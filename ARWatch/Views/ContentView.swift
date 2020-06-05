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
        ScrollView(.vertical, showsIndicators: true) {
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
                ForEach(0..<self.messages.count, id: \.self) { index in
                    Text(self.messages[index])
                }
            }.onAppear{
                self.updateMessages()
                self.messagesObservation = self.connectivityHandler.observe(\.messages) { _, _ in
                    OperationQueue.main.addOperation {
                        self.updateMessages()
                    }
                }
            }.onDisappear{
                
            }.frame(width: UIScreen.main.bounds.width)
        }
    }
    
    func updateMessages() {
        self.messages.append(self.connectivityHandler.messages.last ?? "Hello World")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
