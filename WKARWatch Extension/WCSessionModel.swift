//
//  WCSessionModel.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 05.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
import WatchConnectivity

class WCSessionModel: NSObject, WCSessionDelegate, ObservableObject {
    
    
    @Published var messages: [String] = []
    
    @Published var counter: Int = 0
    
    var session : WCSession?
    
    override init(){
        super.init()
        
        session = WCSession.default
        session!.delegate = self
        session!.activate()
        print("HostingController active")
        debugPrint("%@", " Watch App Installed: \(session!.isReachable)")
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let msg = message["msg"]!
        OperationQueue.main.addOperation {
            self.messages.append("Message \(msg)")
        }
        WKInterfaceDevice.current().play(.notification)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let msg = applicationContext["msg"]!
        OperationQueue.main.addOperation {
            self.messages.append("AppContext \(msg)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        let msg = userInfo["msg"]!
        OperationQueue.main.addOperation {
            self.messages.append("UserInfo \(msg)")
        }
    }
}
