//
//  example.swift
//  ARWatch
//
//  Created by Hannes Steiner on 07.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

/*
import SwiftUI
import ComposableArchitecture

enum LoginAction: Equatable {
    case benutzerNameGeaendert(name: String)
    case passwortGeaendert(passwort: String)
    case loginButtonGedrueckt
    case anmeldeClientAntwort(Result<Bool, Error>)
}

struct LoginState: Equatable {
    var benutzername: String = ""
    var passwort: String = ""
}


public struct LoginEnvironment {
    var anmeldeClient: AnmeldeClient = AnmeldeClient()
}

let loginKomponetenReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
        case .benutzerNameGeaendert(name: let name):
            state.benutzername = name
            return .none
        case .passwortGeaendert(passwort: let passwort):
            state.passwort = passwort
            return .none
        case .loginButtonGedrueckt:
            return environment
                .anmeldeClient
                .login(name: state.benutzername, passwort: state.passwort)
                .catchEffect(LoginViewAction.anmeldeClientAntwort)
        case let .anmeldeClientAntwort(result):
            switch result {
                case .success(true):
                // Anmeldung erfolgreich
                case .failure(let error):
                // Fehler aufgetreten
            }
            return .none
    }
}

struct LoginView: View {
    let store 
    
    var body: some View {
        
    }
}
*/
