//
//  Mapper.swift
//  ARWatch
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import MapKit

#if os(watchOS) || os(iOS)

extension MainMenuState {
    public static func initMainMenuState(from contentState: Data, decoder: JSONDecoder) -> MainMenuState {
        let state = try! decoder.decode(ContentState.self, from: contentState)
        return MainMenuState(
            selectedCard: state.selectedView,
            isMapViewVisible: state.visibleView == .map ? true : false,
            isAudioPlayerVisible: state.visibleView == .player ? true : false,
            isSettingsViewVisible: state.visibleView == .settings ? true : false,
            mapState: MainMenuState.MapState(mapRegion: state.mapState.mapRegion),
            audioState: state.audioState
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
            mapState: MapState(mapRegion: state.mapState.mapRegion),
            audioState: state.audioState
        )
    }
    
}

extension ContentState: Codable {
    private enum CodingKeys: String, CodingKey {
        case selectedView
        case visibleView
        case mapState
        case audioState
    }
    
    enum ContentStateError: Error {
        case unknown
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedView = try container.decode(MainMenuView.self, forKey: .selectedView)
        visibleView = try container.decode(MainMenuView?.self, forKey: .visibleView)
        mapState = try container.decode(MapState.self, forKey: .mapState)
        audioState = try container.decode(AudioState.self, forKey: .audioState)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedView, forKey: .selectedView)
        try container.encode(visibleView, forKey: .visibleView)
        try container.encode(mapState, forKey: .mapState)
        try container.encode(audioState, forKey: .audioState)
    }
}

extension MainMenuState: Codable {
    private enum CodingKeys: String, CodingKey {
        case selectedCard
        case isMapViewVisible
        case isAudioPlayerVisible
        case isSettingsViewVisible
        case mapState
        case audioState
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
        audioState = try container.decode(AudioState.self, forKey: .audioState)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedCard, forKey: .selectedCard)
        try container.encode(isMapViewVisible, forKey: .isMapViewVisible)
        try container.encode(isAudioPlayerVisible, forKey: .isAudioPlayerVisible)
        try container.encode(isSettingsViewVisible, forKey: .isSettingsViewVisible)
        try container.encode(mapState, forKey: .mapState)
        try container.encode(audioState, forKey: .audioState)
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

extension Track: Codable {
    private enum CodingKeys: String, CodingKey {
        case titel
        case artist
        case album
        case length
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titel = try container.decode(String.self, forKey: .titel)
        artist = try container.decode(String.self, forKey: .artist)
        album = try container.decode(String.self, forKey: .album)
        length = try container.decode(Int.self, forKey: .length)
    }
    
    public func encode(to encoder: Encoder) throws {
        var conteiner = encoder.container(keyedBy: CodingKeys.self)
        try conteiner.encode(titel, forKey: .titel)
        try conteiner.encode(artist, forKey: .artist)
        try conteiner.encode(album, forKey: .album)
        try conteiner.encode(length, forKey: .length)
    }
}

extension AudioState: Codable {
    private enum CodingKeys: String, CodingKey {
        case currentTrack
        case time
        case isPlaying
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentTrack = try container.decode(Track.self, forKey: .currentTrack)
        time = try container.decode(Int.self, forKey: .time)
        isPlaying = try container.decode(Bool.self, forKey: .isPlaying)
    }
    
    public func encode(to encoder: Encoder) throws {
        var conteiner = encoder.container(keyedBy: CodingKeys.self)
        try conteiner.encode(currentTrack, forKey: .currentTrack)
        try conteiner.encode(time, forKey: .time)
        try conteiner.encode(isPlaying, forKey: .isPlaying)
    }
}

class MKCoordinateRegionContainer: Codable {
    let region: MKCoordinateRegion
    
    init(region: MKCoordinateRegion) {
        self.region = region
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spanLat = try container.decode(CLLocationDegrees.self, forKey: .spanLat)
        let spanLong = try container.decode(CLLocationDegrees.self, forKey: .spanLong)
        let centerLat = try container.decode(CLLocationDegrees.self, forKey: .centerLat)
        let centerLong = try container.decode(CLLocationDegrees.self, forKey: .centerLong)
        region = .init(
            center: .init(latitude: centerLat, longitude: centerLong),
            span: .init(latitudeDelta: spanLat, longitudeDelta: spanLong))
    }
    
    func encode(to encoder: Encoder) throws {
        var conntainer = encoder.container(keyedBy: CodingKeys.self)
        try conntainer.encode(region.span.latitudeDelta, forKey: .spanLat)
        try conntainer.encode(region.span.longitudeDelta, forKey: .spanLong)
        try conntainer.encode(region.center.latitude, forKey: .centerLat)
        try conntainer.encode(region.center.longitude, forKey: .centerLong)
    }
    
    enum CodingKeys: String, CodingKey {
        case spanLat
        case spanLong
        case centerLat
        case centerLong
    }
}
#endif
