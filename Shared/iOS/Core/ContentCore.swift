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
import MapKit
import WatchConnectivity
import Combine

#if os(iOS) || os(watchOS)

public struct ContentState: Equatable {
    var selectedView: MainMenuView = .map
    var visibleView: MainMenuView? = nil
    var mapState: MapState =
        .init(mapRegion: MKCoordinateRegion(
            center:  CLLocationCoordinate2D(latitude: 12.9716,
                                            longitude: 77.5946),
            span: MKCoordinateSpan(latitudeDelta: 2.0,
                                   longitudeDelta: 2.0)
            )
        )
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

#if os(iOS)
public enum ContentAction: Equatable {
    case onAppear
    case sessionClient(Result<AppWKSessionClient.Action, Never>)
    case selectedViewChanged(value: Int)
    case mapAction(MapAction)
    case audioAction(AudioAction)
    case settingsAction(SettingsAction)
}

public struct ContentEnvironment {
    var sessionClient: AppWKSessionClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    var audioEnvironment = AudioEnvironment()
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
                            state.selectedView = MainMenuView(rawValue: value) ?? .map
                            return .none
                        case let .MMsetWatchMapView(isActive: value):
                            print("GET MMsetWatchMapView: ", value)
                            state.visibleView = (value ? .map : nil)
                            return .none
                        case let .MMsetAudioPlayerView(isActive: value):
                            print("GET MMsetAudioPlayerView: ", value)
                            state.visibleView = (value ? .player : nil)
                            return .none
                        case let .MMsetSettingsView(isActive: value):
                            print("GET MMsetSettingsView: ", value)
                            state.visibleView = (value ? .settings : nil)
                            return .none
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
                case .selectedViewChanged(value: let value):
                    state.selectedView = MainMenuView.init(rawValue: value)!
                    return environment.sessionClient.send(
                        action: .MMselectedCardChanged(value: value)
                    ).fireAndForget()
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
                            return environment.sessionClient.send(
                                action: AppCoreAction.AudioStart
                            ).fireAndForget()
                        case .pause:
                            return environment.sessionClient.send(
                                action: AppCoreAction.AudioStop(at: state.audioState.time)
                            ).fireAndForget()
                        case let .setTrack(to: time):
                            return environment.sessionClient.send(
                                action: AppCoreAction.AudioSet(to: Int(time))
                            ).fireAndForget()
                        default:
                            break
                    }
                    return .none
                case .settingsAction(_):
                    return .none
            }
        },
        mapReducer.pullback(
            state: \.mapState,
            action: /ContentAction.mapAction,
            environment: { $0 }
        ),
        audioReducer.pullback(
            state: \.audioState,
            action: /ContentAction.audioAction,
            environment: { $0.audioEnvironment }
        ),
        settingsReducer.pullback(
            state: \.settingsState,
            action: /ContentAction.settingsAction,
            environment: { SettingsEnvironment(sessionClient: $0.sessionClient, mainQueue: $0.mainQueue) }
        )
    )

let mockEnvironment = ContentEnvironment.init(sessionClient: .mock,
                                              mainQueue: DispatchQueue.main.eraseToAnyScheduler())

extension Reducer where State == ContentState, Action == ContentAction, Environment == ContentEnvironment {
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
                            state.history.append((state.current, .sessionClient(.success(.reciveAction(action)))))
                            _ = self(&state.current, .sessionClient(.success(.reciveAction(action))), mockEnvironment)
                            state.index = count - pos
                            for stateAndAction in slice {
                                state.index += 1
                                _ = self(&state.current, stateAndAction.1, mockEnvironment)
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
                                    state.isReachable = false
                                    print("ERROR: " + error.localizedDescription)
                                case let .isReachable(bool):
                                    if !state.isReachable && bool {
                                        state.isReachable = bool
                                        state.history = []
                                        state.index = -1
                                        return environment
                                            .sessionClient
                                            .sync(state: state.current)
                                            .fireAndForget()
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
                    return self(&state.current, childAction, environment)
                        .map(TimeTravelAction.child)
            }
        }
    }
}
#endif
