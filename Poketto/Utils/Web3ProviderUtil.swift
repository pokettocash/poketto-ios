//
//  Web3ProviderUtil.swift
//  Poketto
//
//  Created by Pabel Nunez Landestoy on 6/27/19.
//  Copyright © 2019 Poketto. All rights reserved.
//

import Foundation
import web3swift
import PromiseKit
import PocketSwift

public class Web3ProviderUtil: NSObject {
    static let defaultProviderUrl = "https://dai.poa.network"

    public static func getCurrentProvider() -> Web3Provider {
        if let network = UserDefaults.standard.string(forKey: "currentNetwork") {
            
            if network == "pocket" {
                return PocketWeb3Provider.init()!
            }else {
                return Web3HttpProvider(URL(string: defaultProviderUrl)!)!
            }
            
        }else {
            print("Unable to retrieve current network setttings, using default.")
            
            UserDefaults.standard.set("default", forKey: "currentNetwork")
            return Web3HttpProvider(URL(string: defaultProviderUrl)!)!
        }
    }
    
    public static func getCurrentNetwork() -> String {
        if let network = UserDefaults.standard.string(forKey: "currentNetwork") {
            return network
        }else {
            UserDefaults.standard.set("default", forKey: "currentNetwork")
            return UserDefaults.standard.string(forKey: "currentNetwork")!
        }
    }
    
}

