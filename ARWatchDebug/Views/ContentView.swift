//
//  ContentView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 08.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    let store: Store<ContentState, ContentAction>
    
    @ObservedObject var viewStore: ViewStore<ContentState, ContentAction>
    
    init(_ store: Store<ContentState, ContentAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var name: String {
        if self.viewStore.state.value == 0 {
            return "Karten"
        }
        if self.viewStore.state.value == 1 {
            return "Audio Player"
        }
        if self.viewStore.state.value == 2 {
            return "Einstellungen"
        }
        return "Fehler"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                if self.viewStore.state.value == 0 {
                    MapView()
                } else if self.viewStore.state.value == 1 {
                    AudioPlayerView()
                } else if self.viewStore.state.value == 2 {
                    SettingsView()
                } else {
                    EmptyView()
                }
            }
            .navigationBarTitle("\(self.name)", displayMode: .large)
            .onAppear {
                print("LOS")
                self.viewStore.send(.onAppear)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTravelView(
            initialState: ContentState(),
            reducer: contentReducer,
            environment: ContentEnvironment()
        ) { store in
            ContentView(store)
        }
    }
}

