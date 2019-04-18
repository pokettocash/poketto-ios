//
//  DashboardController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftyJSON

class DashboardController: UIViewController {
    
    @IBOutlet var collectionView    : UICollectionView!
    var transactions                : Array<Any> = []
    let reuseIdentifier             = "transactionCellId"
    var headerID                    = "dashboardHeaderId"
    var balance                     : Float!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavDivider()

        let wallet = Wallet.init()

        let explorer = Explorer.init()
        explorer.balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
            print(balance)
            self.balance = balance
            self.collectionView.reloadData()
        })
        
//        explorer.transactionsFrom(address: "0x569d656393ca2e1b62a362a6a60556b2ad56721d", completion: { transactions in
//            print("transactions \(transactions)")
//            self.transactions = transactions
//        })

        explorer.transactionsFrom(address: wallet.getEthereumAddress()!.address, completion: { transactions in
            print("transactions \(transactions)")
            self.transactions = transactions
            self.collectionView.reloadData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIScreen.main.bounds.size.width < 375 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWidth = 375*UIScreen.main.bounds.size.width/375
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
        }
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func addNavDivider() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        let dividerView = UIView(frame: CGRect(x: 15, y: (navigationController?.navigationBar.frame.size.height)!-2, width: (navigationController?.navigationBar.frame.size.width)!-30, height: 2))
        dividerView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        navigationController?.navigationBar.addSubview(dividerView)
    }
}

extension DashboardController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = DashboardHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerID, for: indexPath) as! DashboardHeaderView
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            if(balance != nil) {
                sectionHeader.balanceLabel.text = "\(balance!) xDai"
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TransactionCell
        
        let transaction = transactions[indexPath.row] as! JSON
        
        cell.addressLabel.text = "\(transaction["to"])"
        cell.amountLabel.text = "\(transaction["value"])"
        
        return cell
    }
}

extension DashboardController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}
