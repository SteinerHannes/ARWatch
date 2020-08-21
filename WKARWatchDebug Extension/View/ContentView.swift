//
//  ContentView.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 11.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<MainMenuState,MainMenuAction>
    
    init(_ store: Store<MainMenuState,MainMenuAction>) {
        self.store = store
        let viewStore = ViewStore(store)
        viewStore.send(.onAppear)
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                VStack {
                    PagerManager(
                        pageCount: 4,
                        currentIndex: viewStore.binding(
                            get: { $0.selectedCard.rawValue },
                            send: MainMenuAction.selectedCardChanged(value:))
                    ) {
                        Card(image: "map.fill", name: "Map").onTapGesture {
                            viewStore.send(.setWatchMapView(isActive: true))
                        }
                        Card(image: "headphones", name: "Audio Player").onTapGesture {
                            viewStore.send(.setAudioPlayerView(isActive: true))
                        }
                        Card(image: "gear", name: "Settings").onTapGesture {
                            viewStore.send(.setSettingsView(isActive: true))
                        }
                    }
                }
                Spacer()
                HStack {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(viewStore.selectedCard == MainMenuView.map ? Color.white : Color.gray)
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(viewStore.selectedCard == MainMenuView.player ? Color.white  :Color.gray)
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(viewStore.selectedCard == MainMenuView.settings ? Color.white : Color.gray)
                }
                NavigationLink(
                    "",
                    destination: WatchMapView(
                        store: self.store.scope(
                            state: { $0.mapState },
                            action: MainMenuAction.mapAction
                        )
                    ),
                    isActive: viewStore.binding(
                        get: { $0.isMapViewVisible },
                        send: MainMenuAction.setWatchMapView(isActive:))
                ).frame(width: 0, height: 0, alignment: .center)
                NavigationLink(
                    "",
                    destination: AudioPlayerView(
                        store: self.store.scope(
                            state: { $0.audioState },
                            action: MainMenuAction.audioAction
                        )
                    ),
                    isActive: viewStore.binding(
                        get: { $0.isAudioPlayerVisible },
                        send: MainMenuAction.setAudioPlayerView(isActive:))
                ).frame(width: 0, height: 0, alignment: .center)
                NavigationLink(
                    "",
                    destination: SettingsView(
                        store: self.store.scope(
                            state: { $0.settingsState },
                            action: MainMenuAction.settingsAction
                        )
                    ),
                    isActive: viewStore.binding(
                        get: { $0.isSettingsViewVisible },
                        send: MainMenuAction.setSettingsView(isActive:))
                ).frame(width: 0, height: 0, alignment: .center)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

struct Card: View {
    var image: String
    var name: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: self.image)
                .resizable()
                .frame(width: 30, height: 30)
            Text(self.name)
                .font(.headline)
                .scaledToFit()
        }
        .frame(height: 140, alignment: .center)
        .frame(width: 140)
        .background(Color.init(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTravelView<ContentView>(
            initialState: MainMenuState(),
            reducer: mainMenuReducer,
            environment: MainMenuEnvironment()
        ) { store in
            ContentView(store)
        }.previewDevice("Apple Watch Series 4 - 44mm")
    }
}
