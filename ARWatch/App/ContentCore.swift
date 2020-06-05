//
//  ContentCore.swift
//  ARWatch
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct ContentState: Equatable {
    var ARView: ARState?
}

enum ContentAction: Equatable {
    case onAppear
    case setNavigationARView(isPresented: Bool)
    case arAction(ARAction)
}

public struct ContentEnvironment {
    
}

let contentReducer: Reducer<ContentState, ContentAction,ContentEnvironment> =
.combine(
    Reducer { state, action, environment in
        switch action {
            case .onAppear:
                return .none
            case let .setNavigationARView(isPresented: isPresented):
                print(isPresented)
                return .none
            case .arAction:
                return .none
        }
    }.debug()

)
