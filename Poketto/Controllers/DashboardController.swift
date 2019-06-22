//
//  DashboardController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftyJSON
import Presentr
import MagicalRecord
import Contacts


class DashboardController: UIViewController, SettingsDelegate {
    
    var emptyStateContainer             : EmptyStateController!
    @IBOutlet var collectionView        : UICollectionView!
    private let refreshControl          = UIRefreshControl()
    var transactions                    : Array<Transaction> = []
    var dayGroupedTransactions          : Array<Any> = []
    let reuseIdentifier                 = "transactionCellId"
    var headerID                        = "dashboardHeaderId"
    var headerDayID                     = "dashboardHeaderDayId"
    var balance                         : Float!
    var spentToday                      : Float!
    var contactStore                    = CNContactStore()
    var wallet                          = Wallet.init()
    var explorer                        = Explorer.init()
    var hasFetchedData                  = false
    let impact                          = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "DashboardHeaderDayView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerDayID)
    
        collectionView.delaysContentTouches = false
        collectionView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        emptyStateContainer = storyboard?.instantiateViewController(withIdentifier: "emptyStateVC") as? EmptyStateController
        self.addChild(emptyStateContainer)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
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
        
    func fetchData() {
        
        explorer.balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
            print("balance \(balance)")
            self.balance = balance
            self.collectionView.reloadData()
        })
        
        print("wallet address \(wallet.getEthereumAddress()!.address)")
        explorer.transactionsFrom(address: wallet.getEthereumAddress()!.address, completion: { transactions in
            let walletAddress = self.wallet.getEthereumAddress()?.address
            
            var serializedTransactions : Array<Transaction> = []
            var spentTodaySum = Float(0.0)
            
            transactions.forEach({ (exploredTransaction) in
                let jsonTransaction = exploredTransaction as! JSON
                let transaction = Transaction.init()
                
                print("jsonTransaction \(jsonTransaction)")
                
                transaction.toAddress = jsonTransaction["to"].stringValue
                transaction.fromAddress = jsonTransaction["from"].stringValue
                transaction.txHash = jsonTransaction["hash"].stringValue
                
                let date = jsonTransaction["timeStamp"].stringValue
                transaction.date = Date.init(timeIntervalSince1970: TimeInterval(Double(date)!))
                
                var othersAddress = transaction.toAddress.uppercased()
                transaction.transactionType = .Debit
                if transaction.toAddress.uppercased() == walletAddress!.uppercased() {
                    othersAddress = transaction.fromAddress.uppercased()
                    transaction.transactionType = .Credit
                }
                
                if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: othersAddress, in: NSManagedObjectContext.mr_default()) {

                    transaction.displayName = contact.name
                    
                    do {
                        let phoneContact = try self.contactStore.unifiedContact(withIdentifier: contact.contact_id!, keysToFetch: [CNContactThumbnailImageDataKey as CNKeyDescriptor])
                        if let avatar = phoneContact.thumbnailImageData {
                            transaction.displayImage = UIImage(data: avatar)
                        } else {
                            transaction.displayImage = UIImage(named: "contact-placeholder")
                        }
                    } catch {
                        print("Error fetching results for container")
                        transaction.displayImage = UIImage(named: "contact-placeholder")
                    }
                    
                } else {
                    transaction.displayImage = UIImage(named: "unknown-address")
                }
                
                if let amount = jsonTransaction["value"].string {
                    let wei = Float(amount)!
                    let dai : Float = wei / 1000000000000000000.0
                    
                    transaction.amount = dai
                }
                
                if (Calendar.current.isDateInToday(transaction.date) && transaction.transactionType == .Debit) {
                    spentTodaySum += transaction.amount
                }
                
                serializedTransactions.append(transaction)
            })
            
            let groupedTransactions = serializedTransactions.groupSort(byDate: { $0.date })
            self.dayGroupedTransactions = groupedTransactions.reversed()
            
            self.spentToday = spentTodaySum
            
            DispatchQueue.main.async {
                self.hasFetchedData = true
                self.refreshControl.endRefreshing()
                self.transactions = serializedTransactions
                self.transactions.reverse()
                self.collectionView.reloadData()
            }
        })
    }
    
    @objc func refreshData(_ sender: Any) {
        fetchData()
    }
    
    @IBAction func pay() {
        
        impact.impactOccurred()

        let paymentContactsNavVC = storyboard?.instantiateViewController(withIdentifier: "paymentContactsNavVC") as! UINavigationController
        let paymentsVC = paymentContactsNavVC.viewControllers[0] as! PaymentContactsController
        paymentsVC.transactions = transactions
        navigationController?.present(paymentContactsNavVC, animated: true, completion: nil)
    }
    
    @IBAction func settings() {
        
        AppDelegate.shared.blurBackground()
        impact.impactOccurred()
        
        let presenter: Presentr = {
            let heightFloat : Float = 526
            let width = ModalSize.sideMargin(value: 14)
            let height = ModalSize.custom(size: heightFloat)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 14, y: Int(Float((UIScreen.main.bounds.size.height / 2)) - (heightFloat / 2.0))))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVerticalFromTop
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 25
            customPresenter.backgroundColor = .black
            customPresenter.backgroundOpacity = 0.5
            customPresenter.dismissOnSwipe = false
            customPresenter.dismissOnSwipeDirection = .top
            return customPresenter
        }()
        let controller = storyboard?.instantiateViewController(withIdentifier: "settingsNavVC") as! SettingsNavigationController
        controller.settingsDelegate = self
        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    }
    
    func importCompleted() {
        self.fetchData()
    }
    
    @IBAction func request() {
        
        AppDelegate.shared.blurBackground()
        impact.impactOccurred()

        let presenter: Presentr = {
            let width = ModalSize.sideMargin(value: 14)
            let height = ModalSize.custom(size: 536)
            let window = UIApplication.shared.keyWindow
            var padding : CGFloat = 0
            if window?.safeAreaInsets.bottom == 0 {
                padding = 40
            }
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 14, y: (145-padding)*(UIScreen.main.bounds.size.height/812)-padding))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVerticalFromTop
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 25
            customPresenter.backgroundColor = .black
            customPresenter.backgroundOpacity = 0.5
            customPresenter.dismissOnSwipe = false
            customPresenter.dismissOnSwipeDirection = .top
            return customPresenter
        }()
        let navController = storyboard?.instantiateViewController(withIdentifier: "requestNavVC") as! UINavigationController
        let wallet = Wallet.init()
        let controller = navController.viewControllers[0] as! RequestController
        controller.address = wallet.getEthereumAddress()?.address
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "paymentDetails" {
            let transaction = sender as! Transaction
            let paymentDetailsVC = segue.destination as! PaymentDetailsController
            paymentDetailsVC.transaction = transaction
        }
    }
}

