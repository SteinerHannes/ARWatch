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
    
//    @ObservedObject var model = WCSessionModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink(destination: ListView()) {
                    Text("ListView")
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
