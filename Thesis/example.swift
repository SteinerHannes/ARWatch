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

struct LoginState: Equatable {
    var email: String = ""
    var passwort: String = ""
    var fehlerNachricht: String?
}

enum LoginAction: Equatable {
    case loginButtonGedrueckt
    case emailGeaendert(adresse: String)
    case passwortGeaendert(passwort: String)
    case anmeldeClientAntwort(Result<String, Error>)
    case warnhinweisVerwerfen
}

public struct LoginEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var anmeldung: (adresse: String, passwort: String) -> Effect<String, Error>
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment>
{ state, action, environment in
    switch action {
        case .loginButtonGedrueckt:
            return environment
                .anmeldung(adresse: state.email, passwort: state.passwort)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(LoginViewAction.anmeldeClientAntwort)
        case .emailGeaendert(adresse: let email):
            state.email = email
            return .none
        case .passwortGeaendert(passwort: let passwort):
            state.passwort = passwort
            return .none
        case let .anmeldeClientAntwort(result):
            switch result {
                case .success(let benutzerName):
                // Anmeldung erfolgreich
                case .failure(let error):
                    state.fehlerNachricht = error.beschreibung
            }
            return .none
        case .alertVerwerfen:
            state.fehlerNachricht = nil
            return .none
    }
}

struct LoginView: View {
    let store: Store<LoginState, LoginAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField("E-Mail"
                    text: self.viewStore.binding(
                        get: { $0.email },
                        send: LoginAction.emailGeaendert(adresse:)
                    )
                )
                TextField("Passwort"
                    text: self.viewStore.binding(
                        get: { $0.passwort },
                        send: LoginAction.passwortGeaendert(passwort:)
                    )
                )
                Button(action: {
                    self.viewStore.send(.loginButtonGedrueckt)
                }) {
                    Text("Anmelden")
                }
            }
            .alert(
                item: viewStore.binding(
                    get: { $0.fehlerNachricht.map(LoginAlert.init(titel:)) },
                    send: .warnhinweisVerwerfen
                ),
                content: { Alert(titel: Text($0.titel)) }
            )
        }.navigationBarTitel("Anmelden")
    }
}

struct LoginAlert: Identifiable {
    var title: String
    var id: String { self.title }
}
*/
