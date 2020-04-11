//
//  EndPointCompatible.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import Alamofire

public protocol EndPointCompatible {
    var method: HTTPMethod {get}
    var query: [String: Any] {get}
    var path: String {get}
}

extension EndPointCompatible {
    
    var method: HTTPMethod {
        switch self {
        default :
            return .post
        }
    }
    
    var baseQuery: [String: Any]  {
        var modifiedQueries: [String: Any] = [:]
        if let token = APITokenManager.accessToken, let userName = APITokenManager.userName {
            modifiedQueries["Token"] = token
            modifiedQueries["UserName"] = userName
        }
        return modifiedQueries
    }
    
    func getCompleteParameters(parameters: [String: Any]) -> [String: Any] {
        var modifiedQueries: [String: Any] = parameters
        if let token = APITokenManager.accessToken, let userName = APITokenManager.userName {
            modifiedQueries["Token"] = token
            modifiedQueries["UserName"] = userName
        }
        modifiedQueries["DeviceId"] = UIDevice.current.identifierForVendor!.uuidString
        return modifiedQueries
    }
    
    func getCompleteParametersForLogin(parameters: [String: Any]) -> [String: Any] {
        var modifiedQueries: [String: Any] = parameters
        modifiedQueries["DeviceId"] = UIDevice.current.identifierForVendor!.uuidString
        return modifiedQueries
    }
}

class RCTRCTEndpointsManager {

}

func queryBuilder(queries: [(name:String, value:Any)]) -> [String: Any] {
    var queryItems:[String: Any] = [String: Any]()
    for query in queries {
        
        if query.name.isEmpty {
            continue
        }
        if let value = query.value as? String, value.isEmpty {
            continue
        }
        
        queryItems[query.name] = query.value
    }
    return queryItems
}

/// Convenience enum for managing API Path.
enum APIPath {
    case apiPayment(path: String)
    case basePath(path: String)
    
    var url: String {
        switch self {
        case .apiPayment(let path): return basePath+"Payment/"+path
        case .basePath(let path): return basePath + path
        }
    }
    private var basePath: String {
        return URLManager.aPIBaseURL
    }
}
