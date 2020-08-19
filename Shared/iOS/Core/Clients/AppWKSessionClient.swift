//
//  AppWKSessionClient.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

#if os(iOS)

import SwiftUI
import WatchConnectivity
import ComposableArchitecture
import Combine

public struct AppWKSessionClient {
    public enum Action: Equatable {
        case reciveAction(WKCoreAction)
        case reciveActionAndError(action: WKCoreAction, position: Int)
        case reciveError(AppWKSessionError)
    }
    
    private var create: () -> Effect<Action, Never>
    private var send: (AppCoreAction) -> Effect<Never, Never>
    private var sync: (ContentState) -> Effect<Never, Never>
    
    func start() -> Effect<Action, Never> {
        self.create()
    }
    
    func send(action: AppCoreAction) -> Effect<Never, Never> {
        return self.send(action)
    }
    
    func sync(state: ContentState) -> Effect<Never, Never> {
        return self.sync(state)
    }
}

public var sharedWKSessionManager: AppWKSessionManager?

extension AppWKSessionClient {
    public static let live = AppWKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { subscriber in
                if !WCSession.isSupported() {
                    fatalError("WCSession is not supported on this device.")
                }
                let manager = AppWKSessionManager { (message) in
                    guard let action = message["action"] else {
                        let error = message["error"] as! AppWKSessionError
                        subscriber.send(.reciveError(error))
                        return
                    }
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
        },
        sync: { state in
            .fireAndForget {
                guard let manager = sharedWKSessionManager else {
                    debugPrint("AppWKSessionManager noch nicht initialisiert")
                    return
                }
                manager.sync(state: state)
            }
        }
    )
    
    public static let mock = AppWKSessionClient(
        create: { () -> Effect<Action, Never> in
            .run { _ in return AnyCancellable { } }
        }, send: { _ in .fireAndForget { }
        }, sync: { _ in .fireAndForget { }
        }
    )
}

public enum AppWKSessionError: Error, Equatable {
    public static func == (lhs: AppWKSessionError, rhs: AppWKSessionError) -> Bool {
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
    }
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
            case .notActivated:
                handler(["error": AppWKSessionError.error(error!)])
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
        if !(session?.isReachable ?? false) {
            counter.reset()
            handler(["error": AppWKSessionError.isReachable(false)])
            return
        }
        let encodedAction = try! self.encoder.encode(action)
        let msg = ["action": encodedAction, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil, //(([String: Any]) -> Void)?
            errorHandler: { (error) in
                debugPrint(error)
                self.handler(["error": AppWKSessionError.error(error)])
        })
    }
    
    func sync(state: ContentState) {
        if !(session?.isReachable ?? false) {
            counter.reset()
            handler(["error": AppWKSessionError.isReachable(false)])
            return
        }
        let encodedState = try! self.encoder.encode(state)
        let msg = ["state": encodedState, "number": counter.incrementAndGet()] as [String : Any]
        session?.sendMessage(
            msg,
            replyHandler: nil,
            errorHandler: { (error) in
                debugPrint(error)
                self.handler(["error": AppWKSessionError.error(error)])
        })
    }
    
    // The session calls this method when it detects that the user has switched to a different Apple Watch.
    public func sessionDidBecomeInactive(_ session: WCSession) {
        handler(["error": AppWKSessionError.isPaired(false)])
        debugPrint("sessionDidBecomeInactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        handler(["error": AppWKSessionError.isPaired(false)])
        debugPrint("sessionDidDeactivate")
    }
    
    public func sessionWatchStateDidChange(_ session: WCSession) {
        switch session.isPaired {
            case true:
                handler(["error": AppWKSessionError.isPaired(true)])
            case false:
                counter.reset()
                handler(["error": AppWKSessionError.isPaired(false)])
        }
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        switch session.isReachable {
            case true:
                handler(["error": AppWKSessionError.isReachable(true)])
            case false:
                counter.reset()
                handler(["error": AppWKSessionError.isReachable(false)])
        }
    }
}

#endif
