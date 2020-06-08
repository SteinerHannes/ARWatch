//
//  SharedCoreActions.swift
//  ARWatch
//
//  Created by Hannes Steiner on 08.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

enum AppCoreAction: Equatable {
    case reciveTest
}

enum WKCoreAction: Equatable {
    case MMselectedCardChanged(value: Int)
}
