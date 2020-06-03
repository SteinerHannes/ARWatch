//
//  HostingController.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import WatchConnectivity

class HostingController: WKHostingController<ContentView>, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(session.isReachable)
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    var session : WCSession?
    
    override init() {
        // This method is called when watch view controller is about to be visible to user
        super.init()
        
        session = WCSession.default
        session!.delegate = self
        session!.activate()
        print("HostingController active")
        debugPrint("%@", " Watch App Installed: \(session!.isReachable)")
    }
    
    override var body: ContentView {
        return ContentView()
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    }
}
