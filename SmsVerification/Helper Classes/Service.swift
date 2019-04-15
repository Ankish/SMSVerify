//
//  Service.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/8/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import Foundation


typealias ServiceCompletion = (Data?,Int,String?) -> Void //Response data in Array,Status Code,Error Message

class Service {

    public static let shared = Service()
    
    var session = URLSession.shared
    
    func post(request : URLRequest,completion : @escaping ServiceCompletion) {
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard let response = response as? HTTPURLResponse else {
                completion(nil,400,responseError?.localizedDescription ?? NSLocalizedString("Some thing went wrong", comment: ""))
                return
            }
            
            guard let data = responseData else {
                completion(nil,400,responseError?.localizedDescription ?? NSLocalizedString("Some thing went wrong", comment: ""))
                return
            }
            
            if response.statusCode == 200 {
                completion(data,200,nil)
            } else {
                completion(nil,response.statusCode,responseError?.localizedDescription ?? NSLocalizedString("Some thing went wrong", comment: ""))
            }
        }
        
        task.resume()
    }
    
}

