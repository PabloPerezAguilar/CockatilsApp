//
//  Filter.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import Foundation

struct FilterApiResponse: Codable{
    let filters: [[String: String]]
    
    enum CodingKeys: String, CodingKey{
        case filters = "drinks"
    }
}

struct Filter{
    var key: String
    var value: String
}
        
