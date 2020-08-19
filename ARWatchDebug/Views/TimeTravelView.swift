//
//  TimeTravelView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct TimeTravelView<Content: View>: View {
    private let timeStore: Store<TimeTravelState<ContentState, ContentAction>, TimeTravelAction<ContentAction>>
    private let content: (Store<ContentState, ContentAction>) -> Content
    
    init(
        initialState: ContentState,
        reducer: Reducer<ContentState, ContentAction, ContentEnvironment>,
        environment: ContentEnvironment,
        @ViewBuilder content: @escaping (Store<ContentState, ContentAction>) -> Content
    ) {
        self.timeStore = Store<TimeTravelState<ContentState, ContentAction>, TimeTravelAction<ContentAction>>.init(
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
