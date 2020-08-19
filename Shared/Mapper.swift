//
//  Mapper.swift
//  ARWatch
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

#if os(watchOS) || os(iOS)

extension MainMenuState {
    public static func initMainMenuState(from contentState: Data, decoder: JSONDecoder) -> MainMenuState {
        let state = try! decoder.decode(ContentState.self, from: contentState)
        return MainMenuState(
            selectedCard: state.selectedView,
            isMapViewVisible: state.visibleView == .map ? true : false,
            isAudioPlayerVisible: state.visibleView == .player ? true : false,
            isSettingsViewVisible: state.visibleView == .settings ? true : false,
            mapState: MainMenuState.MapState(mapRegion: state.mapState.mapRegion)
        )
    }
}

extension ContentState {
    public static func initContentState(from mainMenuState: Data, decoder: JSONDecoder) -> ContentState {
        let state = try! decoder.decode(MainMenuState.self, from: mainMenuState)
        var visibleView: MainMenuView = .map
        if state.isAudioPlayerVisible {
            visibleView = .player
        } else if state.isSettingsViewVisible {
            visibleView = .settings
        }
        return ContentState(
            selectedView: state.selectedCard,
            visibleView: visibleView,
            mapState: MapState(mapRegion: state.mapState.mapRegion))
    }
    
}

extension ContentState: Codable {
    private enum CodingKeys: String, CodingKey {
        case selectedView
        case visibleView
        case mapState
    }
    
    enum ContentStateError: Error {
        case unknown
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedView = try container.decode(MainMenuView.self, forKey: .selectedView)
        visibleView = try container.decode(MainMenuView?.self, forKey: .visibleView)
        mapState = try container.decode(MapState.self, forKey: .mapState)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedView, forKey: .selectedView)
        try container.encode(visibleView, forKey: .visibleView)
        try container.encode(mapState, forKey: .mapState)
    }
}

extension MainMenuState: Codable {
    private enum CodingKeys: String, CodingKey {
        case selectedCard
        case isMapViewVisible
        case isAudioPlayerVisible
        case isSettingsViewVisible
        case mapState
    }
    
    enum ContentStateError: Error {
        case unknown
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedCard = try container.decode(MainMenuView.self, forKey: .selectedCard)
        isMapViewVisible = try container.decode(Bool.self, forKey: .isMapViewVisible)
        isAudioPlayerVisible = try container.decode(Bool.self, forKey: .isAudioPlayerVisible)
        isSettingsViewVisible = try container.decode(Bool.self, forKey: .isSettingsViewVisible)
        mapState = try container.decode(MapState.self, forKey: .mapState)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedCard, forKey: .selectedCard)
        try container.encode(isMapViewVisible, forKey: .isMapViewVisible)
        try container.encode(isAudioPlayerVisible, forKey: .isAudioPlayerVisible)
        try container.encode(isSettingsViewVisible, forKey: .isSettingsViewVisible)
        try container.encode(mapState, forKey: .mapState)
    }
}

extension MainMenuState.MapState : Codable {
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
#endif

//extension ContentState {
//    public static func initContentState(from mainMenuState: MainMenuState) -> ContentState {
//        var content = ContentState()
//
//        return content
//    }
//}

