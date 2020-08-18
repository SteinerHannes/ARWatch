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
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceMap, context: WKInterfaceObjectRepresentableContext<WatchMapView>) {
        let coordinate = CLLocationCoordinate2D(
            latitude: 12.9716, longitude: 77.5946)
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        wkInterfaceObject.setRegion(region)
    }

    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<WatchMapView>) -> WKInterfaceMap {
        return WKInterfaceMap()
    }
}

//struct WatchMapView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView()
            .edgesIgnoringSafeArea(.all)
    }
}
