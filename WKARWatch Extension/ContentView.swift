//
//  ContentView.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    
    init() {}
    
    init(session: WCSession?) {
        self.session = session
    }
    
    var session: WCSession?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).foregroundColor(.blue)
            Button(action: {
                
            }) {
                Text("Button")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
