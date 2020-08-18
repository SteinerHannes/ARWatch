//
//  MapView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 17.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import MapKit
import ComposableArchitecture
import Combine

struct MapView: UIViewRepresentable {
    let viewStore: ViewStore<MapState, MapAction>
    var cancellables: Set<AnyCancellable> = []
    
    init(store: Store<MapState, MapAction>) {
        self.viewStore = ViewStore(store)
    }
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(viewStore.mapRegion, animated: true)
    }
    
    typealias Context = UIViewRepresentableContext<Self>
    
    func makeCoordinator() -> MapViewCoordinator{
        MapViewCoordinator(self)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(store: Store(
                initialState: MapState(
                    mapRegion: MKCoordinateRegion(
                        center:  CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
                        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
                    )
                ),
                reducer: mapReducer, environment: ContentEnvironment()
            )
        )
        .edgesIgnoringSafeArea(.all)
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapViewController: MapView
    
    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapViewController.viewStore.send(.regionChanges(mapView.region))
    }
}
