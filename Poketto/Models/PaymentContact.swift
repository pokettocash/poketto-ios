//
//  PaymentContact.swift
//  Poketto
//
//  Created by André Sousa on 06/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class PaymentContact: NSObject {

    var name        : String!
    var address     : String!
    var contactId   : String?
    
    func addContact(from address: String) -> PaymentContact {
        
        let paymentContact = PaymentContact()
        
        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: address.uppercased()) {
            paymentContact.name = contact.name
            paymentContact.address = contact.address
            paymentContact.contactId = contact.contact_id
        } else {
            paymentContact.name = address
            paymentContact.address = address
        }
        
        return paymentContact
    }
}
