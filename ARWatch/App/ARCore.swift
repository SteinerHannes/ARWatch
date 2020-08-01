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
    case onAppear
    case print(String)
    case buttonTapped
    case connectivityClient(Result<AppWKSessionClient.Action, Never>)
    case reciveAction(WKCoreAction)
}

public struct AREnvironment {
    var sessionClient: AppWKSessionClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}

let arReducer = Reducer<ARState, ARAction, AREnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            return environment.sessionClient.start()
                .catchToEffect()
                .map(ARAction.connectivityClient)
        case let .connectivityClient(.success(recivedAction)):
            switch recivedAction {
                case let .reciveAction(action):
                    return Effect(value: .reciveAction(action))
            }
        case let .print(text):
            print(text)
            return .none
        case .buttonTapped:
            return .none
            
        case let .reciveAction(action):
            return .none
    }
}
