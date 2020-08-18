//
//  SharedCoreActions.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public enum AppCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
}

extension AppCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case MMselectedCardChanged
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
        
        throw AppCoreActionError.decoding("AppCoreAction konnte nicht decoded werden")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .MMselectedCardChanged(value: value):
                try container.encode(value, forKey: .MMselectedCardChanged)
        }
//        throw AppCoreActionError.decoding("AppCoreAction konnte nicht encoded werden")
    }
}

public enum WKCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
    case MMsetWatchMapView(isActive: Bool)
    case MMsetAudioPlayerView(isActive: Bool)
    case MMsetSettingsView(isActive: Bool)
}

extension WKCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case MMselectedCardChanged
        case MMsetWatchMapView
        case MMsetAudioPlayerView
        case MMsetSettingsView
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
