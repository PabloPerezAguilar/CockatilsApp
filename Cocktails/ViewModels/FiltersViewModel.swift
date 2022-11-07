//
//  FiltersViewModel.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//

import Foundation

class FiltersViewModel{
    var reloadTableView: (()->())?
    var showError: ((_ error: String)->())?
    var showLoading: (()->())?
    var hideLoading: (()->())?
    var insertRows: ((_ indexPaths: [IndexPath]) -> ())?
    var deleteRows: ((_ indexPaths: [IndexPath]) -> ())?
    var returnToList: ((_ filters: [Filter])->())?
    
    let filterKeys = [
        Filter(key: "Alcoholic", value: "a"),
        Filter(key: "Category", value: "c"),
        Filter(key: "Glass", value: "g"),
        Filter(key: "Ingredient", value: "i")
    ]
    var filterList: [ String: [ [String: String] ] ] = [
        "Alcoholic": [],
        "Category": [],
        "Glass": [],
        "Ingredient": []
    ]
    var selectedFilters = [
        "Alcoholic": "Alcoholic",
        "Category": "",
        "Glass": "",
        "Ingredient": ""
    ]
    var hiddenSections: Set = [0, 1, 2, 3]
    
    func getFilters(){
        self.showLoading?()
        var i = 1;
        let url = Constants.filterListUrl
        var components = URLComponents(string: url)!
        for item in filterKeys{
            components.queryItems = [URLQueryItem(name: item.value, value: "list")]
            URLSession.shared.getRequest(components: components, decoding: FilterApiResponse.self){ result in
                switch(result){
                    case .success(let data):
                    self.filterList[item.key] = data.filters
                    case .failure(let error):
                        print(error)
                }
                if(i == self.filterKeys.count){
                    self.setOpenFilters()
                    self.hideLoading?()
                    self.reloadTableView?()
                }
                i += 1;
            }
        }
    }
    
    var numberOfSections: Int {
        return filterList.count
    }
    
    func setOpenFilters(){
        let item = Array(selectedFilters).first(where: {$0.value != ""})
        let filterIndex = Array(filterList).firstIndex(where: { $0.key == item?.key })!
        let index = hiddenSections.firstIndex(where: { $0 == filterIndex })!
        hiddenSections.remove(at: index)
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int{
        var result = 0
        let elements = getFilterElementsBySection(section)
        if !self.hiddenSections.contains(section) && elements.count > 0{
            result = elements.count
        }
        return result
    }
    
    func getFilter(_ indexPath: IndexPath) -> [String : String]?{
        let elements = getFilterElementsBySection(indexPath.section)
        var result:[String : String]? = nil
        if(elements.count > 0){
            result = elements[indexPath.row];
        }
        
        return result
    }
    
    private func getFilterKeyBySection(_ section: Int) -> String{
        let index = filterList.index(filterList.startIndex, offsetBy: section)
        return self.filterList.keys[index];
    }
    
    func getSectionTitle(_ section: Int) -> String {
        let key = getFilterKeyBySection(section)
        let title = selectedFilters[key] != "" ? "\(key)(1)" : key
        return title
    }
    
    private func getFilterElementsBySection(_ section: Int) -> [[String: String]]{
        let key = getFilterKeyBySection(section)
        return self.filterList[key] ?? []
    }
    
    func getOriginalKeyBySection(_ section: Int) -> String{
        let key = getFilterKeyBySection(section)
        let originalKeys: [String: String] = [
            "Alcoholic": "strAlcoholic",
            "Category": "strCategory",
            "Glass": "strGlass",
            "Ingredient": "strIngredient1"
        ]
        
        return originalKeys[key]!
    }
    
    private func indexPathsForSection(_ section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let key = getFilterKeyBySection(section)
        for row in 0..<self.filterList[key]!.count{
            indexPaths.append(IndexPath(row: row, section: section))
        }
        
        return indexPaths
    }
    
    func setIshidden(_ section: Int){
        let indexPathsForSection = indexPathsForSection(section)
        
        if hiddenSections.contains(section){
            hiddenSections.remove(section)
            self.insertRows?(indexPathsForSection)
        }else{
            hiddenSections.insert(section)
            self.deleteRows?(indexPathsForSection)
        }
    }
    
    private func getValueFromSelectedRow(_ indexPath: IndexPath, key: String) -> String{
        let selectedRow = self.filterList[key]?[indexPath.row]
        let originalKey = getOriginalKeyBySection(indexPath.section)
        return selectedRow?[originalKey] ?? ""
    }
    
    func selectFilter(_ indexPath: IndexPath){
        let key = getFilterKeyBySection(indexPath.section)
        let value = getValueFromSelectedRow(indexPath, key: key)
        if(selectedFilters[key] == value){
            selectedFilters[key] = ""
        }else{
            selectedFilters = [
                "Alcoholic": "",
                "Category": "",
                "Glass": "",
                "Ingredient": ""
            ]
            selectedFilters[key] = value
        }
        self.reloadTableView?()
    }
    
    func isRowSelected(_ indexPath: IndexPath) -> Bool{
        let key = getFilterKeyBySection(indexPath.section)
        let item = getValueFromSelectedRow(indexPath, key: key)
        
        return selectedFilters[key] == item
    }
    
    private func formatFilterKey(_ key: String) -> String{
        let formatedFilterKeys: [String: String] = [
            "Alcoholic": "a",
            "Category": "c",
            "Glass": "g",
            "Ingredient": "i"
        ]
        
        return formatedFilterKeys[key]!
    }
    
    func filterResults(){
        var formatedFilters: [Filter] = [];
        for filter in selectedFilters{
            if(filter.value != ""){
                let key = formatFilterKey(filter.key)
                formatedFilters.append(
                    Filter(key: key, value: filter.value)
                )
            }
        }
        if(formatedFilters.isEmpty){
            showError?("You must select at least one filter")
        }
        
        returnToList?(formatedFilters)
    }
    
    func setCurrentFilters(_ correntFormatedfilters: [Filter]){
        let filterKeys: [String: String] = [
            "a": "Alcoholic",
            "c": "Category",
            "g": "Glass",
            "i": "Ingredient"
        ]
        var currentFilters = [
            "Alcoholic": "",
            "Category": "",
            "Glass": "",
            "Ingredient": ""
        ]
        for filter in correntFormatedfilters{
            let filterKey = filterKeys[filter.key]!
            currentFilters[filterKey] = filter.value
        }
        selectedFilters = currentFilters
    }
    
    func cleanFilters(){
        selectedFilters = [
            "Alcoholic": "Alcoholic",
            "Category": "",
            "Glass": "",
            "Ingredient": ""
        ]
        self.reloadTableView?()
    }
    
}
