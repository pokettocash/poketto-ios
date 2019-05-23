//
//  TapAndCopyLabel.swift
//  Poketto
//
//  Created by Andre Sousa on 23/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

@IBDesignable
class TapAndCopyLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - UIGestureRecognizer
    @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .recognized else { return }
        
        if let recognizerView = recognizer.view,
            let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder()
        {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            menuController.setMenuVisible(true, animated:true)
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(UIResponderStandardEditActions.copy(_:)))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
}
