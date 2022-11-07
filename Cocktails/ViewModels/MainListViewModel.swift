//
//  MainListViewModel.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import Foundation

class MainListViewModel{
    var reloadTableView: (()->())?
    var showError: ((_ error: String)->())?
    var showLoading: (()->())?
    var hideLoading: (()->())?
    
    let database = DatabaseHandler()
    var cocktails = [Cocktail]();
    var filters: [Filter] = [
        Filter(key: "a", value: "Alcoholic")
    ];
    var favorites: [CocktailCoreData]?{
        didSet {
            reloadTableView?()
        }
    }
    
    func getCocktails(){
        showLoading?()
        let url = Constants.listUrl
        var components = URLComponents(string: url)!
        var queryItems: [URLQueryItem] = []
        for filter in filters {
            queryItems.append(
                URLQueryItem(name: filter.key, value: filter.value)
            )
        }
        components.queryItems = queryItems
        
        URLSession.shared.getRequest(components: components, decoding: CocktailList.self){
            result in
            self.hideLoading?()
            switch result{
            case .success(let data):
                self.cocktails = data.drinks;
                self.reloadTableView?()
            case .failure(let error):
                self.showError?(error.localizedDescription)
            }
        }
    }
    
    var numberOfCells: Int {
        return cocktails.count
    }
    
    var currentFilters: [Filter]{
        return filters
    }
    
    func getCocktail(_ index: Int) -> Cocktail{
        return cocktails[index]
    }
    
    func filterResults(_ filters: [Filter]){
        self.filters = filters
        getCocktails()
    }
    
    func inicializeFavorites(){
        favorites = database.fetch(CocktailCoreData.self)
    }
    
    func setFavorite(_ index: Int){
        let currentCocktail = cocktails[index]
        if let favIndex = favorites?.firstIndex(where: {$0.id == currentCocktail.id} ){
            database.delete((favorites?[favIndex])!)
            favorites?.remove(at: favIndex)
        }else{
            guard let newFavorite = database.add(CocktailCoreData.self) else{
                showError?("Could not add to favorites, try again")
                return
            }
            newFavorite.id = currentCocktail.id
            newFavorite.name = currentCocktail.name
            newFavorite.thumbUrl = currentCocktail.thumbUrl
            database.save()
            favorites?.append(newFavorite)
        }
        
        reloadTableView?()
    }
    
    func isFavorite(_ index: Int) -> Bool{
        let currentCocktail = cocktails[index]
        guard let favorite = favorites?.contains(where: {$0.id == currentCocktail.id} ) else {
            return false
        }
        return favorite
    }
    
    
    
    
}
