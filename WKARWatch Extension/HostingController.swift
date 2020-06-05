//
//  HostingController.swift
//  WKARWatch Extension
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import WatchKit
import SwiftUI

class HostingController: WKHostingController<ContentView> {

    override init() {
        // This method is called when watch view controller is about to be visible to user
        super.init()
    }

    override var body: ContentView {
        return ContentView()
    }
}
