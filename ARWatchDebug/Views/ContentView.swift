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
    
    init(_ store: Store<ContentState, ContentAction>) {
        self.store = store
        let  viewStore = ViewStore(self.store)
        viewStore.send(.onAppear)
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker(
                        selection: viewStore.binding(
                            get: { $0.selectedView.rawValue },
                            send: ContentAction.selectedViewChanged(value: )
                        ),
                        label: Text("What is your favorite color?")
                    ) {
                        ForEach(MainMenuView.allCases, id: \.self ) { viewCase in
                            Text("\(viewCase.titel)").tag(viewCase.rawValue)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    if viewStore.state.visibleView == .map {
                        MapView(store: self.store.scope(
                            state: { $0.mapState },
                            action: ContentAction.mapAction
                            )
                        )
                    } else if viewStore.state.visibleView == .player {
                        AudioPlayerView(store: self.store.scope(
                            state: { $0.audioState },
                            action: ContentAction.audioAction
                            )
                        )
                        Spacer()
                    } else if viewStore.state.visibleView == .settings {
                        SettingsView()
                        Spacer()
                    } else {
                        Spacer()
                    }
                }
                .navigationBarTitle("\(viewStore.selectedView.titel)", displayMode: .large)
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

