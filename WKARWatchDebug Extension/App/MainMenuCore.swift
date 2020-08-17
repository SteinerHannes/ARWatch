//
//  MainMenuCore.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public enum MainMenuView: Int, CaseIterable {
    case map = 0
    case player = 1
    case settings = 2
}

public struct CardStruct: Equatable, Hashable {
    var name: String
    var image: String
}

struct MainMenuState: Equatable {
    var selectedCard: Int = 0

    var showText: Bool = false
}

enum MainMenuAction: Equatable {
    case onAppear
    case sessionClient(Result<WKSessionClient.Action, Never>)
    case selectedCardChanged(value: Int)
    case digitalCrownChanged(value: Double)
}

public struct MainMenuEnvironment {
    var connectivityClient: WKSessionClient = .live
    var mainQueue = DispatchQueue.main.eraseToAnyScheduler()
}

let mainMenuReducer = Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            print("onAppear")
            return environment.connectivityClient.start()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(MainMenuAction.sessionClient)
        case let .selectedCardChanged(value: value):
            state.selectedCard = value
            print("newValue", value)
            return environment.connectivityClient.send(
                action: WKCoreAction.MMselectedCardChanged(value: value)
            ).fireAndForget()
        case let .digitalCrownChanged(value: value):
            state.selectedCard = Int(value)
            return .none
        case let .sessionClient(.success(.reciveAction(action))):
            switch action {
                case let .reciveTest(text):
                    print(text)
                    return .none
                case .buttonTapped:
                    state.showText.toggle()
                    return .none
            }
        case .sessionClient(.success(.reciveActionAndError(action: _, position: _))):
            return .none
        case let .sessionClient(.success(.reciveError(error))):
            switch error {
                
                case let .error(error):
                    print("ERROR: " + error.localizedDescription)
                case let .isReachable(bool):
                    print("ERROR: isReachable \(bool)")
                case .disconnected:
                    print("ERROR: disconnected")
                case let .isPaired(bool):
                    print("ERROR: isPaired \(bool)")
            }
            return .none
    }
}


extension Reducer where State == MainMenuState, Action == MainMenuAction {
    func timeTravel() -> Reducer<TimeTravelState<State, Action>, TimeTravelAction<Action>, Environment> {
        .init { state, action, environment in
            switch action {
                case let .child(childAction):
                    let count = state.history.count
                    switch childAction {
                        case let .sessionClient(.success(.reciveActionAndError(action: action, position: pos))):
                            let slice = state.history.suffix(from: count - pos)
                            state.current = state.history[count - pos].0
                            state.history.removeSubrange((count - pos)...)
                            state.history.append((state.current, MainMenuAction.sessionClient(.success(.reciveAction(action)))))
                            _ = self(&state.current, MainMenuAction.sessionClient(.success(.reciveAction(action))), environment)
                            state.index = count - pos
                            //var effects = Effect.concatenate(effect)
                            for stateAndAction in slice {
                                state.index += 1
//                                effects = Effect.concatenate(effects,  self(&state.current, action.1, environment))
                                _ = self(&state.current, stateAndAction.1, environment)
                                state.history.append((state.current, stateAndAction.1))
                                if state.history.count == maxHistoryCount {
                                    state.history.removeFirst(1)
                                    state.index -= 1
                                }
                            }
                            return .none//effects.map(TimeTravelAction.child)
                        default:
                            break
                    }
                    state.index += 1
                    if state.history.count > state.index {
                        state.history.removeSubrange(state.index...)
                    }
                    state.history.append((state.current, childAction))
                    if state.history.count == maxHistoryCount {
                        state.history.removeFirst(1)
                        state.index -= 1
                    }
                    let effect = self(&state.current, childAction, environment)
                    return effect.map(TimeTravelAction.child)
            }
        }
    }
}

struct TimeTravelView<Environment, Content: View>: View {
    private let timeStore: Store<TimeTravelState<MainMenuState, MainMenuAction>, TimeTravelAction<MainMenuAction>>
    private let content: (Store<MainMenuState, MainMenuAction>) -> Content
    
    init(
        initialState: MainMenuState,
        reducer: Reducer<MainMenuState, MainMenuAction, Environment>,
        environment: Environment,
        @ViewBuilder content: @escaping (Store<MainMenuState, MainMenuAction>) -> Content
    ) {
        self.timeStore = Store<TimeTravelState<MainMenuState, MainMenuAction>, TimeTravelAction<MainMenuAction>>.init(
            initialState: TimeTravelState(current: initialState),
            reducer: reducer.timeTravel(),
            environment: environment
        )
        self.content = content
    }
    
    var body: some View {
        self.content(
            self.timeStore.scope(
                state: \TimeTravelState.current,
                action: TimeTravelAction.child
            )
        )
    }
}
