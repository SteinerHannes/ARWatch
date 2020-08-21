//
//  SettingsView.swift
//  ARWatchDebug
//
//  Created by Hannes Steiner on 19.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: Store<SettingsState,SettingsAction>
    
    init(store: Store<SettingsState,SettingsAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Text("Hello World!")
                TextField("Name", text: viewStore.binding(
                    get: { $0.name },
                    send: SettingsAction.nameChanged(to:)
                    )
                )
            }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
