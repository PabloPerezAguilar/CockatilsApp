//
//  DetailsViewModel.swift
//  Cocktails
//
//  Created by Consultant on 7/8/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class DetailsViewModel{
    var showInfo: (() -> ())?
    var showLoading: (()->())?
    var hideLoading: (()->())?
    var showError: ((_ error: String)->())?
    var setButtonColor: ((_ color: String) -> ())?
    var setMapKitRegion: ((_ region: MKCoordinateRegion) -> ())?
    var setMapKitAnnotations: ((_ annotations: [MKPointAnnotation]) -> ())?
    var setMapKitPolyline: ((_ polyline: MKPolyline) -> ())?
    
    var cocktail = FormatedCocktailDetails(id: "", name: "", thumbUrl: "", tags: "", category: "", alcoholic: "", glass: "", instructions: "", ingredients: [])
    let database = DatabaseHandler()
    var favorites: [CocktailCoreData]?
    private let locationManager = CLLocationManager()
    private let userRadiusInMeters: Double = 1000
    
    func inicializeFavorites(){
        favorites = database.fetch(CocktailCoreData.self)
    }
    
    func getDetailsById(id: String){
        showLoading?()
        let url = Constants.detailsUrl
        var components = URLComponents(string: url)!
        components.queryItems =  [URLQueryItem(name: "i", value: id)]
        URLSession.shared.getRequest(components: components, decoding: APIResponse.self){ response in
            self.hideLoading?()
            switch(response){
                case .success(let data):
                    self.cocktail = self.formatCocktailDetails(data.drinks[0])
                    self.showInfo?()
                case .failure(let error):
                    self.showError?(error.localizedDescription)
            }
        }
    }
    
    func getRandomCocktai(){
        showLoading?()
        let url = Constants.randomUrl
        let components = URLComponents(string: url)
        URLSession.shared.getRequest(components: components, decoding: APIResponse.self){ result in
            self.hideLoading?()
            switch(result){
                case .success(let data):
                    self.cocktail = self.formatCocktailDetails(data.drinks[0])
                    self.showInfo?()
                case .failure(let error):
                    self.showError?(error.localizedDescription)
            }
        }
    }
    
    func formatIngredients(_ cocktail: CocktaiDetails) -> [Ingredient] {
        var ingredients: [Ingredient] = [];
        
        for i in 1..<16{
            guard let ingredient = cocktail["ingredient\(i)"] as? String, let measure = cocktail["measure\(i)"] as? String else { return ingredients }
            let value = Ingredient(ingredient: ingredient, measure: measure)
            ingredients.append(value)
        }
        
        return ingredients
    }
    
    func formatCocktailDetails(_ cocktail: CocktaiDetails) -> FormatedCocktailDetails {
        return FormatedCocktailDetails(
            id: cocktail.id,
            name: cocktail.name,
            thumbUrl: cocktail.thumbUrl,
            tags: cocktail.tags ?? "No info",
            category: cocktail.category ?? "No info",
            alcoholic: cocktail.alcoholic ?? "No info",
            glass: cocktail.glass ?? "No info",
            instructions: cocktail.instructions,
            ingredients: formatIngredients(cocktail)
        )
    }
    
    var numberOfCells: Int {
        return cocktail.ingredients.count
    }
    
    func getCocktail() -> FormatedCocktailDetails{
        return cocktail
    }
    
    func checkIfFavorite() -> Bool {
        guard let isFavorite = favorites?.contains(where: { $0.id == cocktail.id } ) else { return false }
        
        return isFavorite
    }
    
    func setFavorite() {
        var color = "default"
        if(checkIfFavorite()){
            let index = favorites?.firstIndex(where: { $0.id == cocktail.id } )
            database.delete(favorites![index!])
            favorites?.remove(at: index!)
        }else{
            guard let newFavorite = database.add(CocktailCoreData.self) else{
                showError?("Could not add to favorites, try again")
                return
            }
            newFavorite.id = cocktail.id
            newFavorite.name = cocktail.name
            newFavorite.thumbUrl = cocktail.thumbUrl
            
            favorites?.append(newFavorite)
            database.save()
            color = "favorited"
        }
        setButtonColor?(color)
    }
    
    func redirectToYoutube(){
        let formatedName = cocktail.name.replacingOccurrences(of: " ", with: "+")
        let url = "https://www.youtube.com/results?search_query=\(formatedName)+cocktail"
        if let youtubeUrl = URL(string: url), UIApplication.shared.canOpenURL(youtubeUrl){
            UIApplication.shared.open(youtubeUrl, options: [:], completionHandler: nil)
        }else{
            showError?("Can not open this link, try again")
        }
    }
    
    func grokUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: userRadiusInMeters, longitudinalMeters: userRadiusInMeters)
            setMapKitRegion?(region)
        }
    }
    
    func findSuperMarkets(){
        if let location = locationManager.location?.coordinate{
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "Groceries"
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: userRadiusInMeters, longitudinalMeters: userRadiusInMeters)
            request.region = region
            
            let search = MKLocalSearch(request: request)
            search.start(){ response, error in
                if error != nil{
                    self.showError?("Error occured in search: \(error!.localizedDescription)")
                }else if response!.mapItems.count == 0 {
                    self.showError?("No matches found")
                }else{
                    let items = response!.mapItems.sorted(by: {
                        (self.locationManager.location?.distance(from: $0.placemark.location!))! <
                            (self.locationManager.location?.distance(from: $1.placemark.location!))!
                    })
                    var markers = [MKPointAnnotation]()
                    var i = 0
                    for item in items{
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        var subtitle = ""
                        if(i == 0){
                            subtitle = "Nearest"
                        }
                        annotation.subtitle = subtitle
                        markers.append(annotation)
                        i += 1
                    }
                    self.setMapKitAnnotations?(markers)
                }
            }
        }
        
    }
    
    func setPolylineToAnnotation(_ annotation: MKAnnotationView){
        if let location = locationManager.location?.coordinate{
            let coordinates = [location, annotation.annotation?.coordinate] as! [CLLocationCoordinate2D]
            print(coordinates)
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            setMapKitPolyline?(polyline)
        }
    }

}
