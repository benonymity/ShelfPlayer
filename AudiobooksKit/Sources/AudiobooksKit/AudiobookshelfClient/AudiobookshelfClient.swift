//
//  AudiobookshelfClient.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 17.09.23.
//

import Foundation

public class AudiobookshelfClient {
    public private(set) var serverUrl: URL!
    public private(set) var token: String!
    
    public private(set) var clientVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    public private(set) var clientBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    
    private init(serverUrl: URL!, token: String!) {
        self.serverUrl = serverUrl
        self.token = token
    }
    
    lazy public private(set) var isAuthorized = {
        self.token != nil
    }()
}

// MARK: Setter

extension AudiobookshelfClient {
    public func setServerUrl(_ serverUrl: String) throws {
        guard let serverUrl = URL(string: serverUrl) else {
            throw AudiobookshelfClientError.invalidServerUrl
        }
        
        UserDefaults.standard.set(serverUrl, forKey: "serverUrl")
        self.serverUrl = serverUrl
    }
    public func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "token")
        self.token = token
    }
    
    public func logout() {
        UserDefaults.standard.set(nil, forKey: "token")
        exit(0)
    }
}

// MARK: Singleton

extension AudiobookshelfClient {
    public static let shared = {
        AudiobookshelfClient(
            serverUrl: UserDefaults.standard.url(forKey: "serverUrl"),
            token: UserDefaults.standard.string(forKey: "token"))
    }()
}