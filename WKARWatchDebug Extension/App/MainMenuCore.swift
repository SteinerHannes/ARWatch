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

struct MainMenuState: Equatable {
    var selectedCard: MainMenuView = .map
    var isMapViewVisible: Bool = false
    var isAudioPlayerVisible: Bool = false
    var isSettingsViewVisible: Bool = false
    var mapState: MapState = .init(
        mapRegion: MKCoordinateRegion(
            center:  CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
    )
    struct MapState: Equatable {
        var mapRegion: MKCoordinateRegion
    }
}

enum MainMenuAction: Equatable {
    case onAppear
    case sessionClient(Result<WKSessionClient.Action, Never>)
    case selectedCardChanged(value: Int)
    case setWatchMapView(isActive: Bool)
    case setAudioPlayerView(isActive: Bool)
    case setSettingsView(isActive: Bool)
    case mapAction(MapAction)
    
    enum MapAction: Equatable {
        case regionChanges(MKCoordinateRegion)
    }
}

public struct MainMenuEnvironment {
    var connectivityClient: WKSessionClient = .live
    var mainQueue = DispatchQueue.main.eraseToAnyScheduler()
}

let mainMenuReducer: Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment> =
    .combine(
        mapReducer.pullback(
            state: \.mapState,
            action: /MainMenuAction.mapAction,
            environment: { $0 }
        ),
        Reducer { state, action, environment in
            switch action {
                case .onAppear:
                    return environment.connectivityClient.start()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map(MainMenuAction.sessionClient)
                case let .selectedCardChanged(value: value):
                    state.selectedCard = MainMenuView(rawValue: value) ?? .map
                    print("newValue", value)
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMselectedCardChanged(value: value)
                    ).fireAndForget()
                case let .setWatchMapView(isActive: active):
                    print("setWatchMapView \(active)")
                    state.isMapViewVisible = active
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMsetWatchMapView(isActive: active)
                    ).fireAndForget()
                case let .setSettingsView(isActive: active):
                    print("setSettingsView \(active)")
                    state.isSettingsViewVisible = active
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMsetSettingsView(isActive: active)
                    ).fireAndForget()
                case let .setAudioPlayerView(isActive: active):
                    print("setAudioPlayerView \(active)")
                    state.isAudioPlayerVisible = active
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMsetAudioPlayerView(isActive: active)
                    ).fireAndForget()
                
                case let .sessionClient(.success(.reciveAction(action))):
                    switch action {
                        case let .MMselectedCardChanged(value: value):
                            state.selectedCard = MainMenuView(rawValue: value)!
                            return .none
                        case let .MapVselectedRegionChanged(value: region):
                            return Effect(value: MainMenuAction.mapAction(.regionChanges(region)))
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
                case .mapAction(_):
                    return .none
            }
        }
    )

let mapReducer = Reducer<MainMenuState.MapState, MainMenuAction.MapAction, MainMenuEnvironment> { state, action, environment in
    switch action {
        case let .regionChanges(region):
            print("Region: \(region)")
            state.mapRegion = region
            return .none
    }
}

let mockEnvironment = MainMenuEnvironment.init(connectivityClient: .mock,
                                               mainQueue: DispatchQueue.main.eraseToAnyScheduler())
extension Reducer where State == MainMenuState, Action == MainMenuAction, Environment == MainMenuEnvironment {
    
    
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
                            _ = self(&state.current, MainMenuAction.sessionClient(.success(.reciveAction(action))), mockEnvironment)
                            state.index = count - pos
                            //var effects = Effect.concatenate(effect)
                            for stateAndAction in slice {
                                state.index += 1
//                                effects = Effect.concatenate(effects,  self(&state.current, action.1, environment))
                                _ = self(&state.current, stateAndAction.1, mockEnvironment)
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
        reducer: Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment>,
        environment: MainMenuEnvironment,
        @ViewBuilder content: @escaping (Store<MainMenuState, MainMenuAction>) -> Content
    ) {
        self.timeStore = Store<TimeTravelState<MainMenuState, MainMenuAction>, TimeTravelAction<MainMenuAction>>.init(
            initialState: TimeTravelState(current: initialState),
            reducer: reducer.timeTravel().debug(),
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
