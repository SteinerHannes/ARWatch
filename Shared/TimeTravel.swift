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
}

enum TimeTravelAction<Action: Equatable>: Equatable {
    case child(Action)
}

//extension Reducer where State: Equatable, Action: Equatable {
//    func timeTravel() -> Reducer<TimeTravelState<State, Action>, TimeTravelAction<Action>, Environment> {
//        .init { state, action, environment in
//            switch action {
//                case let .child(childAction):
//                    let effect = self(&state.current, childAction, environment)
//                    state.index += 1
//                    if state.history.count > state.index {
//                        state.history.removeSubrange(state.index...)
//                    }
//                    state.history.append((state.current, childAction))
//                    if state.history.count == maxHistoryCount {
//                        state.history.removeFirst(1)
//                        state.index -= 1
//                    }
//                    return effect.map(TimeTravelAction.child)
//            }
//        }
//    }
//}
