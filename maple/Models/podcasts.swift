//
//  podcasts.swift
//  Maple
//
//  Created by Murray Toews on 4/26/19.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import Foundation


struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
