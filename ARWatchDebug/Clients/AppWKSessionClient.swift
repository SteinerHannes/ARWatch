//
//  AppWKSessionClient.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import WatchConnectivity
import ComposableArchitecture
import Combine


public struct AppWKSessionClient {
    public enum Action: Equatable {
        case reciveAction(WKCoreAction)
        case reciveActionAndError(action: WKCoreAction, position: Int)
    }
    
    private var create: () -> Effect<Action, Never>
    private var send: (AppCoreAction) -> Effect<Never, Never>
    
    func start() -> Effect<Action, Never> {
        self.create()
    }
    
    func send(action: AppCoreAction) -> Effect<Never, Never> {
        return self.send(action)
    }
}

public var sharedWKSessionManager: AppWKSessionManager?

extension AppWKSessionClient {
    static let live = AppWKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { subscriber in
                let manager = AppWKSessionManager { (message) in
                    let action = message["action"]!
                    if let position = message["number"] {
                        subscriber.send(.reciveActionAndError(action: action as! WKCoreAction,
                                                              position: position as! Int))
                    } else {
                        subscriber.send(.reciveAction(action as! WKCoreAction))
                    }
                }
                sharedWKSessionManager = manager
                return AnyCancellable { }
            }
        },
        send: { action in
            .fireAndForget {
                guard let manager = sharedWKSessionManager else {
                    debugPrint("AppWKSessionManager noch nicht initialisiert")
                    return
                }
                manager.send(action: action)
            }
        }
    )
}

public final class AppWKSessionManager: NSObject, WCSessionDelegate {
    
    var counter: AtomicInteger = AtomicInteger()
    
    var session: WCSession?
    
    var handler: ([String : Any]) -> Void
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
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
        let encodedAction = message["action"]! as! Data
        let number = message["number"]! as! Int
        let action = try! self.decoder.decode(WKCoreAction.self, from: encodedAction)
        let counter = self.counter.value
        debugPrint("Paketnummer: \(number), Counter: \(counter)")
        if number == counter + 1 {
            self.counter.increment()
            handler(["action": action])
        } else {
            let difference = counter - number + 1
            self.counter.increment()
            handler(["action": action, "number": difference])
        }
    }
    
    func send(action: AppCoreAction) {
        let encodedAction = try! self.encoder.encode(action)
        let msg = ["action": encodedAction, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
        })
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("sessionDidBecomeInactive: \(session)")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("sessionDidDeactivate: \(session)")
    }
    
    public func sessionWatchStateDidChange(_ session: WCSession) {
        debugPrint("sessionWatchStateDidChange: \(session)")
        
        debugPrint("Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        self.session = session
    }
}
