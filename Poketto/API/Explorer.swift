//
//  Explorer.swift
//  Poketto
//
//  Created by Tiago Alves on 09/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import Foundation
import Alamofire
import Chester
import SwiftyJSON

let graphqlEndpoint = "https://blockscout.com/poa/dai/graphiql"

class Explorer {
    func balanceFrom(address: String, completion: @escaping (_ balance: Float) -> ()) {
        do {
            let query = try QueryBuilder()
                .from("address")
                .with(arguments: Argument(key: "hash", value: address))
                .with(fields: "fetchedCoinBalance")
                .build()
            
            let params = [
                "query": query
            ]
            
            Alamofire.request(graphqlEndpoint, parameters: params).responseJSON { response in
                let json = JSON(response.result.value!)
                let result = json["data"]["address"]["fetchedCoinBalance"]
                if let balance = result.string {
                    let wei = Float(balance)!
                    let dai : Float = wei / 1000000000000000000.0
                    completion(dai)
                } else {
                    completion(0)
                }
            }
        } catch {
            completion(0)
        }
    }
}
