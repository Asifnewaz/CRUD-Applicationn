//
//  APIManager.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
    
    static var tokenInfo: TokenInformationModel?
    static var sessionManager: Alamofire.SessionManager?
    
    class func createAlamofireSession() {
        //serverTrustPolicy:
        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
        
        // For SSL Pining
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "DomainName" : serverTrustPolicy
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        
        APIManager.sessionManager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }
    
    
    //MARK: Fetch Employee list
    class func fetchEmployeeListFromAPI(completion: @escaping (APIResult<DataResponse<[Employee]>, [Employee]>)->Void) {
        
        let endPoint = EndPoint.getEmployeeList

        print("API Path: \(endPoint.path))")
        print("API Query: \(endPoint.query))")
        print("API Method: \(endPoint.method.rawValue))")

        let request = Request(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: URLEncoding.default, headers: [:])
        
        request?.responseManagedArray(endPoint: endPoint, encoding: URLEncoding.default, saveData: true, entityNameString: "Employee", identifierKey: "id", type: .stringType, keyPath: "data") { (response: DataResponse<[Employee]>) in
            var object = [Employee]()
            if let value = response.result.value {
                object = value
            } else {
                completion(.failure(response, nil))
            }
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(.success(response, object, nil))
            } else {
                completion(.failure(response, response.error))
            }
        }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    class func getNewTokenInformation(completion: @escaping (APIResult<DataResponse<TokenInformationModel>, TokenInformationModel>)->Void) {
        
        var parameters: [String:Any] = [String: Any]()
        parameters["grant_type"] = "refresh_token"
        parameters["scope"] = "offline_access"
        parameters["refresh_token"] = APITokenManager.refreshToken
        parameters["client_id"] = "cashbabaios"
        parameters["client_secret"] = "Rcis123$..123"
        var headersInfo = Alamofire.SessionManager.defaultHTTPHeaders
        headersInfo["Content-Type"] = "application/x-www-form-urlencoded"
        
        let endPoint = EndPoint.getEmployeeList // getNewToken(parameters: parameters)
        
        print("🌿🌿🌿🌿🌿🌿🌿🌿 Get New Token Information After access token expired. 🌿🌿🌿🌿🌿🌿🌿🌿")
        print("🍷🍷 API Call Path: " + endPoint.path)
        print("🍷🍷 \(endPoint.query)")
        print("🍷🍷 API Call method: " + endPoint.method.rawValue)
        
        CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: URLEncoding.default, headers: [:]) { request in
            request?.responseObject(endPoint: endPoint, encoding: URLEncoding.default) { (response: DataResponse<TokenInformationModel>) in
                var object = TokenInformationModel()
                if let value = response.result.value {
                    object = value
                } else {
                    completion(.failure(response, nil))
                }
                
                if let statusCode = response.response?.statusCode, statusCode == 200 {
                    completion(.success(response, object, nil))
                } else {
                    completion(.failure(response, response.error))
                }
            }
        }
    }
    
    class func login(parameters: [String: Any],userName: String, password: String, completion: @escaping (APIResult<DataResponse<TokenInformationModel>, TokenInformationModel>)->Void) {
        
        let endPoint = EndPoint.login(parameters:parameters)
        
        print("🌶🌶 API Call Path: " + endPoint.path)
        print("🌶🌶 \(endPoint.query)")
        print("🌶🌶 API Call method: " + endPoint.method.rawValue)
        let request = Request(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: URLEncoding.default, headers: [:])
        request?.responseObject(endPoint: endPoint, encoding: URLEncoding.default) { (response: DataResponse<TokenInformationModel>) in
            var object = TokenInformationModel()
            if let value = response.result.value {
                object = value
            } else {
                completion(.failure(response, nil))
            }

            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(.success(response, object, nil))
            } else {
                completion(.failure(response, response.error))
            }
        }
    }
}
