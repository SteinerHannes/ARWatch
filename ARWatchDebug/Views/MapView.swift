//
//  MapView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 17.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(
            latitude: 12.9716, longitude: 77.5946)
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
    }
    
    typealias Context = UIViewRepresentableContext<Self>
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .edgesIgnoringSafeArea(.all)
    }
}
