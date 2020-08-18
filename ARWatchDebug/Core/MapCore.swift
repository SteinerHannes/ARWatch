//
//  MapCore.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 18.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import ComposableArchitecture
import MapKit

struct MapState: Equatable {
    var mapRegion: MKCoordinateRegion
}

public enum MapAction: Equatable {
    case regionChanges(MKCoordinateRegion)
}

let mapReducer = Reducer<MapState, MapAction, ContentEnvironment> { state, action, environment in
    switch action {
        case let .regionChanges(region):
            state.mapRegion = region
            return environment.sessionClient.send(
                action: .MapVselectedRegionChanged(value: region)
            ).fireAndForget()
    }
}


