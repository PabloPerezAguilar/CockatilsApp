//
//  ViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filtersButton: UIButton!
    
    var viewModel = MainListViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.inicializeFavorites()
    }
    
    func setup(){
        title = "Cocktails"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CocktailTableViewCell", bundle: nil), forCellReuseIdentifier: CocktailTableViewCell.identifier)
    }
    
    func initViewModel(){
        viewModel.reloadTableView = {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        viewModel.showError = { error in
            DispatchQueue.main.async { self.showAlert(error, title: "Ups, something went wrong.") }
        }
        viewModel.showLoading = {
            DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        }
        viewModel.hideLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        viewModel.getCocktails()
    }
    
    private func setupUI(){
        filtersButton.tintColor = .uranianBlue
    }
    
    @IBAction func didTapFiltersButton(_ sender: Any) {
        performSegue(withIdentifier: "filtersSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FilterViewController{
            vc.delegate = self
            vc.currentFilters = viewModel.currentFilters
        }
        
        if let dvc = segue.destination as? DetailsViewController{
            let cocktail = viewModel.getCocktail((self.tableView.indexPathForSelectedRow?.row)!)
            dvc.configure(cocktail)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CocktailTableViewCell.identifier, for: indexPath) as! CocktailTableViewCell
        let isFavorite = viewModel.isFavorite(indexPath.row)
        cell.delegate = self
        cell.configure(viewModel.getCocktail(indexPath.row), isFavorite: isFavorite)
        
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mainDetailsSegue", sender: self)
    }
    
    
}

extension ViewController: FilterProtocol{
    func filterResults(filters: [Filter]) {
        viewModel.filterResults(filters)
        navigationController?.popViewController(animated: true)
    }
}

extension ViewController: FavoritesProtocol{
    func passSelectedRowData(cell: UITableViewCell) {
        let tappedIndex = tableView.indexPath(for: cell)!.row
        viewModel.setFavorite(tappedIndex)
    }
}

