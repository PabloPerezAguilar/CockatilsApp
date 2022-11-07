//
//  FilterTableViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var cleanButton: UIButton!
    
    let filterVM = FiltersViewModel()
    var delegate: FilterProtocol?
    var currentFilters = [Filter]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initViewModel()
        setupUI()
    }
    
    func setup(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func initViewModel(){
        filterVM.reloadTableView = {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
        filterVM.showError = { error in
            DispatchQueue.main.async { self.showAlert(error, title: "Ups, something went wrong.") }
        }
        
        filterVM.showLoading = {
            DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        }
        
        filterVM.hideLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
        filterVM.insertRows = { indexPaths in
            DispatchQueue.main.async {
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
        
        filterVM.deleteRows = { indexPaths in
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            }
        }
        
        filterVM.returnToList = { filters in
            self.delegate?.filterResults(filters: filters)
            self.navigationController?.popViewController(animated: true)
        }
        
        filterVM.getFilters()
        filterVM.setCurrentFilters(currentFilters)
    }
    
    private func setupUI(){
        filterButton.tintColor = .uranianBlue
        cleanButton.tintColor = .middleBlueGreen
    }

    @IBAction func didTapFilterButton(_ sender: Any) {
        filterVM.filterResults()
    }
    
    @IBAction func didTapCleanButton(_ sender: Any) {
        filterVM.cleanFilters()
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterVM.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterVM.getNumberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let key = filterVM.getOriginalKeyBySection(indexPath.section)
        let element = filterVM.getFilter(indexPath)
        cell.textLabel?.text = element?[key]
        if(filterVM.isRowSelected(indexPath)){
            cell.backgroundColor = .ligthSteelBlue
            cell.textLabel?.textColor = .black
        }else{
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .risingBlack
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterVM.selectFilter(indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionButton = UIButton()
        sectionButton.layer.cornerRadius = 5
        sectionButton.clipsToBounds = true
        sectionButton.setTitle(filterVM.getSectionTitle(section), for: .normal)
        sectionButton.backgroundColor = .systemPink
        sectionButton.tag = section
        sectionButton.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)
        
        return sectionButton
    }
    
    @objc
    private func hideSection(sender: UIButton){
        let section = sender.tag
        
        filterVM.setIshidden(section)
        
    }
}
