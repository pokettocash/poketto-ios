//
//  Transaction.swift
//  Poketto
//
//  Created by Tiago Alves on 08/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    var fromAddress : String!
    var toAddress : String!
    var date : Date!
    var amount : Float! // in DAI
    var transactionType : TransactionTypes!
    
    var displayName : String?
    var displayImage : UIImage?
    
    enum TransactionTypes {
        case Credit
        case Debit
    }
}
