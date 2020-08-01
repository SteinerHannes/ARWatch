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
    var value: Int = 0
}

enum ContentAction: Equatable {
    case onAppear
    case sessionClient(Result<AppWKSessionClient.Action, Never>)
    case setNavigationARView(isPresented: Bool)
    case arAction(ARAction)
    case reciveAction(WKCoreAction)
    case buttonTapped
}

public struct ContentEnvironment {
    var sessionClient: AppWKSessionClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}

let contentReducer: Reducer<ContentState, ContentAction, ContentEnvironment> =
.combine(
    Reducer { state, action, environment in
        switch action {
            case .onAppear:
                return environment.sessionClient.start()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(ContentAction.sessionClient)
            case let .setNavigationARView(isPresented: isPresented):
                print(isPresented)
                return .none
            case .arAction:
                return .none
            case let .sessionClient(.success(recivedAction)):
                switch recivedAction {
                    case let .reciveAction(action):
                        return Effect(value: .reciveAction(action))
                }
            case let .reciveAction(action):
                switch action {
                    case let .MMselectedCardChanged(value: value):
                    print("GET MMselectedCardChanged: ", value)
                    state.value = value
                    return .none
                }
            case .buttonTapped:
                return environment.sessionClient.send(
                    action: AppCoreAction.buttonTapped
                ).fireAndForget()
        }
    }.debug()
)
