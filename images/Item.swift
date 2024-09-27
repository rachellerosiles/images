//
//  Item.swift
//  images
//
//  Created by Rachelle Rosiles on 9/27/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
