//
//  ContentView.swift
//  ARWatch
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import UIKit
import ComposableArchitecture

struct ContentView: View {
    
    let store: Store<ContentState, ContentAction>
    
    @ObservedObject var viewStore: ViewStore<ContentState, ContentAction>
    
    init() {
        self.store = Store(
            initialState: ContentState(),
            reducer: contentReducer,
            environment: ContentEnvironment()
        )
        self.viewStore = ViewStore(self.store)
    }
    
    var name: String {
        if self.viewStore.state.value == 0 {
            return "Karten"
        }
        if self.viewStore.state.value == 1 {
            return "Audioplayer"
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
            .frame(width: proxy.size.width/3, height: proxy.size.width/3, alignment: .top)
            .offset(x: proxy.size.width/3, y: -20)
            .onAppear {
                self.viewStore.send(.onAppear)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
