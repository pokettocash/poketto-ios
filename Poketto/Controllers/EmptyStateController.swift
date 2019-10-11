//
//  EmptyStateController.swift
//  Poketto
//
//  Created by André Sousa on 30/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SafariServices

class EmptyStateController: UIViewController {
    
    @IBOutlet weak var disclaimerTextView : UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = NSMutableAttributedString(string: "*Carbon is responsible for handling purchases")
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, text.length))
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6), range: NSMakeRange(0, text.length))

        let selectablePart = NSMakeRange(1, 7)
        text.addAttribute(NSAttributedString.Key.link, value: "carbonWebsite", range: selectablePart)
        text.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: selectablePart)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))

        disclaimerTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        disclaimerTextView.attributedText = text
        disclaimerTextView.isEditable = false
        disclaimerTextView.isSelectable = true
    }
    
    @IBAction func addFunds() {
        
        let wallet = Wallet.init()
        let walletAddress = wallet.getEthereumAddress()!.address
        let url = URL(string: "https://buy.carbon.money/?apiKey=9899fb8c-837b-41a5-a8bd-3094b7def049&tokens=xDai&homeScreenMessage=Poketto&receiveAddressxDai=\(walletAddress)")
        let vc = SFSafariViewController(url: url!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func receiveFunds() {
        
        let parent = self.parent as! DashboardController
        parent.request()
    }
    
    @IBAction func learnMore() {
        
        UIApplication.shared.open(URL(string: "https://poa.network/xdai")!, options: [:], completionHandler: nil)
    }
}

extension EmptyStateController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(Foundation.URL(string: "https://www.carbon.money")!, options: [:], completionHandler: nil)
        return false
    }
}

extension EmptyStateController : SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        let parent = self.parent as! DashboardController
        parent.fetchData()
    }
}
