//
//  MapSearchController.swift
//  maple
//
//  Created by Murray Toews on 2017-07-01.
//  Copyright © 2017 mapleon. All rights reserved.
//

import UIKit
import GooglePlaces

class MapSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var tableDataSource: GMSAutocompleteTableDataSource?
    var searchController: UISearchController?
    
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search for friends"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    
    /*
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
        
    }
    */
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Locations"
        
        let leftButton =  UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancel))
        
        
        let image = UIImage(named: "nav_more_icons")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleMenu))
        button.tintColor = .mainBlack()
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = button
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        //collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self as? GMSAutocompleteTableDataSourceDelegate
        
        searchController = UISearchController()
        
        //searchController?.searchResultsDataSource = tableDataSource
        //searchController.searchResultsDelegate = tableDataSource
        searchController?.delegate = self as? UISearchControllerDelegate
        
        view.addSubview(searchBar)
    }
    
    @objc func handleCancel()
    {
        
    }
    
    @objc func handleMenu()
    {
        
    }
    
    func didUpdateAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    func didRequestAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        searchDisplayController?.searchResultsTableView.reloadData()
    }
    
}

extension MapSearchController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(_ didAutocompleteWithtableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        searchDisplayController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        tableDataSource?.sourceTextHasChanged(searchString)
        return false
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // TODO: Handle the error.
        // print("Error: \(error.description)")
    }
    
    private func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}

