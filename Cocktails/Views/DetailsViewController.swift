//
//  DetailsViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/8/22.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var cocktailNameLabel: UILabel!
    @IBOutlet weak var cocktailTagsLabel: UILabel!
    @IBOutlet weak var cocktailAlcoholLabel: UILabel!
    @IBOutlet weak var cocktailCategoryLabel: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapLabel: UILabel!
    
    let viewModel = DetailsViewModel()
    private let locationManager = CLLocationManager()
    private let userRadiusInMeters: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initViewModel()
        locationServicesCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.inicializeFavorites()
    }
    
    func setup(){
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        mapView.delegate = self
    }
    
    func initViewModel(){
        viewModel.showInfo = {
            DispatchQueue.main.async {
                self.inicializeUIValues()
                self.cocktailImageView.isHidden = false
                self.cocktailNameLabel.isHidden = false
                self.cocktailTagsLabel.isHidden = false
                self.cocktailAlcoholLabel.isHidden = false
                self.cocktailCategoryLabel.isHidden = false
                self.ingredientsTableView.isHidden = false
                self.instructionsTextView.isHidden = false
                self.ingredientsTableView.reloadData()
            }
        }
        viewModel.showError = { error in
            DispatchQueue.main.async { self.showAlert(error, title: "Ups, something went wrong.") }
        }
        viewModel.showLoading = {
            DispatchQueue.main.async{
                self.activityIndicator.startAnimating()
                self.cocktailImageView.isHidden = true
                self.cocktailNameLabel.isHidden = true
                self.cocktailTagsLabel.isHidden = true
                self.cocktailAlcoholLabel.isHidden = true
                self.cocktailCategoryLabel.isHidden = true
                self.ingredientsTableView.isHidden = true
                self.instructionsTextView.isHidden = true
            }
        }
        viewModel.hideLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        viewModel.setButtonColor = { value in
            DispatchQueue.main.async {
                var color:UIColor = .white
                if(value == "favorited"){
                    color = .systemPink
                }
                self.changeFavButtonColor(color: color)
            }
        }
        viewModel.setMapKitRegion = { region in
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: true)
            }
        }
        viewModel.setMapKitAnnotations = { annotations in
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
            }
        }
        viewModel.setMapKitPolyline = { polyline in 
            DispatchQueue.main.async {
                print(polyline)
                self.mapView.addOverlay(polyline)
            }
        }
    }
    
    func configure(_ cocktail: Cocktail? = nil){
        if let cocktailDetails = cocktail {
            print("IN")
            viewModel.getDetailsById(id: cocktailDetails.id)
        }else {
            viewModel.getRandomCocktai()
        }
    }
    
    
    func inicializeUIValues(){
        let cocktail = viewModel.getCocktail()
        cocktailImageView.getImage(from: URL(string: cocktail.thumbUrl)!)
        cocktailNameLabel.text = cocktail.name
        cocktailTagsLabel.text = cocktail.tags
        cocktailAlcoholLabel.text = cocktail.alcoholic
        cocktailCategoryLabel.text = cocktail.category
        instructionsTextView.text = cocktail.instructions
        var color: UIColor = .white
        if(viewModel.checkIfFavorite()){
            color = .systemPink
        }
        changeFavButtonColor(color: color)
        
    }
    
    func changeFavButtonColor(color: UIColor){
        favoriteButton.tintColor = color
    }
    
    @IBAction func didTapFavotiresButton(_ sender: Any) {
        viewModel.setFavorite()
    }
    
    @IBAction func didTapYoutubeButton(_ sender: Any) {
        viewModel.redirectToYoutube()
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ingredientsTableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath)
        let ingredient = viewModel.getCocktail().ingredients[indexPath.row]
        cell.textLabel?.text = ingredient.ingredient
        cell.detailTextLabel?.text = ingredient.measure
        return cell
    }
    
}

extension DetailsViewController: MKMapViewDelegate, CLLocationManagerDelegate{
    
    private func setLocationServices(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func  checkAuthStatus(){
        switch locationManager.authorizationStatus{
        case .restricted, .denied:
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .authorizedAlways:
            mapView.showsUserLocation = true
            viewModel.grokUserLocation()
            viewModel.findSuperMarkets()
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            viewModel.grokUserLocation()
            viewModel.findSuperMarkets()
        default:
            break
        }
    }
    
    private func locationServicesCheck(){
        //Is GeoLocation enabled in the device
        if CLLocationManager.locationServicesEnabled() {
            setLocationServices()
            checkAuthStatus()
        }else{
            viewModel.showError?("Could not show map")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.markerTintColor = annotation.subtitle == "Nearest"  ? .systemPink : .gray

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        mapView.removeOverlays(mapView.overlays)
//        viewModel.setPolylineToAnnotation(view)
        var text = "Supermarkets in the area"
        if(text != view.annotation?.title){
            text = (view.annotation?.title!)!
        }
        mapLabel.text = text
    }
    
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let routePoliline = overlay as? MKPolyline{
//            let render = MKPolylineRenderer(polyline: routePoliline)
//            render.strokeColor = .blue
//            render.lineWidth = 3
//            return render
//        }
//
//        return MKOverlayRenderer()
//    }
    
    
}
