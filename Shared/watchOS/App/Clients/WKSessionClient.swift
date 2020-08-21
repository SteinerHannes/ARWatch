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

#if os(watchOS)

public struct WKSessionClient {
    enum Action: Equatable {
        case reciveAction(AppCoreAction)
        case reciveActionAndError(action: AppCoreAction, position: Int)
        case reciveError(WKSessionError)
        case reciveState(MainMenuState)
    }
    
    private var create: () -> Effect<Action, Never>
    private var send: (WKCoreAction) -> Effect<Never, Never>
    private var sync: (MainMenuState) -> Effect<Never, Never>
    
    func start() -> Effect<Action, Never> {
        self.create()
    }
    
    func send(action: WKCoreAction) -> Effect<Never, Never> {
        return self.send(action)
    }
    
    func sync(state: MainMenuState) -> Effect<Never, Never> {
        return self.sync(state)
    }
}

public var watchSharedWKSessionManager: WKSessionManager?

extension WKSessionClient {
    static let live = WKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { subscriber in
                if !WCSession.isSupported() {
                    fatalError("WCSession is not supported on this device.")
                }
                let manager = WKSessionManager { (message) in
                    if let state = message["state"] {
                        subscriber.send(.reciveState(state as! MainMenuState))
                        return
                    }
                    guard let action = message["action"] else {
                        let error = message["error"] as! WKSessionError
                        subscriber.send(.reciveError(error))
                        return
                    }
                    if let position = message["number"] {
//                        subscriber.send(.reciveActionAndError(action: action as! AppCoreAction,
//                                                              position: position as! Int))
                        subscriber.send(.reciveAction(action as! AppCoreAction))
                    } else {
                        subscriber.send(.reciveAction(action as! AppCoreAction))
                    }
                }
                watchSharedWKSessionManager = manager
                return AnyCancellable { }
            }
        },
        send: { action in
            .fireAndForget {
                guard let manager = watchSharedWKSessionManager else {
                    fatalError("WKSessionManager noch nicht initialisiert")
                }
                print("action send:", action)
                watchSharedWKSessionManager?.send(action: action)
            }
        },
        sync: { state in
            .fireAndForget {
                guard let manager = watchSharedWKSessionManager else {
                    debugPrint("WKSessionManager noch nicht initialisiert")
                    return
                }
                manager.sync(state: state)
            }
        }
    )
    
    static let mock = WKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { _ in return AnyCancellable { } }
        }, send: { _ in .fireAndForget { }
        }, sync: { _ in .fireAndForget { }
        }
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
        handler(["error": WKSessionError.isReachable(session!.isReachable)])
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
        if let encodedState = message["state"] {
            let newState = MainMenuState.initMainMenuState(from: encodedState  as! Data, decoder: decoder)
            self.counter.increment()
            handler(["state": newState])
            return
        }
        
        guard let encodedAction = message["action"] else {
            return
        }
        let number = message["number"]! as! Int
        let action = try! self.decoder.decode(AppCoreAction.self, from: encodedAction as! Data)
        let counter = self.counter.value
        debugPrint("Paketnummer: \(number), Counter: \(counter)")
        if number == counter + 1 {
            self.counter.increment()
            handler(["action" : action])
            WKInterfaceDevice.current().play(.notification)
        } else {
            let difference = counter - number + 1
            self.counter.increment()
            handler(["action": action, "number": difference])
            WKInterfaceDevice.current().play(.failure)
        }
    }
    
    func send(action: WKCoreAction) {
        if !(session?.isReachable ?? false) {
            counter.reset()
            handler(["error": WKSessionError.isReachable(false)])
            return
        }
        let encodedAction = try! self.encoder.encode(action)
        let counterValue = counter.value
        debugPrint("Paketnummer: \(counterValue + 1), Counter: \(counterValue)")
        let msg = ["action": encodedAction, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
                self.handler(["error": WKSessionError.error(error)])
        })
    }
    
    func sync(state: MainMenuState) {
        if !(session?.isReachable ?? false) {
            counter.reset()
            handler(["error": WKSessionError.isReachable(false)])
            return
        }
        let encodedState = try! self.encoder.encode(state)
        let msg = ["state": encodedState, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil,
            errorHandler: { (error) in
                debugPrint(error)
                self.handler(["error": WKSessionError.error(error)])
        })
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        switch session.isReachable {
            case true:
                counter.reset()
                handler(["error": WKSessionError.isReachable(true)])
            case false:
                counter.reset()
                handler(["error": WKSessionError.isReachable(false)])
        }
    }
}

#endif