extension DashboardController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dayGroupedTransactions.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            let transactions = (dayGroupedTransactions as NSArray).object(at: section-1) as! [Transaction]
            return transactions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        if indexPath.section == 0 {
            var sectionHeader = DashboardHeaderView()

            sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerID, for: indexPath) as! DashboardHeaderView

            if kind == UICollectionView.elementKindSectionHeader {

                if(balance != nil) {
                    sectionHeader.balanceLabel.text = "\(String(format: "%.2f", balance)) xDai"
                }

                if(spentToday != nil) {
                    sectionHeader.spentTodayLabel.text = "\(String(format: "%.2f", spentToday)) xDai"
                }

                if(hasFetchedData) {
                    sectionHeader.isHidden = false
                }

                if(self.transactions.count == 0 && hasFetchedData) {
                    sectionHeader.emptyStateView.isHidden = false
                    self.emptyStateContainer.view.isHidden = false
                    if(!sectionHeader.emptyStateView.contains(self.emptyStateContainer.view)) {
                        sectionHeader.emptyStateView.addSubview(self.emptyStateContainer.view)
                    }
                } else {
                    sectionHeader.emptyStateView.isHidden = true
                    self.emptyStateContainer.view.isHidden = true
                    if(sectionHeader.emptyStateView.contains(self.emptyStateContainer.view)) {
                        self.emptyStateContainer.view.removeFromSuperview()
                    }
                }

                return sectionHeader
            }
            return UICollectionReusableView()
        } else {
            var sectionHeader = DashboardHeaderDayView()
            
            sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerDayID, for: indexPath) as! DashboardHeaderDayView
            
            if kind == UICollectionView.elementKindSectionHeader {
                
                let transactions = (dayGroupedTransactions as NSArray).object(at: indexPath.section-1) as! [Transaction]
                let transaction = transactions[0]
                
                if Calendar.current.isDateInToday(transaction.date) {
                    sectionHeader.dateLabel.text = "Today"
                } else if Calendar.current.isDateInYesterday(transaction.date) {
                    sectionHeader.dateLabel.text = "Yesterday"
                } else if Calendar.current.isDate(Date(), equalTo: transaction.date, toGranularity: .weekOfYear) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMMM"
                    sectionHeader.dateLabel.text = dateFormatter.string(from: transaction.date)
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMMM"
                    sectionHeader.dateLabel.text = dateFormatter.string(from: transaction.date)
                }
                
                return sectionHeader
            }
            return UICollectionReusableView()
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TransactionCell
        
        let transactions = (dayGroupedTransactions as NSArray).object(at: indexPath.section-1) as! NSArray
        let reversedTransactions = transactions.reversed() as! [Transaction]
        let transaction = reversedTransactions[indexPath.row]
        
        if (transaction.displayName != nil) {
            cell.addressLabel.text = transaction.displayName
        } else {
            let attributedString = NSMutableAttributedString(string: "Unknown",
                                                             attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                                                                           NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)])
            attributedString.append(NSMutableAttributedString(string: "   \(transaction.transactionType == .Credit ? transaction.fromAddress ?? "" : transaction.toAddress ?? "")",
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                             NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.3)]))
            cell.addressLabel.attributedText = attributedString
        }
        
        if (transaction.displayImage != nil) {
            cell.contactImageView.image = transaction.displayImage
        }
        
        if (transaction.transactionType == .Credit) {
            cell.amountLabel.text = String(format: "+%.2f", transaction.amount)
            cell.amountLabel.textColor = UIColor(red: 255/255, green: 190/255, blue: 65/255, alpha: 1)
        } else {
            cell.amountLabel.text = String(format: "%.2f", transaction.amount)
            cell.amountLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        }
        
        cell.contactImageView.layer.cornerRadius = 20
        
        return cell
    }
}

extension DashboardController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            if let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? DashboardHeaderView {
                // Layout to get the right dimensions
                headerView.layoutIfNeeded()
            }
            
            // Automagically get the right height
            var height : CGFloat = 215
            if self.transactions.count == 0 {
                height = self.view.frame.size.height
            }
            
            emptyStateContainer.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height)
            emptyStateContainer.view.updateConstraints()
            emptyStateContainer.view.layoutSubviews()
            
            // return the correct size
            return CGSize(width: collectionView.frame.width, height: height)

        } else {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DashboardController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section > 0 {
            let transactions = (dayGroupedTransactions as NSArray).object(at: indexPath.section-1) as! NSArray
            let reversedTransactions = transactions.reversed() as! [Transaction]
            let transaction = reversedTransactions[indexPath.row]
            performSegue(withIdentifier: "paymentDetails", sender: transaction)
        }
    }
}
