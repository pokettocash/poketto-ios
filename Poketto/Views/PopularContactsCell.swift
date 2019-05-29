//
//  PopularContactsCell.swift
//  Poketto
//
//  Created by Andre Sousa on 29/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import Contacts

class PopularContactsCell: UITableViewCell {
    
    @IBOutlet weak var collectionView   : UICollectionView!
    var popularPaymentContacts          : [PaymentContact] = []
    var contactStore                    = CNContactStore()
    var paymentContactsController       : PaymentContactsController!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }

}

extension PopularContactsCell : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularPaymentContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularContactCellId", for: indexPath) as! PopularContactCell

        let paymentContact = popularPaymentContacts[indexPath.row]
        cell.addressLabel.text = paymentContact.name
        
        if let contactId = paymentContact.contactId {
            do {
                let phoneContact = try contactStore.unifiedContact(withIdentifier: contactId, keysToFetch: [CNContactThumbnailImageDataKey as CNKeyDescriptor])
                if let avatar = phoneContact.thumbnailImageData {
                    DispatchQueue.main.async {
                        cell.contactImageView.image = UIImage(data: avatar)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.contactImageView.image = UIImage(named: "contact-placeholder")
                    }
                }
            } catch {
                print("Error fetching results for container")
                DispatchQueue.main.async {
                    cell.contactImageView.image = UIImage(named: "contact-placeholder")
                }
            }
        } else {
            DispatchQueue.main.async {
                cell.contactImageView.image = UIImage(named: "unknown-address")
            }
        }
        
        cell.contactImageView.layer.cornerRadius = 28

        return cell
    }
}

extension PopularContactsCell : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let paymentContact = popularPaymentContacts[indexPath.row]
        paymentContactsController.selectedAddress = paymentContact.address
        paymentContactsController.performSegue(withIdentifier: "send", sender: paymentContact)
    }
}

