//
//  AudioCore.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Combine

public struct Track: Equatable {
    let titel: String
    let artist: String
    let album: String
    let length: Int
}

public struct AudioState: Equatable {
    var currentTrack: Track
    var time: Int = 0
    var isPlaying: Bool = false
}

public enum AudioAction: Equatable {
    case onAppear
    case play
    case pause
    case back
    case next
    case setTrack(to: Double)
    case update(Result<AudioPlayerClient.Action,Never>)
    case onDisappear
}

struct AudioEnvironment {
    var player: AudioPlayerClient = .live
    var mainQueue = DispatchQueue.main.eraseToAnyScheduler()
}

let audioReducer = Reducer<AudioState,AudioAction,AudioEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            return environment.player.start(track: state.currentTrack)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AudioAction.update)
        case .play:
            state.isPlaying = true
            return environment.player.resume().fireAndForget()
        case .pause:
            state.isPlaying = false
            return environment.player.stop().fireAndForget()
        case .back:
            return .none
        case .next:
            return .none
        case let .setTrack(to: to):
            state.isPlaying = false
            let time = Int(to)
            state.time = time
            return environment.player.setTo(time: time).fireAndForget()
        case let .update(.success(action)):
            switch action {
                case let .update(value):
                    state.time = value
                    return .none
            }
        case .onDisappear:
            return environment.player.stop().fireAndForget()
    }
}


public struct AudioPlayerClient {
    public enum Action: Equatable {
        case update(Int)
    }
    
    private var startPlayer: (Track) -> Effect<Action, Never>
    private var playTrack: (Track) -> Effect<Never, Never>
    private var stopTrack: () -> Effect<Never, Never>
    private var resumeTrack: () -> Effect<Never, Never>
    private var setTrackTo: (Int) -> Effect<Never, Never>
    
    func play(track: Track) -> Effect<Never, Never> {
        self.playTrack(track)
    }
    
    func stop() -> Effect<Never, Never> {
        self.stopTrack()
    }
    
    func resume() -> Effect<Never, Never> {
        self.resumeTrack()
    }
    
    func setTo(time: Int) -> Effect<Never, Never> {
        self.setTrackTo(time)
    }
    
    func start(track: Track) -> Effect<Action, Never> {
        self.startPlayer(track)
    }
}

extension AudioPlayerClient {
    static let live = AudioPlayerClient(
        startPlayer: { (track) -> Effect<Action, Never> in
            .run { subscriber in
                AudioPlayer.shared.setTrack(track)
                return AudioPlayer.shared.time.map { value in
                    Action.update(value)
                }.sink { (action) in
                    subscriber.send(action)
                }
            }
        },
        playTrack: { (track) -> Effect<Never, Never> in
            .fireAndForget {
                AudioPlayer.shared.start(track)
            }
        },
        stopTrack: { () -> Effect<Never, Never> in
            .fireAndForget {
                AudioPlayer.shared.stop()
            }
        },
        resumeTrack: { () -> Effect<Never, Never> in
            .fireAndForget {
                AudioPlayer.shared.resume()
            }
        },
        setTrackTo: { (time) -> Effect<Never, Never> in
            .fireAndForget {
                AudioPlayer.shared.setTime(to: time)
            }
        }
    )
}

class AudioPlayer: NSObject  {
    static let shared = AudioPlayer()

    private var track: Track?
    
    public var time = CurrentValueSubject<Int, Never>(0)
    
    private weak var timer: Timer?
    
    private override init( ) { }
    
    public func start(_ track: Track) {
        setTrack(track)
        resume()
    }
    
    public func stop() {
        timer?.invalidate()
    }
    
    public func resume() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if let length = self.track?.length {
                if self.time.value <= length {
                    self.time.value += 1
                } else {
                    self.stopTimer()
                }
            } else {
                self.stopTimer()
            }
        })
    }
    
    public func setTime(to: Int) {
        self.timer?.invalidate()
        self.timer = nil
        self.time.value = to
    }
    
    public func setTrack(_ track: Track) {
        stopTimer()
        if self.track != track {
            self.track = track
            self.time.value = 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        self.timer = nil
    }
}
