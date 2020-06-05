//
//  ListView.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ListView: View {
    
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

    @State var scrollAmount = 0.0
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader { geometry in
                PagingScrollView(
                    activePageIndex: self.viewStore.binding(
                        get: { $0.selectedCard },
                        send: MainMenuAction.selectedCardChanged(value:)),
                    itemCount: self.viewStore.cards.count,
                    pageWidth: 368,
                    tileWidth: 368 - 32,
                    tilePadding: 32
                ) {
                    ForEach(self.viewStore.cards, id: \.hashValue) { card in
                        Card(image: card.image, name: card.name)
                    }
                }
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
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
        .frame(width: 368 - 32)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
