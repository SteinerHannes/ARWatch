//
//  MapView.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 17.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import MapKit

struct WatchMapView: WKInterfaceObjectRepresentable {
    
    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<WatchMapView>) -> WKInterfaceMap {
        return WKInterfaceMap()
    }
    
    func updateWKInterfaceObject(_ view: WKInterfaceMap, context: WKInterfaceObjectRepresentableContext<WatchMapView>) {
        let coordinate = CLLocationCoordinate2D(
            latitude: 12.9716, longitude: 77.5946)
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView()
            .edgesIgnoringSafeArea(.all)
    }
}
