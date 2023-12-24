//
//  LoginTextFieldStyle.swift
//  Audiobooks
//
//  Created by Benjamin Bassett on 23.12.23.
//

import SwiftUI

struct LoginTextFieldStyle: TextFieldStyle {

    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundColor(.primary)
                .padding(12)
                .background(.fill)
                .cornerRadius(7)
                .padding(3)
        }
}
