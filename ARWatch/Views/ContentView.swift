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
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(self.viewStore.value)")
                }.frame(width: UIScreen.main.bounds.width)
            }
            .navigationBarTitle("ARWatch", displayMode: .large)
            .onAppear{
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
