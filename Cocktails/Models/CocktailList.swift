//
//  CocktailList.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import Foundation

struct CocktailList: Codable{
    let drinks: [Cocktail]
}

struct Cocktail: Codable{
    let id: String
    let name: String
    let thumbUrl: String
    
    enum CodingKeys: String, CodingKey{
        case id = "idDrink"
        case name = "strDrink"
        case thumbUrl = "strDrinkThumb"
    }
}
