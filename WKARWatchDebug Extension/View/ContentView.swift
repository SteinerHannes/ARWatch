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
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader { geometry in
                PagingScrollView(
                    activePageIndex: self.viewStore.binding(
                        get: { $0.selectedCard },
                        send: MainMenuAction.selectedCardChanged(value:)),
                    itemCount: self.viewStore.cards.count,
                    pageWidth: 150,
                    tileWidth: 140,
                    tilePadding: 10
                ) {
                    ForEach(self.viewStore.cards, id: \.hashValue) { card in
                        ZStack(alignment: .center) {
                            Card(store: self.store, image: card.image, name: card.name)
                                .onTapGesture {
                                    print(card.image)
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .onAppear {
            self.viewStore.send(.onAppear)
        }
    }
}

struct Card: View {
    let store: Store<MainMenuState, MainMenuAction>
    var image: String
    var name: String
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: self.image)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(self.name)
                    .font(.headline)
                    .scaledToFit()
                if viewStore.state.showText {
                    Text("Hello World")
                }
            }
            .frame(height: 140, alignment: .center)
            .frame(width: 140)
            .background(Color.init(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(20)
        }
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
