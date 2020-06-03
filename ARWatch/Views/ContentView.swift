//
//  ContentView.swift
//  ARWatch
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var messages: [String] = []
    
    var connectivityHandler: ConnectivityHandler!
    @State var counter = 0
    @State var messagesObservation: NSKeyValueObservation?
    
    init() {
        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                self.counter += 1
                self.connectivityHandler.session.sendMessage(["msg": "Message \(self.counter)"], replyHandler: nil) { error in
                    debugPrint("Error sending message: \(error)")
                }
            }) {
                Text("Send message")
            }
            Button(action: {
                self.counter += 1
                try! self.connectivityHandler.session.updateApplicationContext(["msg": "Message \(self.counter)"])
            }) {
                Text("Update App Context")
            }
            Button(action: {
                self.counter += 1
                self.connectivityHandler.session.transferUserInfo(["msg": "Message \(self.counter)"])
            }) {
                Text("Transfer User Info")
            }
        }.onAppear{
            self.updateMessages()
            self.messagesObservation = self.connectivityHandler.observe(\.messages) { _, _ in
                OperationQueue.main.addOperation {
                    self.updateMessages()
                }
            }
        }.onDisappear{
            
        }
    }
    
    func updateMessages() {
        self.messages.append(self.connectivityHandler.messages.joined(separator: "\n"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
