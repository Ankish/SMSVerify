//
//  Data+Extension.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/8/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import Foundation

extension Data {
    func toDictionary() -> [String:Any]? {
        if let decoded = try? JSONSerialization.jsonObject(with: self, options: []),let dictFromJSON = decoded as? [String:Any] {
            return dictFromJSON
        } else {
            return nil
        }
    }
}
