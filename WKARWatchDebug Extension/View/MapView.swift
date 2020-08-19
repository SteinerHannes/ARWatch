//
//  MapView.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 17.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import MapKit
import ComposableArchitecture
import Combine

struct WatchMapView: WKInterfaceObjectRepresentable {
    var viewStore: ViewStore<MainMenuState.MapState, MainMenuAction.MapAction>
    
    init(store: Store<MainMenuState.MapState, MainMenuAction.MapAction>) {
        self.viewStore = ViewStore(store)
    }
    
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceMap, context: WKInterfaceObjectRepresentableContext<WatchMapView>) {
        wkInterfaceObject.setRegion(self.viewStore.mapRegion)
    }

    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<WatchMapView>) -> WKInterfaceMap {
        let map = WKInterfaceMap()
        return map
    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: WKInterfaceController {
//        var map: WatchMapView
//        var cancellables: Set<AnyCancellable> = []
//
//        init(_ map: WatchMapView) {
//            self.map = map
//        }
//        
//        override func didAppear() {
//            super.didAppear()
//            self.map.viewStore.publisher.sink { state in
//                print(state.mapRegion)
//            }.store(in: &self.cancellables)
//        }
//    }
}

struct WatchMapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView(
            store: Store(
                initialState: MainMenuState.MapState(
                    mapRegion: MKCoordinateRegion(
                        center:  CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
                        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
                    )
                ),
                reducer: watchMapReducer,
                environment: MainMenuEnvironment()
            )
        )
        .edgesIgnoringSafeArea(.all)
    }
}
