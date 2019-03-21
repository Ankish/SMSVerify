//
//  ApiClass.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/8/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public typealias HTTPHeaders = [String: String]

class Request {
    
    let url : String
    let method : HTTPMethod
    var headers: HTTPHeaders?
    var body: Data?
    
    init(baseUrl : String = Constants.baseUrl,path : String,method : HTTPMethod,headers: HTTPHeaders?,body:  Data?) {
        self.url = "\(baseUrl)\(path)"
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    func generateURLRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: self.url)!)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body
        return request
    }
}
