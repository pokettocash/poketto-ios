//
//  PayOptionsController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class PayOptionsController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var searchController            : UISearchController!
    let reuseIdentifier             = "payOptionCellId"
    @IBOutlet weak var tableView    : UITableView!
    var hasAddressOnClipboard       : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setSearchBar()
        checkPasteBoard()
    }
    
    func setSearchBar() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func checkPasteBoard() {
        
        if let pasteboardString = UIPasteboard.general.string {
            let first2 = String(pasteboardString.prefix(2))
            if first2 == "0x" {
                hasAddressOnClipboard = true
            }
            tableView.reloadData()
        }
    }

}

extension PayOptionsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if hasAddressOnClipboard {
                return 3
            } else {
                return 2
            }
        } else if section == 1 {
            return 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if hasAddressOnClipboard {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "pasteCellId", for: indexPath) as! PasteCell
                    cell.subtitleLabel.text = UIPasteboard.general.string
                    return cell
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "enterAddressCellId", for: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
                    return cell
                }
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "enterAddressCellId", for: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
                    return cell
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pasteCellId", for: indexPath) as! PasteCell
            return cell
        }
    }
}

extension PayOptionsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
