//
//  APIResponse.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import EVReflection

public enum APIResult<Response,Value> {
    case success(Response,Value?,GGSAPIPager?)
    case failure(Response?,Error?)
}


public class APIResponse: EVObject {
    var statusCode: NSNumber?
    var status: String?
    var message: String?
    var details: String?
    var id: String?
    var data: Any?
    var title: String?
    var errorMessages: [ErrorMessage]?
    var errors: APIError?
    
    public convenience required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class APIError: NSObject {
    
    var status: String?
    var code:Int = 0
    var message: String = ""
    var results: [String:String] = [:]
    
    override init() {
    }
    
    init(code:Int, message: String) {
        self.code = code
        self.message = message
    }
    
}

public class ErrorMessage: EVObject {
    var code: NSNumber?
    var message: String?
    var Email: String?
    var MobileNumber: String?
    var FullName: String?
    var Password: String?
    var details: String?
}

public class GGSAPIPager : EVObject {
    
    var parameters: [String:Any]?
    var sortBy: String?
    var desc: Bool? = nil
    var lastSearchKey: String?
    
    var currentPage : Int = 0
    var perPage: Int = 0
    var totalinpage: Int = 0
    var totalPage: Int = 0
    var total: Int = 0
    
    required public init () {}
}
