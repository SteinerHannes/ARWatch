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
        case reciveActionAndError(action: AppCoreAction, position: Int)
        case reciveError(WKSessionError)
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
                    guard let action = message["action"] else {
                        let error = message["error"] as! WKSessionError
                        subscriber.send(.reciveError(error))
                        return
                    }
                    if let position = message["number"] {
                        subscriber.send(.reciveActionAndError(action: action as! AppCoreAction,
                                                              position: position as! Int))
                    } else {
                        subscriber.send(.reciveAction(action as! AppCoreAction))
                    }
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
    
    static let mock = WKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { _ in return AnyCancellable { } }
    },
        send: { _ in .fireAndForget { } }
    )
}

public enum WKSessionError: Error, Equatable {
    public static func == (lhs: WKSessionError, rhs: WKSessionError) -> Bool {
        switch (lhs, rhs) {
            case let (error(lhsError), error(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (isReachable(lhsBool), isReachable(rhsBool)):
                return lhsBool == rhsBool
            case (disconnected, disconnected):
                return true
            case let (isPaired(lhsBool), isPaired(rhsBool)):
                return lhsBool == rhsBool
            default:
                return false
        }
    }
    
    case error(Error)
    case isReachable(Bool)
    case disconnected
    case isPaired(Bool)
}

public final class WKSessionManager: NSObject, WCSessionDelegate {
    
    var counter: AtomicInteger = AtomicInteger()
    
    var session: WCSession?
    
    var handler: (([String : Any]) -> Void)
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    init(messageHandler: @escaping ([String : Any]) -> Void ){
        handler = messageHandler
        
        super.init()
        
        session = WCSession.default
        session!.delegate = self
        session!.activate()
    }
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
            case .notActivated:
                handler(["error": WKSessionError.error(error!)])
                print("notActivated")
            case .inactive:
                print("inactive")
            case .activated:
                print("activated")
            @unknown default:
                print("default")
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let encodedAction = message["action"]! as! Data
        let number = message["number"]! as! Int
        let action = try! self.decoder.decode(AppCoreAction.self, from: encodedAction)
        let counter = self.counter.value
        debugPrint("Paketnummer: \(number), Counter: \(counter)")
        if number == counter + 1 {
            self.counter.increment()
            handler(["action" : action])
        } else {
            let difference = counter - number + 1
            self.counter.increment()
            handler(["action": action, "number": difference])
            WKInterfaceDevice.current().play(.failure)
        }
        WKInterfaceDevice.current().play(.notification)
    }
    
    func send(action: WKCoreAction) {
        if !(session?.isReachable ?? false) {
            handler(["error": WKSessionError.isReachable(false)])
            return
        }
        let encodedAction = try! self.encoder.encode(action)
        let msg = ["action": encodedAction, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
                self.handler(["error": WKSessionError.error(error)])
        })
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        switch session.isReachable {
            case true:
                handler(["error": WKSessionError.isReachable(true)])
            case false:
                counter.reset()
                handler(["error": WKSessionError.isReachable(false)])
        }
    }
}
