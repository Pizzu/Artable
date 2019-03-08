//
//  Product.swift
//  Artable
//
//  Created by Luca Lo Forte on 07/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

struct Product: Codable {
    var name: String
    var id: String
    var categoryId: String
    var price: Double
    var productDescription: String
    var imgUrl: String
    var timeStamp: Timestamp
    var stock: Int
}

extension Product: Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
