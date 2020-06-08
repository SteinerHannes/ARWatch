//
//  ContentView.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<MainMenuState,MainMenuAction>
    @ObservedObject var viewStore: ViewStore<MainMenuState,MainMenuAction>
    
    init() {
        self.store = Store(
            initialState: MainMenuState(),
            reducer: mainMenuReducer,
            environment: MainMenuEnvironment()
        )
        self.viewStore = ViewStore(self.store)
    }
    
    @State var isMapOpen: Bool = false
    @State var isPlayerOpen: Bool = false
    @State var isSettingsOpen: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader { geometry in
                PagingScrollView(
                    activePageIndex: self.viewStore.binding(
                        get: { $0.selectedCard },
                        send: MainMenuAction.selectedCardChanged(value:)),
                    itemCount: self.viewStore.cards.count,
                    pageWidth: 200,
                    tileWidth: 200 - 32,
                    tilePadding: 32
                ) {
                    ForEach(self.viewStore.cards, id: \.hashValue) { card in
                        Card(image: card.image, name: card.name)
                        .onTapGesture {
                            print(card.image)
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
    var image: String
    var name: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: image)
                .resizable()
                .frame(width: 30, height: 30)
            Text(name)
                .font(.headline)
                .scaledToFit()
        }
        .frame(height: 140, alignment: .center)
        .frame(width: 200 - 32)
        .background(Color.init(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
         .previewDevice("Apple Watch Series 4 - 44mm")
    }
}
