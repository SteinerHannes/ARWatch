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

struct TimeTravelState<ChildState: Equatable>: Equatable {
    var history: [ChildState] = []
    var current: ChildState
    var index: Int = -1
}

enum TimeTravelAction<Action: Equatable>: Equatable {
    case child(Action)
    case changeIndex(Double)
}

extension Reducer where State: Equatable, Action: Equatable {
    func timeTravel() -> Reducer<TimeTravelState<State>, TimeTravelAction<Action>, Environment> {
        .init { state, action, environment in
            switch action {
                case let .child(childAction):
                    let effect = self(&state.current, childAction, environment)
                    state.index += 1
                    if state.history.count > state.index {
                        state.history.removeSubrange(state.index...)
                    }
                    state.history.append(state.current)
                    return effect.map(TimeTravelAction.child)
                case let .changeIndex(index):
                    state.index = Int(index)
                    state.current = state.history[state.index]
                    return .none
            }
        }
    }
}

struct TimeTravelView<State: Equatable, Action: Equatable, Envitonment, Content: View>: View {
    private let store: Store<TimeTravelState<State>, TimeTravelAction<Action>>
    private let content: (Store<State, Action>) -> Content
    
    init(
        initialState: State,
        reducer: Reducer<State, Action, Envitonment>,
        environment: Envitonment,
        @ViewBuilder content: @escaping (Store<State, Action>) -> Content
    ) {
        self.store = .init(
            initialState: TimeTravelState(current: initialState),
            reducer: reducer.timeTravel(),
            environment: environment
        )
        self.content = content
    }
    
    var body: some View {
        self.content(
            self.store.scope(
                state: \TimeTravelState.current,
                action: TimeTravelAction.child
            )
        )
    }
    
}
