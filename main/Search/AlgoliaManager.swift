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
    
    var posts : Index
    var users : Index
    var location : Index
    var category : Index
    
    let client = Client(appID: "TWU83H7FS8" , apiKey: "1beb1cb0de444f069abd9c6dddd245ec" )
    private override init() {
        //let apiKey = Bundle.main.infoDictionary!["AlgoliaApiKey"] as! String
        
        posts = client.index(withName: "posts")
        users = client.index(withName: "users")
        location = client.index(withName: "locations")
        category = client.index(withName: "category")
    }
}
