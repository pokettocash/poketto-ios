//
//  ContactsController.swift
//  Poketto
//
//  Created by André Sousa on 28/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import Contacts
import MagicalRecord

protocol ContactsDelegate {
    func assignedContact(phoneContact: CNContact)
}

class ContactsController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    var address : String!
    lazy var phoneContacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        // sort by name given
        let sortedResults = results.sorted(by: {
            (firt: CNContact, second: CNContact) -> Bool in firt.givenName < second.givenName
        })
        
        return sortedResults
    }()
    
    var filterContacts : [CNContact]!
    var delegate : ContactsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterContacts = phoneContacts

        // Do any additional setup after loading the view.
        for s in searchBar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderWidth = 2.0
                s.layer.cornerRadius = 10
                s.layer.borderColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 0.4).cgColor
            }
        }
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func cancel() {
        
        navigationController!.dismiss(animated: true, completion: nil)
    }
    
}

extension ContactsController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){
        filterContentForSearchText(searchText: searchText)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        DispatchQueue.main.async {
            self.filterContacts.removeAll()
            
            if searchText != "" {
                self.filterContacts = self.phoneContacts.filter { phoneContact in
                    return "\(phoneContact.givenName) \(phoneContact.familyName)".lowercased().contains(searchText.lowercased())
                }
            } else {
                self.filterContacts = self.phoneContacts
                
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
}

extension ContactsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellId", for: indexPath) as! ContactCell
        let phoneContact = filterContacts[indexPath.row]
        cell.contactImageView.layer.cornerRadius = 20
        cell.contactLabel.text = "\(phoneContact.givenName) \(phoneContact.familyName)"
        cell.spinner.isHidden = true
        cell.accessoryType = .none
        DispatchQueue.main.async {
            if let contactThumbailData = phoneContact.thumbnailImageData {
                cell.contactImageView.image = UIImage(data: contactThumbailData)
            } else {
                DispatchQueue.main.async {
                    cell.contactImageView.image = UIImage(named: "contact-placeholder")
                }
            }
        }
        return cell
    }
}

extension ContactsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let phoneContact = filterContacts[indexPath.row]

        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
        cell.spinner.isHidden = false
        cell.spinner.startAnimating()
                
        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: address.uppercased()) {
            contact.name = "\(phoneContact.givenName) \(phoneContact.familyName)"
            contact.contact_id = phoneContact.identifier
        } else {
            let contact = PKContact(context: NSManagedObjectContext.mr_default())
            contact.address = address.uppercased()
            contact.name = "\(phoneContact.givenName) \(phoneContact.familyName)"
            contact.contact_id = phoneContact.identifier
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            cell.spinner.isHidden = true
            cell.spinner.stopAnimating()
            cell.accessoryType = .checkmark

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if self.delegate != nil {
                    self.delegate.assignedContact(phoneContact: phoneContact)
                }
                self.navigationController!.dismiss(animated: true, completion: nil)
            })
        })
    }
}
