//
//  SettingsCore.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 20.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture

#if os(iOS) || os(watchOS)

public struct SettingsState: Equatable {
    var name: String = ""
}

#endif
#if os(iOS) || os(watchOS)
public enum SettingsAction: Equatable {
    case nameChanged(to: String)
}
#endif

#if os(iOS) || os(watchOS)
public struct SettingsEnvironment {
    #if os(iOS)
    var sessionClient: AppWKSessionClient = .live
    #elseif os(watchOS)
    var connectivityClient: WKSessionClient = .live
    #endif
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}
#endif

#if os(iOS) || os(watchOS)
let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in
    switch action {
        case let .nameChanged(to: name):
            state.name = name
            #if os(watchOS)
            return environment.connectivityClient.send(
                action: WKCoreAction.SettingsNameChanged(name: name)
            ).fireAndForget()
            #else
            return environment.sessionClient.send(
                action: AppCoreAction.SettingsNameChanged(name: name)
            ).fireAndForget()
            #endif
    }
}
#endif
