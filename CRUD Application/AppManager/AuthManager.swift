//
//  AuthManager.swift
//  BoilerCode
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
public enum TokenAlive {
    case accessAlive
    case refreshAlive
    case allExpired
}

public class AuthManager {
    public class func isRefreshTokenAlive() -> Bool? {
        if let refreshToken = APIManager.tokenInfo?.refresh_token, refreshToken.isNotEmpty, let expire = APIManager.tokenInfo?.expires_in {
            let currentDateTime = Date().timeIntervalSince1970
            let timeDifference: Double = currentDateTime - (APIManager.tokenInfo?.tokenGenerationTime)!
            if timeDifference < expire {
                return true
            } else {
                return true
            }
        } else {
            return false
        }
        
    }
    
    public class func isAccessTokenAlive() -> Bool? {
        if let accessToken = APIManager.tokenInfo?.access_token, accessToken.isNotEmpty, let expire = APIManager.tokenInfo?.expires_in {
            let currentDateTime = Date().timeIntervalSince1970
            let timeDifference: Double = currentDateTime - (APIManager.tokenInfo?.tokenGenerationTime)!
            
            if timeDifference < expire {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    class func isTokeAlive() -> TokenAlive {
        if AuthManager.isRefreshTokenAlive()! {
            if AuthManager.isAccessTokenAlive()! {
                return  .accessAlive
            } else {
                return .refreshAlive
            }
        } else {
            return .allExpired
        }
    }
}
