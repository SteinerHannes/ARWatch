//
//  MapCore.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 18.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

#if os(iOS)


import Foundation
import ComposableArchitecture
import MapKit

struct MapState: Equatable {
    var mapRegion: MKCoordinateRegion
}

extension MapState: Codable {
    private enum CodingKeys: String, CodingKey {
        case mapRegion
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mapRegionContainer = try container.decode(MKCoordinateRegionContainer.self, forKey: .mapRegion)
        mapRegion = mapRegionContainer.region
    }
    
    public func encode(to encoder: Encoder) throws {
        var conteiner = encoder.container(keyedBy: CodingKeys.self)
        try conteiner.encode(MKCoordinateRegionContainer(region: mapRegion), forKey: .mapRegion)
    }
    
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

#endif


