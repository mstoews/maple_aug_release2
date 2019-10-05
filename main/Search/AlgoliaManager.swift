//
//  AlgoliaManager.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/24.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation
//import AFNetworking
import AlgoliaSearch
import Foundation

private let DEFAULTS_KEY_MIRRORED       = "algolia.mirrored"
private let DEFAULTS_KEY_STRATEGY       = "algolia.requestStrategy"
private let DEFAULTS_KEY_TIMEOUT        = "algolia.offlineFallbackTimeout"




class AlgoliaManager: NSObject {
    /// The singleton instance.
    static let sharedInstance = AlgoliaManager()
    static let appId = "TWU83H7FS8"
    static let apiKey = "1beb1cb0de444f069abd9c6dddd245ec"
    
    var posts : Index
    var users : Index
    var location : Index
    
    static let client = Client(appID: appId , apiKey: apiKey)
    private override init() {
        posts = AlgoliaManager.client.index(withName: "posts")
        users = AlgoliaManager.client.index(withName: "users")
        location = AlgoliaManager.client.index(withName: "locations")
    }
}
