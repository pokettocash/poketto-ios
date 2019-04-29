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

class ContactsController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel() {
        
        navigationController!.dismiss(animated: true, completion: nil)
    }
    
}

extension ContactsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellId", for: indexPath) as! ContactCell
        let phoneContact = phoneContacts[indexPath.row]
        cell.contactImageView.layer.cornerRadius = 20
        cell.contactLabel.text = "\(phoneContact.givenName) \(phoneContact.familyName)"
        cell.spinner.isHidden = true
        cell.accessoryType = .none
        DispatchQueue.main.async {
            if let contactThumbailData = phoneContact.thumbnailImageData {
                cell.contactImageView.image = UIImage(data: contactThumbailData)
            } else {
                cell.contactImageView.image = nil
            }
        }
        return cell
    }
}

extension ContactsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
        cell.spinner.isHidden = false
        cell.spinner.startAnimating()
        
        let phoneContact = phoneContacts[indexPath.row]
        
        let contact = PKContact(context: NSManagedObjectContext.mr_default())
        contact.address = address
        contact.name = "\(phoneContact.givenName) \(phoneContact.familyName)"
        contact.contact_id = phoneContact.identifier
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            cell.spinner.isHidden = true
            cell.spinner.stopAnimating()
            cell.accessoryType = .checkmark

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.navigationController!.dismiss(animated: true, completion: nil)
            })
        })
    }
}
