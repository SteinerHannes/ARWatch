//
//  MainMenuCore.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//


import WatchConnectivity
import Combine
import Foundation
import ComposableArchitecture
import SwiftUI
import MapKit

#if os(watchOS) || os(iOS)

public struct MainMenuState: Equatable {
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
    var audioState: AudioState =
        .init(currentTrack: .init(
            titel: "Under Pressure",
            artist: "Queen & David Bowie",
            album: "Hot Space",
            length: 320)
        )
    var settingsState = SettingsState()
}

#endif
#if os(watchOS)

enum MainMenuAction: Equatable {
    case onAppear
    case sessionClient(Result<WKSessionClient.Action, Never>)
    case selectedCardChanged(value: Int)
    case setWatchMapView(isActive: Bool)
    case setAudioPlayerView(isActive: Bool)
    case setSettingsView(isActive: Bool)
    case audioAction(AudioAction)
    case settingsAction(SettingsAction)
    case mapAction(MapAction)
    
    enum MapAction: Equatable {
        case regionChanges(MKCoordinateRegion)
    }
}

public struct MainMenuEnvironment {
    var connectivityClient: WKSessionClient = .live
    var mainQueue = DispatchQueue.main.eraseToAnyScheduler()
    var audioEnvironment = AudioEnvironment()
}

let mainMenuReducer: Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment> =
    .combine(
        Reducer { state, action, environment in
            switch action {
                case .onAppear:
                    return environment.connectivityClient.start()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map(MainMenuAction.sessionClient)
                case let .selectedCardChanged(value: value):
                    state.selectedCard = MainMenuView(rawValue: value) ?? .map
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMselectedCardChanged(value: value)
                    ).fireAndForget()
                case let .setWatchMapView(isActive: active):
                    state.isMapViewVisible = active
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMsetWatchMapView(isActive: active)
                    ).fireAndForget()
                case let .setSettingsView(isActive: active):
                    state.isSettingsViewVisible = active
                    return environment.connectivityClient.send(
                        action: WKCoreAction.MMsetSettingsView(isActive: active)
                    ).fireAndForget()
                case let .setAudioPlayerView(isActive: active):
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
                        case .AudioStart:
                            state.audioState.isPlaying = true
                            return environment.audioEnvironment.player.resume().fireAndForget()
                        case let .AudioStop(at: time):
                            state.audioState.isPlaying = false
                            return environment.audioEnvironment.player.setTo(time: time).fireAndForget()
                        case let .AudioSet(to: time):
                            state.audioState.isPlaying = false
                            state.audioState.time = time
                            return environment.audioEnvironment.player.setTo(time: time).fireAndForget()
                        case let .SettingsNameChanged(name: name):
                            state.settingsState.name = name
                            return .none
                }
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
                case .sessionClient(.success(.reciveActionAndError(action: _, position: _))):
                    return .none
                case .sessionClient(.success(.reciveState(_))):
                    return .none
                case .mapAction(_):
                    return .none
                case let .audioAction(action):
                    switch action {
                        case .play:
                            return environment.connectivityClient.send(
                                action: WKCoreAction.AudioStart
                            ).fireAndForget()
                        case .pause:
                            return environment.connectivityClient.send(
                                action: WKCoreAction.AudioStop(at: state.audioState.time)
                                ).fireAndForget()
                        case let .setTrack(to: time):
                            return environment.connectivityClient.send(
                                action: WKCoreAction.AudioSet(to: Int(time))
                            ).fireAndForget()
                        default:
                            break
                    }
                    return .none
                case .settingsAction(_):
                    return .none
            }
        },
        watchMapReducer.pullback(
            state: \.mapState,
            action: /MainMenuAction.mapAction,
            environment: { $0 }
        ),
        audioReducer.pullback(
            state: \.audioState,
            action: /MainMenuAction.audioAction,
            environment: { $0.audioEnvironment }
        ),
        settingsReducer.pullback(
            state: \.settingsState,
            action: /MainMenuAction.settingsAction,
            environment: { SettingsEnvironment(connectivityClient: $0.connectivityClient , mainQueue: $0.mainQueue) }
        )
    )

let watchMapReducer = Reducer<MainMenuState.MapState, MainMenuAction.MapAction, MainMenuEnvironment> { state, action, environment in
    switch action {
        case let .regionChanges(region):
            state.mapRegion = region
            return .none
    }
}

let watchMockEnvironment = MainMenuEnvironment.init(connectivityClient: .mock,
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
                            _ = self(&state.current, MainMenuAction.sessionClient(.success(.reciveAction(action))), watchMockEnvironment)
                            state.index = count - pos
                            for stateAndAction in slice {
                                state.index += 1
                                _ = self(&state.current, stateAndAction.1, watchMockEnvironment)
                                state.history.append((state.current, stateAndAction.1))
                                if state.history.count == maxHistoryCount {
                                    state.history.removeFirst(1)
                                    state.index -= 1
                                }
                            }
                            return .none
                        case let .sessionClient(.success(.reciveError(error))):
                            switch error {
                                case let .error(error):
                                    print("ERROR: " + error.localizedDescription)
                                case let .isReachable(bool):
                                    if !state.isReachable && bool {
                                        state.isReachable = bool
                                        state.history = []
                                        state.index = -1
                                        watchSharedWKSessionManager?.counter.reset()
                                        return .none
//                                        return environment
//                                            .connectivityClient
//                                            .sync(state: state.current)
//                                            .fireAndForget()
                                    }
                                    state.isReachable = bool
                                    print("ERROR: isReachable \(bool)")
                                case .disconnected:
                                    print("ERROR: disconnected")
                                case let .isPaired(bool):
                                    print("ERROR: isPaired \(bool)")
                            }
                            return .none
                        case let .sessionClient(.success(.reciveState(newState))):
                            state.current = newState
                            state.history = []
                            state.index = -1
                            return environment.audioEnvironment.player.setTo(time: state.current.audioState.time).fireAndForget()
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

#endif
