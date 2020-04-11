//
//  AlamofireRequestManger.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import Alamofire


public func CheckTokenAlive(
    _ method: HTTPMethod,
    _ urlString: String,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: [String: String]? = nil, completion:@escaping ((_ request: DataRequest?)->Void)) {
        
        if  AuthManager.isTokeAlive() == .accessAlive  {
            var headersInfo: [String: String] = [:]
            
            if let headers = headers, headers.count > 0 {
               headersInfo = headers
            } else {
                headersInfo = Alamofire.SessionManager.defaultHTTPHeaders
            }
            
            if let token = APITokenManager.accessToken {
                headersInfo["Authorization"] = "Bearer \(token)"
            } else {
                headersInfo["Authorization"] = "Bearer "
            }
            
            return completion(Request(method, urlString, parameters: parameters, encoding: encoding, headers: headersInfo))
            
        } else if AuthManager.isTokeAlive() == .refreshAlive  {
            
            print("🌿🌿🌿🌿🌿🌿 Access token expired, calling api for new token 🌿🌿🌿🌿🌿🌿")
            
            APIManager.getNewTokenInformation(){ result in
                switch result {
                case .success(_, let tokenInformation, _):
                    if let loginInformation = tokenInformation {
                        
                        let model = TokenInformationModel()
                        
                        if let accessToken = loginInformation.access_token, accessToken.isNotEmpty {
                            APITokenManager.saveAccessToken(accessToken: accessToken )
                            model.access_token = accessToken
                        }
                        
                        if let refreshToken = loginInformation.refresh_token, refreshToken.isNotEmpty {
                            APITokenManager.saveRefreshToken(refreshToken: refreshToken )
                            model.refresh_token = refreshToken
                        }
                        
                        if let refreshToken = loginInformation.expires_in {
                            model.expires_in = refreshToken
                            APITokenManager.saveExpiraryTime(expTime: String(refreshToken))
                        }
                        
                        if let tokenType = loginInformation.token_type,  tokenType.isNotEmpty{
                            model.token_type = tokenType
                            APITokenManager.saveTokentype(tokenType: tokenType)
                        }
                        
                        APIManager.tokenInfo = model
                        APIManager.tokenInfo?.tokenGenerationTime = Date().timeIntervalSince1970
                        APITokenManager.saveTokenGenerationTime(time: String(Date().timeIntervalSince1970))
                    }
                    var headersInfo = headers ?? Alamofire.SessionManager.defaultHTTPHeaders
                    headersInfo["cashbaba_token"] = "Bearer \(APITokenManager.accessToken!)"
                    
                    return completion(Request(method, urlString, parameters: parameters, encoding: encoding, headers: headersInfo))
                case .failure(_, _):
                    return completion(nil)
                }
            }
        } else  {
            return completion(nil)
        }
}

public func Request(
    _ method: HTTPMethod,
    _ urlString: String,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: [String: String]? = nil)
    -> DataRequest? {
        
        let baseURL: URL = URL(string: "http://118.179.152.102:8081/api/Payment/")!
        
        guard let fullUrl = URL(string: urlString, relativeTo: baseURL) else {
            return nil
        }
        // get the default headers
        let headers = headers ?? Alamofire.SessionManager.defaultHTTPHeaders
        
        let request = APIManager.sessionManager?.request(fullUrl, method: method, parameters: parameters, encoding: encoding, headers: headers)
        return request
}
