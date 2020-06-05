//
//  ContentView.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var model = WCSessionModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink(destination: ListView()) {
                    Text("ListView")
                }
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Button(action: {
                    self.model.session?.sendMessage(
                        ["request": "date"],
                        replyHandler: { response in
                            self.model.messages.append("Reply: \(response)")
                    }, errorHandler: { error in
                        print("Error sending message: %@", error)
                    })
                }) {
                    Text("Request Info")
                }
                Button(action: {
                    self.model.counter += 1
                    self.model.session?.sendMessage(
                        ["msg": "Message \(self.model.counter)"]
                        , replyHandler: nil
                    ) { error in
                        debugPrint("Error sending message: \(error)")
                    }
                }) {
                    Text("Send Message")
                }
                Button(action: {
                    self.model.counter += 1
                    try! self.model.session?.updateApplicationContext(["msg": "Message \(self.model.counter)"])
                }) {
                    Text("Update App Context")
                }
                Button(action: {
                    self.model.counter += 1
                    self.model.session?.transferUserInfo(["msg": "Message \(self.model.counter)"])
                }) {
                    Text("Transfer User Info")
                }
                ForEach(0..<self.model.messages.count, id: \.self) { index in
                    Text(self.model.messages[index])
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
