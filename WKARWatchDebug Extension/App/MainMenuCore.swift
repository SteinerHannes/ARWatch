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
    var showText: Bool = false
}

enum MainMenuAction: Equatable {
    case onAppear
    case connectivityClient(Result<WKSessionClient.Action, Never>)
    case selectedCardChanged(value: Int)
    case digitalCrownChanged(value: Double)
    case reciveAction(AppCoreAction)
}

public struct MainMenuEnvironment {
    var connectivityClient: WKSessionClient = .live
}

let mainMenuReducer = Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            print("onAppear")
            return environment.connectivityClient.start()
                .catchToEffect()
                .map(MainMenuAction.connectivityClient)
        case let .selectedCardChanged(value: value):
            state.selectedCard = value
            print("newValue", value)
            return environment.connectivityClient.send(
                action: WKCoreAction.MMselectedCardChanged(value: value)
            ).fireAndForget()
        case let .digitalCrownChanged(value: value):
            state.selectedCard = Int(value)
            return .none
        case let .connectivityClient(.success(recivedAction)):
            switch recivedAction {
                case let .reciveAction(action):
                    return Effect(value: .reciveAction(action))
            }
        case let .reciveAction(action):
            switch action {
                case let .reciveTest(text):
                    print(text)
                    return .none
                case .buttonTapped:
                    state.showText.toggle()
                    return .none
        }
    }
}.debug()

