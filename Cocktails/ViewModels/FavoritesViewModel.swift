//
//  FavoritesViewModel.swift
//  Cocktails
//
//  Created by Consultant on 7/7/22.
//

import Foundation

class FavoritesViewModel{
    var reloadTableView: (()->())?
    var showError: ((_ error: String)->())?
    
    let database = DatabaseHandler()
    var favorites: [CocktailCoreData]?{
        didSet {
            reloadTableView?()
        }
    }
    
    func inicializeFavorites(){
        favorites = database.fetch(CocktailCoreData.self)
    }
    
    var numberOfCells: Int {
        return favorites?.count ?? 0
    }
    
    func getFavorite(_ index: Int) -> Cocktail{
        guard let favorite = favorites?[index] else {
            return Cocktail(id: "", name: "", thumbUrl: "")
        }
        
        return Cocktail(id: favorite.id!, name: favorite.name!, thumbUrl: favorite.thumbUrl!)
    }
    
    func deleteFromFavorites(_ index: Int){
        database.delete((favorites?[index])!)
        favorites?.remove(at: index)
        reloadTableView?()
    }
}
