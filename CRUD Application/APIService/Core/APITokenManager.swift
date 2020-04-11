//
//  APITokenManager.swift
//  BoilerCode
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation

public class APITokenManager {
    
    static var accessToken: String? {
        if let accessToken = UserDefaults.standard.value(forKey: "AccessToken") as? String {
            return accessToken
        }
        return nil
    }
    
    static var accessTokenExpiraryTime: String? {
        if let expTime = UserDefaults.standard.value(forKey: "TokenExpiraryTime") as? String {
            return expTime
        }
        return nil
    }
    
    static var refreshToken: String? {
        if let refreshToken = UserDefaults.standard.value(forKey: "RefreshToken") as? String {
            return refreshToken
        }
        return nil
    }
    
    
    static var tokenType: String? {
        if let tokenType = UserDefaults.standard.value(forKey: "TokenType") as? String {
            return tokenType
        }
        return nil
    }
    
    
    static var tokenGenerationTime: String? {
        if let tokenType = UserDefaults.standard.value(forKey: "TokenGenerationTime") as? String {
            return tokenType
        }
        return nil
    }
    
    static var userName: String? {
        if let userName = UserDefaults.standard.value(forKey: "username") as? String {
            return userName
        }
        return nil
    }
    
    class func saveUserName(userName: String) {
        do {
            UserDefaults.standard.set(userName, forKey: "username")
            UserDefaults.standard.synchronize()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    class func saveExpiraryTime(expTime: String) {
        do {
            UserDefaults.standard.set(expTime, forKey: "TokenExpiraryTime")
            UserDefaults.standard.synchronize()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    
    class func saveAccessToken(accessToken: String) {
        do {
            UserDefaults.standard.set(accessToken, forKey: "AccessToken")
            UserDefaults.standard.synchronize()
        } catch (let error) {
            print(error.localizedDescription) 
        }
    }
    
    class func saveRefreshToken(refreshToken: String) {
        do {
            UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
            UserDefaults.standard.synchronize()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    class func saveTokentype(tokenType: String) {
        UserDefaults.standard.set(tokenType, forKey: "TokenType")
        UserDefaults.standard.synchronize()
    }
    
    class func saveTokenGenerationTime(time: String){
        UserDefaults.standard.set(time, forKey: "TokenGenerationTime")
        UserDefaults.standard.synchronize()
    }
    
}



extension APITokenManager {
    class func removeUserName() {
        UserDefaults.standard.set(nil, forKey: "username")
        UserDefaults.standard.synchronize()
    }
    
    class func removeAccessToken() {
        UserDefaults.standard.set(nil, forKey: "AccessToken")
        UserDefaults.standard.synchronize()
    }
    
    class func removeExpiraryToken() {
        UserDefaults.standard.set(nil, forKey: "TokenExpiraryTime")
        UserDefaults.standard.synchronize()
    }
    
    class func removeRefreshToken() {
        UserDefaults.standard.set(nil, forKey: "RefreshToken")
        UserDefaults.standard.synchronize()
    }
    
    
    class func removeTokenType() {
        UserDefaults.standard.set(nil, forKey: "TokenType")
        UserDefaults.standard.synchronize()
    }
    
    class func removeTokenGenereationTime() {
        UserDefaults.standard.set(nil, forKey: "TokenGenerationTime")
        UserDefaults.standard.synchronize()
    }
    
}
