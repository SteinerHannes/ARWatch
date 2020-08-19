//
//  Mapper.swift
//  ARWatch
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

#if os(iOS)
#if os(watchOS)


public func initMainMenuState(from ContentState: ContentState) -> MainMenuState {
    return MainMenuState()
}

#endif
#endif
