//
//  ImportSeedController.swift
//  Poketto
//
//  Created by Tiago Alves on 01/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class ImportSeedController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var seedKeyTextView : UITextView!
    
    var placeholderText = "Paste here your seed key..."

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        
        seedKeyTextView.text = placeholderText
        seedKeyTextView.textColor = UIColor.lightGray
        
        seedKeyTextView.becomeFirstResponder()
        seedKeyTextView.delegate = self
        
        seedKeyTextView.selectedTextRange = seedKeyTextView.textRange(from: seedKeyTextView.beginningOfDocument, to: seedKeyTextView.beginningOfDocument)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        } else {
            return true
        }
        
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    @IBAction func importWallet() {
        let wallet = Wallet.init()
        let importedWallet = wallet.importSeed(seed: seedKeyTextView.text)
        if (!importedWallet) {
            let msg = "The seed key you provided was invalid. Please try again with a different one."
            let alert = UIAlertController(title: "Error",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let settingsNavigationController = self.navigationController as! SettingsNavigationController
            settingsNavigationController.importCompleted()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
}
