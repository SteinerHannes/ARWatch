//
//  simple_example.swift
//
//  Created by Hannes Steiner on 12.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
/*
// Der State der Anwendung
struct AppState {
    // Eine Variable für Ganzzahlen
    var zahl: Int = 0
}

// Auflistung aller Actions, jedoch ohne Geschaeftslogik
enum ActionType {
    case inkrementieren
    case dekrementieren
    case multiplizieren(Int)
}

// Der Reducer nimmt Actions entgegen und
// wodurch er Aenderungen am State ausloest
class Reducer: ObservableObject {
    // Diese Funktion updated den State,
    // abhängig von der mitgelieferten Action und dem State.
    // Hier steht die Geschaeftslogik der Actions.
    func update(state: inout AppState, action: ActionType) {
        switch action {
            // Variable 'zahl' wird mit 1 addiert
            case .inkrementieren:
                state.zahl += 1
            // Variable 'zahl' wird mit 1 subtrahiert
            case .dekrementieren
                state.zahl -= 1
            // Varibale 'zahl' wird mit dem mitgegebenen Faktor multipliziert
            case .multiplizieren(let faktor)
                state.zahl *= faktor
        }
    }
}

// Geruest zum Verwalten des States
final class Store: ObservableObject {
    // Ein Store benötigt einen State und einen Reducer
    init(initialState: AppState, reducer: Reducer) {
        self.state = initialState
        self.reducer = reducer
    }
    
    // Der State ist von aussen lesbar.
    // Aenderungen muessen ueber den Reducer gemacht werden.
    // @Published bedeutet, dass andere z.B. Views ueber Aenderungen
    // benachrichtigt werden
    @Published private(set) var state: AppState
    
    // Der Reducer ist während der Laufzeit nicht manupulierbar
    private let reducer: Reducer
    
    // Ueber diese Funktion koennen Aenderungen ausgeloest werden.
    // Dazu muss die jeweilige Action mitgeliefert werden
    func erledigen(actionType: ActionType) {
        self.reducer.update(state: &state, action: actionType)
    }
}

// Beispielhafter Programmablauf:
// Store mit State und Reducer wird erstellt
let store = Store(initialState: AppState(), reducer: Reducer())
// Actions werden an den Store gesendet:
store.erledigen(actionType: .inkrementieren)    // zahl = 1
store.erledigen(actionType: .multiplizieren(2)) // zahl = 2
store.erledigen(actionType: .dekrementieren)    // zahl = 1
*/
