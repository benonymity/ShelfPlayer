//
//  LoginView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 16.09.23.
//

import SwiftUI
import AudiobooksKit

struct LoginView: View {
    var callback : () -> ()
    
    @State var loginSheetPresented = false
    @State var loginFlowState: LoginFlowState = .server
    
    @State var server = AudiobookshelfClient.shared.serverUrl?.absoluteString ?? ""
    @State var username = ""
    @State var password = ""
    
    @State var serverVersion: String?
    @State var loginError: LoginError?
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("Logo")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 130)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.bottom, 30)
            
            Text("login.welcome")
                .font(.headline)
                .fontDesign(.serif)
            Text("login.text")
                .font(.subheadline)
                .padding(.bottom)
            switch loginFlowState {
            case .server, .credentials:
                Section{
                    if loginFlowState == .server {
                        TextField("login.server", text: $server)
                            .keyboardType(.URL)
                            .textFieldStyle(LoginTextFieldStyle())
                        
                        Button {
                            flowStep()
                        } label: {
                            Text("login.next")
                        }
                        .buttonStyle(LargeButtonStyle())
                        .padding(3)
                        Text("Important!")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fontDesign(.serif)
                            .padding(.horizontal, 5)
                            .bold()
                            .padding(1)
                        Text("This app is designed to work with an Audiobookshelf server that you or someone you know is hosting. This app does not provide any content.")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .font(Font.system(size:15, design: .serif))
                            .padding(.horizontal, 5)
                    } else if loginFlowState == .credentials {
                        TextField("login.username", text: $username)
                            .textFieldStyle(LoginTextFieldStyle())
                        SecureField("login.password", text: $password)
                            .textFieldStyle(LoginTextFieldStyle())
                        Button {
                            flowStep()
                        } label: {
                            Text("login.promt")
                        }
                        .buttonStyle(LargeButtonStyle())
                    }
                }.padding(.horizontal,15)
                case .serverLoading, .credentialsLoading:
                    VStack {
                        ProgressView()
                        Text("login.loading")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
            }
            Spacer()
            
            Text("developedBy")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: Functions

extension LoginView {
    private func flowStep() {
        if loginFlowState == .server {
            loginFlowState = .serverLoading
            
            // Verify url format
            do {
                try AudiobookshelfClient.shared.setServerUrl(server)
            } catch {
                loginError = .url
                loginFlowState = .server
                
                return
            }
            
            // Verify server
            Task {
                do {
                    try await AudiobookshelfClient.shared.ping()
                } catch {
                    loginError = .server
                    loginFlowState = .server
                    
                    return
                }
                
                loginError = nil
                loginFlowState = .credentials
            }
        } else if loginFlowState == .credentials {
            loginFlowState = .credentialsLoading
            
            Task {
                do {
                    let token = try await AudiobookshelfClient.shared.login(username: username, password: password)
                    
                    AudiobookshelfClient.shared.setToken(token)
                    callback()
                } catch {
                    loginError = .failed
                    loginFlowState = .credentials
                }
            }
        }
    }
    
    enum LoginFlowState {
        case server
        case serverLoading
        case credentials
        case credentialsLoading
    }
    enum LoginError {
        case server
        case url
        case failed
    }
}

#Preview {
    LoginView() {
        print("Login flow finished")
    }
}
