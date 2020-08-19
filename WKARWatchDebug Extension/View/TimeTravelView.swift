//
//  TimeTravelView.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct TimeTravelView<Content: View>: View {
    private let timeStore: Store<TimeTravelState<MainMenuState, MainMenuAction>, TimeTravelAction<MainMenuAction>>
    private let content: (Store<MainMenuState, MainMenuAction>) -> Content
    
    init(
        initialState: MainMenuState,
        reducer: Reducer<MainMenuState, MainMenuAction, MainMenuEnvironment>,
        environment: MainMenuEnvironment,
        @ViewBuilder content: @escaping (Store<MainMenuState, MainMenuAction>) -> Content
    ) {
        self.timeStore = Store<TimeTravelState<MainMenuState, MainMenuAction>, TimeTravelAction<MainMenuAction>>.init(
            initialState: TimeTravelState(current: initialState),
            reducer: reducer.timeTravel().debug(),
            environment: environment
        )
        self.content = content
    }
    
    var body: some View {
        self.content(
            self.timeStore.scope(
                state: \TimeTravelState.current,
                action: TimeTravelAction.child
            )
        )
    }
}
