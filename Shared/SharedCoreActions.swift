//
//  SharedCoreActions.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import MapKit

public enum AppCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
    case MapVselectedRegionChanged(value: MKCoordinateRegion)
    case AudioStart
    case AudioStop(at: Int)
    case AudioSet(to: Int)
}

extension AppCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case MMselectedCardChanged
        case MapVselectedRegionChanged
        case AudioStart
        case AudioStop
        case AudioSet
    }
    
    enum AppCoreActionError: Error {
        case decoding(String)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Int.self, forKey: .MMselectedCardChanged) {
            self = .MMselectedCardChanged(value: value)
            return
        }
        if let value = try? values.decode(MKCoordinateRegionContainer.self, forKey: .MapVselectedRegionChanged) {
            self = .MapVselectedRegionChanged(value: value.region)
            return
        }
        if ((try? values.decode(Int.self, forKey: .AudioStart)) != nil) {
            self = .AudioStart
            return
        }
        if let value = try? values.decode(Int.self, forKey: .AudioStop) {
            self = .AudioStop(at: value)
            return
        }
        if let value = try? values.decode(Int.self, forKey: .AudioSet) {
            self = .AudioSet(to: value)
            return
        }
        throw AppCoreActionError.decoding("AppCoreAction konnte nicht decoded werden")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .MMselectedCardChanged(value: value):
                try container.encode(value, forKey: .MMselectedCardChanged)
            case let .MapVselectedRegionChanged(value: region):
                try container.encode(MKCoordinateRegionContainer(region: region), forKey: .MapVselectedRegionChanged)
            case .AudioStart:
                try container.encode(1, forKey: .AudioStart)
            case let .AudioStop(at: time):
                try container.encode(time, forKey: .AudioStop)
            case let .AudioSet(to: time):
                try container.encode(time, forKey: .AudioSet)
        }
//        throw AppCoreActionError.decoding("AppCoreAction konnte nicht encoded werden")
    }
}

public enum WKCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
    case MMsetWatchMapView(isActive: Bool)
    case MMsetAudioPlayerView(isActive: Bool)
    case MMsetSettingsView(isActive: Bool)
    case AudioStart
    case AudioStop(at: Int)
    case AudioSet(to: Int)
}

extension WKCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case MMselectedCardChanged
        case MMsetWatchMapView
        case MMsetAudioPlayerView
        case MMsetSettingsView
        case AudioStart
        case AudioStop
        case AudioSet
    }
    
    enum WKCoreActionError: Error {
        case decoding(String)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Int.self, forKey: .MMselectedCardChanged) {
            self = .MMselectedCardChanged(value: value)
            return
        }
        if let value = try? values.decode(Bool.self, forKey: .MMsetWatchMapView) {
            self = .MMsetWatchMapView(isActive: value)
            return
        }
        if let value = try? values.decode(Bool.self, forKey: .MMsetAudioPlayerView) {
            self = .MMsetAudioPlayerView(isActive: value)
            return
        }
        if let value = try? values.decode(Bool.self, forKey: .MMsetSettingsView) {
            self = .MMsetSettingsView(isActive: value)
            return
        }
        if ((try? values.decode(Int.self, forKey: .AudioStart)) != nil) {
            self = .AudioStart
            return
        }
        if let value = try? values.decode(Int.self, forKey: .AudioStop) {
            self = .AudioStop(at: value)
            return
        }
        if let value = try? values.decode(Int.self, forKey: .AudioSet) {
            self = .AudioSet(to: value)
            return
        }
        throw WKCoreActionError.decoding("WKCoreAction konnte nicht decoded werden")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            switch self {
                case let .MMselectedCardChanged(value: value):
                    try container.encode(value, forKey: .MMselectedCardChanged)
                case let .MMsetWatchMapView(isActive: activ):
                    try container.encode(activ, forKey: .MMsetWatchMapView)
                case let .MMsetAudioPlayerView(isActive: activ):
                    try container.encode(activ, forKey: .MMsetAudioPlayerView)
                case let .MMsetSettingsView(isActive: activ):
                    try container.encode(activ, forKey: .MMsetSettingsView)
                case .AudioStart:
                    try container.encode(1, forKey: .AudioStart)
                case let .AudioStop(at: time):
                    try container.encode(time, forKey: .AudioStop)
                case let .AudioSet(to: time):
                    try container.encode(time, forKey: .AudioSet)
            }
        } catch let error as EncodingError {
            print(error.localizedDescription)
            throw WKCoreActionError.decoding("WKCoreAction konnte nicht encoded werden")
        }
    }
}

public enum MainMenuView: Int, CaseIterable {
    case map = 0
    case player = 1
    case settings = 2
    
    var titel: String {
        switch self {
            case .map:
                return "Map"
            case .player:
                return "Audio Player"
            case .settings:
                return "Settings"
        }
    }
}

extension MainMenuView: Codable {
    private enum CodingKeys: String, CodingKey {
        case rawValue
        
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
            case 0:
                self = .map
            case 1:
                self = .player
            case 2:
                self = .settings
            default:
                throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            switch self {
                case .map:
                    try container.encode(0, forKey: .rawValue)
                case .player:
                    try container.encode(1, forKey: .rawValue)
                case .settings:
                    try container.encode(2, forKey: .rawValue)
            }
        }
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.span.latitudeDelta == rhs.span.latitudeDelta
            && lhs.span.longitudeDelta == rhs.span.longitudeDelta
            && lhs.center.latitude == rhs.center.latitude
            && lhs.center.longitude == rhs.center.longitude
    }
}


