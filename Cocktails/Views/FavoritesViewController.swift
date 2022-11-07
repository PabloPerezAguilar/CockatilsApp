//
//  FavoritesViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/7/22.
//

import UIKit

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let viewModel = FavoritesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.inicializeFavorites()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DetailsViewController{
            let cocktail = viewModel.getFavorite((self.tableView.indexPathForSelectedRow?.row)!)
            dvc.configure(cocktail)
        }
    }
    
    func setup(){
        title = "Favorites"
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
        
    }
    
    
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CocktailTableViewCell.identifier, for: indexPath) as! CocktailTableViewCell
        cell.delegate = self
        let cocktail = viewModel.getFavorite(indexPath.row)
        cell.configure(cocktail, canDelete: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favDetailsSegue", sender: self)
    }
    
}

extension FavoritesViewController: FavoritesProtocol{
    
    func passSelectedRowData(cell: UITableViewCell) {
        let tappedIndex = tableView.indexPath(for: cell)!.row
        viewModel.deleteFromFavorites(tappedIndex)
    }
    
}
