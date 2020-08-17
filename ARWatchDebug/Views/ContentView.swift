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
        GeometryReader { proxy in
            NavigationView {
                VStack(alignment: .center, spacing: 20) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(self.name)
                        }.frame(width: UIScreen.main.bounds.width)
                    }
                    .navigationBarTitle("ARWatch", displayMode: .large)
                    .onAppear{
                        self.viewStore.send(.onAppear)
                    }
                    Button(action: {
                        self.viewStore.send(.buttonTapped)
                    }) {
                        Text("Hello World").font(.largeTitle)
                    }
                    Spacer()
                }
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

