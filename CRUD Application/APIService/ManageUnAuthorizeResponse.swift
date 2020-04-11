//
//  ManageUnAuthorizeResponse.swift
//  BoilerCode
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection

class ManageUnAuthorizeResponse {
    
    class func ManageUnAuthorizeSessionObject(completion:@escaping (Bool) -> Void)  {
        
        APIManager.getNewTokenInformation(){ result in
            switch result {
            case .success(_, let tokenInformation, _):
                if let loginInformation = tokenInformation, let accessToken = loginInformation.access_token {
                    
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
                    UserDefaults.standard.synchronize()
                    
                    completion(true)
                    
                } else {
                    completion(false)
                }
                
            case .failure(_, _):
                completion(false)
            }
        }
        
        
    }
    
    
}

