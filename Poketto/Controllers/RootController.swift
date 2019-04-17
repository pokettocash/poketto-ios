//
//  RootController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class RootController: UIViewController {
    
    private var current: UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        self.current = LaunchController()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.current = storyboard?.instantiateViewController(withIdentifier: "launchVC") as! LaunchController
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    func switchToDashboard() {
        let dashboardController = self.storyboard?.instantiateViewController(withIdentifier: "dashboardVC") as! DashboardController
        animateFadeTransition(to: dashboardController)
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        self.view.addSubview(new.view)
        new.view.alpha = 0
        new.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            new.view.alpha = 1
            self.current.view.alpha = 0
        }) { (finished) in
            self.current.view.removeFromSuperview()
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }

}
