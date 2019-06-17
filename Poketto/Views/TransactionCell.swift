//
//  TransactionCell.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class TransactionCell: UICollectionViewCell {
    
    @IBOutlet weak var contactImageView : UIImageView!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var amountLabel : UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
            } else {
                backgroundColor = UIColor.white
            }
        }
    }
}
