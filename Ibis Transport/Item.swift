//
//  Item.swift
//  Ibis Transport
//
//  Created by appleshoops on 29/7/2024.
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
