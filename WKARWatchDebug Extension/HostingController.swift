//
//  HostingController.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 11.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<TimeTravelView<ContentView>> {
    override var body: TimeTravelView<ContentView> {
        return TimeTravelView(
            initialState: MainMenuState(),
            reducer: mainMenuReducer,
            environment: MainMenuEnvironment()
        ) { store in
            ContentView(store)
        }
    }
}
