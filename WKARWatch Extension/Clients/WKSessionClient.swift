//
//  WKSessionClient.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import WatchConnectivity
import ComposableArchitecture
import Combine


public struct WKSessionClient {
    enum Action: Equatable {
        case newAction(AppCoreAction)
    }
    
    private var create: () -> Effect<Action, Never>
    private var send: (WKCoreAction) -> Effect<Never, Never>
    
    func start() -> Effect<Action, Never> {
        self.create()
    }
    
    func send(action: WKCoreAction) -> Effect<Never, Never> {
        return self.send(action)
    }
}

public var sharedWKSessionManager: WKSessionManager?

extension WKSessionClient {
    static let live = WKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { subscriber in
                let manager = WKSessionManager { (message) in
                    let action = message["action"]!
                    subscriber.send(.newAction(action as! AppCoreAction))
                }
                return AnyCancellable { sharedWKSessionManager = manager }
            }
        },
        send: { action in
            .fireAndForget {
                guard let manager = sharedWKSessionManager else {
                    debugPrint("WKSessionManager noch nicht initialisiert")
                    return
                }
                manager.send(action: action)
            }
        }
    )
}

public final class WKSessionManager: NSObject, WCSessionDelegate {
    var session: WCSession?
    
    var handler: ([String : Any]) -> Void
    
    init(messageHandler: @escaping ([String : Any]) -> Void ){
        handler = messageHandler

        super.init()
        
        session = WCSession.default
        session!.delegate = self
        session!.activate()
        debugPrint(" Watch App Installed: \(session!.isReachable)")
    }
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handler(message)
        WKInterfaceDevice.current().play(.notification)
    }
    
    func send(action: WKCoreAction) {
        let msg = ["action": action]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
        })
    }
}