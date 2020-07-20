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
        case reciveAction(AppCoreAction)
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
                if !WCSession.isSupported() {
                    fatalError("WCSession is not supported on this device.")
                }
                let manager = WKSessionManager { (message) in
                    let action = message["action"]!
                    subscriber.send(.reciveAction(action as! AppCoreAction))
                }
                sharedWKSessionManager = manager
                return AnyCancellable { }
            }
        },
        send: { action in
            .fireAndForget {
                guard let manager = sharedWKSessionManager else {
                    fatalError("WKSessionManager noch nicht initialisiert")
                }
                print("action send:", action)
                sharedWKSessionManager?.send(action: action)
            }
        }
    )
}

public final class WKSessionManager: NSObject, WCSessionDelegate {
    var session: WCSession?
    
    var handler: (([String : Any]) -> Void)?
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    init(messageHandler: @escaping ([String : Any]) -> Void ){
        super.init()
        handler = messageHandler
        session = WCSession.default
        session!.delegate = self
        session!.activate()
        debugPrint("Watch App Installed: \(session!.isReachable)")
    }
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
            case .notActivated:
                print("notActivated")
            case .inactive:
                print("inactive")
            case .activated:
                print("activated")
            @unknown default:
                print("default")
        }
        
        debugPrint("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let encodedAction = message["action"]!
        let action = try! self.decoder.decode(AppCoreAction.self, from: encodedAction as! Data)
        handler!(["action" : action])
        WKInterfaceDevice.current().play(.notification)
    }
    
    func send(action: WKCoreAction) {
        let encodedAction = try! self.encoder.encode(action)
        let msg = ["action": encodedAction]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
        })
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        //let msg = applicationContext["msg"]!
        print(applicationContext)
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        //let msg = userInfo["msg"]!
        print(userInfo)
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        self.session = session
    }
    
    public func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        self.session = session
    }
}
