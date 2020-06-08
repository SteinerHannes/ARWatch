//
//  SharedCoreActions.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

enum AppCoreAction: Equatable {
    case reciveTest(String)
}

extension AppCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case reciveTest
    }
    
    enum AppCoreActionError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .reciveTest) {
            self = .reciveTest(value)
            return
        }
        throw AppCoreActionError.decoding("AppCoreAction konnte nicht decoded werden")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .reciveTest(text):
                try container.encode(text, forKey: .reciveTest)
        }
//        throw AppCoreActionError.decoding("AppCoreAction konnte nicht encoded werden")
    }
}

enum WKCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
}

extension WKCoreAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case MMselectedCardChanged
    }
    
    enum WKCoreActionError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Int.self, forKey: .MMselectedCardChanged) {
            self = .MMselectedCardChanged(value: value)
            return
        }
        throw WKCoreActionError.decoding("WKCoreAction konnte nicht decoded werden")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .MMselectedCardChanged(value: value):
                try container.encode(value, forKey: .MMselectedCardChanged)
        }
//        throw WKCoreActionError.decoding("WKCoreAction konnte nicht encoded werden")
    }
}
