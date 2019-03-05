//
//  Category.swift
//  Artable
//
//  Created by Luca Lo Forte on 04/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

struct Category: Codable {
    var name: String
    var id: String
    var imgUrl: String
    var isActive: Bool = true
    var timeStamp: Timestamp
}

extension Timestamp: TimestampType {}
