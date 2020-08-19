//
//  TimeTravel.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI


public let maxHistoryCount: Int = 9

struct TimeTravelState<ChildState: Equatable, Action: Equatable>: Equatable {
    static func == (lhs: TimeTravelState<ChildState, Action>, rhs: TimeTravelState<ChildState, Action>) -> Bool {
        lhs.current == rhs.current
    }
    
    var history: [(ChildState, Action)] = []
    var current: ChildState
    var index: Int = -1
    var isReachable: Bool = true
}

enum TimeTravelAction<Action: Equatable>: Equatable {
    case child(Action)
}
