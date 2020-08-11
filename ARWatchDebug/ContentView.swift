//
//  ContentView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 08.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    let store: Store<ContentState, ContentAction>
    
    @ObservedObject var viewStore: ViewStore<ContentState, ContentAction>
    
    init(_ store: Store<ContentState, ContentAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var name: String {
        if self.viewStore.state.value == 0 {
            return "Karten"
        }
        if self.viewStore.state.value == 1 {
            return "Audioplayer"
        }
        if self.viewStore.state.value == 2 {
            return "Einstellungen"
        }
        return "Fehler"
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                VStack(alignment: .center, spacing: 20) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(self.name)
                        }.frame(width: UIScreen.main.bounds.width)
                    }
                    .navigationBarTitle("ARWatch", displayMode: .large)
                    .onAppear{
                        self.viewStore.send(.onAppear)
                    }
                    Button(action: {
                        self.viewStore.send(.buttonTapped)
                    }) {
                        Text("Hello World").font(.largeTitle)
                    }
                    Spacer()
                }
            }
            .onAppear {
                self.viewStore.send(.onAppear)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTravelView(
            initialState: ContentState(),
            reducer: contentReducer,
            environment: ARWatchDebug.ContentEnvironment()
        ) { store in
            ContentView(store)
        }
    }
}

struct ContentState: Equatable {
    var value: Int = 0
    var name: String = "Karten"
}

enum ContentAction: Equatable {
    case onAppear
    case sessionClient(Result<AppWKSessionClient.Action, Never>)
    case setNavigationARView(isPresented: Bool)
    case reciveAction(WKCoreAction)
    case buttonTapped
}

public struct ContentEnvironment {
    var sessionClient: AppWKSessionClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}

let contentReducer: Reducer<ContentState, ContentAction, ContentEnvironment> =
    .combine(
        Reducer { state, action, environment in
            switch action {
                case .onAppear:
                    return environment.sessionClient.start()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map(ContentAction.sessionClient)
                case let .setNavigationARView(isPresented: isPresented):
                    print(isPresented)
                    return .none
                case let .sessionClient(.success(recivedAction)):
                    switch recivedAction {
                        case let .reciveAction(action):
                            return Effect(value: .reciveAction(action))
                }
                case let .reciveAction(action):
                    switch action {
                        case let .MMselectedCardChanged(value: value):
                            print("GET MMselectedCardChanged: ", value)
                            state.value = value
                            switch value {
                                case 0:
                                    state.name = "Karten"
                                case 1:
                                    state.name = "Audio Player"
                                case 2:
                                    state.name = "Einstellungen"
                                default:
                                    state.name = "Fehler"
                            }
                            return .none
                }
                case .buttonTapped:
                    return environment.sessionClient.send(
                        action: AppCoreAction.buttonTapped
                    ).fireAndForget()
            }
        }.debug()
)
