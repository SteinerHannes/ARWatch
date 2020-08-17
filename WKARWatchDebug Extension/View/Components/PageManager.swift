//
//  PageManager.swift
//  WKARWatchDebug Extension
//
//  Created by Hannes Steiner on 17.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI



struct PagerManager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    
    //Set the initial values for the variables
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0
    
    //Set the animation
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .focusable(true)
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
            .digitalCrownRotation(
                Binding.init(
                    get: { Double(self.currentIndex) },
                    set: {
                        if $0.truncatingRemainder(dividingBy: 1) == 0 {
                            self.currentIndex = Int($0)
                        }
                    }
                ),
                from: 0.0,
                through: Double(self.pageCount - 1),
                by: 1.0,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
        }
    }
}
