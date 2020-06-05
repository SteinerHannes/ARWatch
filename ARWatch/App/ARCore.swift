//
//  ARCore.swift
//  ARWatch
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct ARState: Equatable {
    
}

enum ARAction: Equatable {
    case print(String)
}

public struct AREnvironment {
    
}

let arReducer = Reducer<ARState, ARAction, AREnvironment> { state, action, environment in
    switch action {
        case let .print(text):
            print(text)
            return .none
    }
}
