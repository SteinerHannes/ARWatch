//
//  AudioPlayerView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView: View {
    let store: Store<AudioState, AudioAction>
    
    init(store: Store<AudioState, AudioAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                #if os(iOS)
                VStack(alignment: .center, spacing: 30) {
                    TrackInfoView(track: viewStore.currentTrack)
                    TrackControllView(store: self.store)
                }
                #else
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    TrackInfoView(track: viewStore.currentTrack)
                    TrackControllView(store: self.store)
                }
                #endif
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
        }
    }
}

struct TrackInfoView: View {
    let track: Track
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            #if os(iOS)
            Text(track.titel)
                .font(.largeTitle)
            Text(track.artist)
                .font(.title)
            Text(track.album)
                .font(.title)
            #endif
            #if os(watchOS)
            Text(track.titel)
                .font(.body)
            Text(track.artist)
                .font(.body)
            Text(track.album)
                .font(.body)
            #endif
        }
    }
}

struct TrackControllView: View {
    let store: Store<AudioState, AudioAction>
    
    init(store: Store<AudioState, AudioAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 10) {
                #if os(iOS)
                HStack(alignment: .center, spacing: 30) {
                    Button(
                        action: {
                            viewStore.send(.back)
                        },
                        label: {
                            Image(systemName: "backward.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    )
                    Button(
                        action: {
                            if viewStore.isPlaying {
                                viewStore.send(.pause)
                            } else {
                                viewStore.send(.play)
                            }
                        },
                        label: {
                            Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    )
                    Button(
                        action: {
                            viewStore.send(.next)
                        },
                        label: {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    )
                }.accentColor(.primary)
                #endif
                #if os(watchOS)
                HStack(alignment: .center, spacing: 20) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .onTapGesture {
                            viewStore.send(.back)
                        }
                    Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .onTapGesture {
                            if viewStore.isPlaying {
                                viewStore.send(.pause)
                            } else {
                                viewStore.send(.play)
                            }
                        }
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .onTapGesture {
                            viewStore.send(.next)
                        }
                }
                #endif
                HStack(alignment: .center, spacing: 0) {
                    #if os(iOS)
                    Text("\(timeToString(time: viewStore.time))").font(.caption)
                    Slider(
                        value: viewStore.binding(
                            get: { Double($0.time) },
                            send: AudioAction.setTrack(to:)
                        ),
                        in: 0.0...Double(viewStore.currentTrack.length)
                    ).padding(.horizontal,5)
                    Text("\(timeToString(time: viewStore.currentTrack.length))").font(.caption)
                    #endif
                    #if os(watchOS)
                    VStack(alignment: .center, spacing: 0) {
                        Slider(
                            value: viewStore.binding(
                                get: { Double($0.time) },
                                send: AudioAction.setTrack(to:)
                            ),
                            in: 0.0...Double(viewStore.currentTrack.length)
                        )
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(timeToString(time: viewStore.time))").font(.caption)
                            Spacer()
                            Text("\(timeToString(time: viewStore.currentTrack.length))").font(.caption)
                        }
                    }
                    #endif
                }.padding(.horizontal)
            }
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerView(
                store: Store(
                    initialState: AudioState(
                        currentTrack: .init(
                            titel: "Under Pressure",
                            artist: "Queen & David Bowie",
                            album: "Hot Space",
                            length: 320)
                        ),
                    reducer: audioReducer,
                    environment: AudioEnvironment()
                )
            )
        }
    }
}

func timeToString(time: Int) -> String {
    return String.init(format: "%02d:%02d", time / 60, time % 60)
}
