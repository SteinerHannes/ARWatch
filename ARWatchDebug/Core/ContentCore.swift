//
//  ContentCore.swift
//  ARWatch
//
//  Created by Hannes Steiner on 11.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public struct ContentState: Equatable {
    var value: Int = 0
}

public enum ContentAction: Equatable {
    case onAppear
    case sessionClient(Result<AppWKSessionClient.Action, Never>)
    case buttonTapped
}

public struct ContentEnvironment {
    var sessionClient: AppWKSessionClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}

public let contentReducer: Reducer<ContentState, ContentAction, ContentEnvironment> =
    .combine(
        Reducer { state, action, environment in
            switch action {
                case .onAppear:
                    return environment.sessionClient.start()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map(ContentAction.sessionClient)
                case let .sessionClient(.success(.reciveAction(action))):
                    switch action {
                        case let .MMselectedCardChanged(value: value):
                            print("GET MMselectedCardChanged: ", value)
                            state.value = value
                            return .none
                }
                case .buttonTapped:
                    return environment.sessionClient.send(
                        action: AppCoreAction.buttonTapped
                    ).fireAndForget()
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
    )

extension Reducer where State == ContentState, Action == ContentAction {
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
                            state.history.append((state.current, ContentAction.sessionClient(.success(.reciveAction(action)))))
                            _ = self(&state.current, ContentAction.sessionClient(.success(.reciveAction(action))), environment)
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
    private let timeStore: Store<TimeTravelState<ContentState, ContentAction>, TimeTravelAction<ContentAction>>
    private let content: (Store<ContentState, ContentAction>) -> Content
    
    init(
        initialState: ContentState,
        reducer: Reducer<ContentState, ContentAction, Environment>,
        environment: Environment,
        @ViewBuilder content: @escaping (Store<ContentState, ContentAction>) -> Content
    ) {
        self.timeStore = Store<TimeTravelState<ContentState, ContentAction>, TimeTravelAction<ContentAction>>.init(
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
