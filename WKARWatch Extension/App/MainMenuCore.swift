//
//  MainMenuCore.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture

public enum MainMenuView: Int, CaseIterable {
    case map = 0
    case player = 1
    case settings = 2
}

public struct CardStruct: Equatable, Hashable {
    var name: String
    var image: String
}

struct MainMenuState: Equatable {
    var selectedCard: Int = 0
    let cards: [CardStruct] = [
        CardStruct.init(name: "Karten", image: "map.fill"),
        CardStruct.init(name: "Audio Player", image: "headphones"),
        CardStruct.init(name: "Einstellungen", image: "gear" )
    ]
    
}

enum MainMenuAction: Equatable {
    case onAppear
    case selectedCardChanged(value: Int)
    case digitalCrownChanged(value: Double)
}

public struct MainMenuEnvironment {
    
}

let mainMenuReducer = Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            return .none
        case let .selectedCardChanged(value: value):
            state.selectedCard = value
            print("newValue", value)
            // MARK: TODO send changes via environment
            return .none
        case let .digitalCrownChanged(value: value):
            state.selectedCard = Int(value)
            return .none
    }
}.debug()


