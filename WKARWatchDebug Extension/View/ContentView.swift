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
    @ObservedObject var viewStore: ViewStore<MainMenuState,MainMenuAction>
    
    init(_ store: Store<MainMenuState,MainMenuAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    @State var isMapViewVisible: Bool = false
    @State var isAudioPlayerVisible: Bool = false
    @State var isSettingsVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack {
                PagerManager(pageCount: 3,
                             currentIndex: viewStore.binding(
                                get: { $0.selectedCard },
                                send: MainMenuAction
                                    .selectedCardChanged(value:))
                ) {
                    Card(image: "map.fill", name: "Map")
                    Card(image: "headphones", name: "Audio Player")
                    Card(image: "gear", name: "Settings")
                }
            }
            Spacer()
            HStack {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(self.viewStore.selectedCard == 0 ? Color.white : Color.gray)
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(self.viewStore.selectedCard == 1 ? Color.white  :Color.gray)
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(self.viewStore.selectedCard == 2 ? Color.white : Color.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .onAppear {
            self.viewStore.send(.onAppear)
        }
    }
}


//NavigationLink("", destination: WatchMapView(), isActive: self.$isMapViewVisible)
//    .frame(width: 0, height: 0, alignment: .center)
//NavigationLink("", destination: AudioPlayerView(), isActive: self.$isAudioPlayerVisible)
//    .hidden()
//    .frame(width: 0, height: 0, alignment: .center)
//NavigationLink("", destination: SettingsView(), isActive: self.$isSettingsVisible)
//    .hidden()
//    .frame(width: 0, height: 0, alignment: .center)

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
        TimeTravelView(
            initialState: MainMenuState(),
            reducer: mainMenuReducer,
            environment: MainMenuEnvironment()
        ) { store in
            ContentView(store)
        }.previewDevice("Apple Watch Series 4 - 44mm")
    }
}
