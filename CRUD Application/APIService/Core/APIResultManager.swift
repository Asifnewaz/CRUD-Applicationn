//
//  APIResultManager.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection

class APIResultManager {
    
    class func generateSingleObjectResult<T: EVObject>(alamofireResponse: DataResponse<APIResponse>, key: String?) -> APIResult<APIResponse, T> {
        switch alamofireResponse.result {
        case .success(let apiResponse):
            if let statusCode = apiResponse.statusCode, let data = apiResponse.data as? NSObject, statusCode == 200 {
                let modelObject: T = DataRequest.EVReflectionRTObjectSerializer(key, result: data)
                    return .success(apiResponse,modelObject,nil)
            } else if let statusCode = apiResponse.statusCode, statusCode == 200 {
                return .success(apiResponse,nil,nil)
            } else {
                return .failure(apiResponse,nil)
            }
        case .failure(let error):
            return .failure(nil,error)
        }
    }
    
    class func generateSingleObjectResultString(alamofireResponse: DataResponse<APIResponse>, key: String) -> APIResult<APIResponse, String> {
        switch alamofireResponse.result {
        case .success(let apiResponse):
            if let statusCode = apiResponse.statusCode, let data = (apiResponse.data as? [String: Any])?[key] as? String, statusCode == 200 {
                let modelObject: String = data
                return .success(apiResponse,modelObject,nil)
            } else {
                return .failure(apiResponse,nil)
            }
        case .failure(let error):
            return .failure(nil,error)
        }
    }
    
    class func generateSingleObjectResultStringList(alamofireResponse: DataResponse<APIResponse>, key: String) -> APIResult<APIResponse, [String]> {
        switch alamofireResponse.result {
        case .success(let apiResponse):
            if let statusCode = apiResponse.statusCode, let data = (apiResponse.data as? [String: Any])?[key] as? [String], statusCode == 200 {
                let modelObject: [String]  = data
                return .success(apiResponse,modelObject,nil)
            } else {
                return .failure(apiResponse,nil)
            }
        case .failure(let error):
            return .failure(nil,error)
        }
    }
    
    class func generateCollectionObjectsResult<T: EVObject>(alamofireResponse: DataResponse<APIResponse>, key: String) -> APIResult<APIResponse, [T]> {
        switch alamofireResponse.result {
        case .success(let apiResponse):
            if let statusCode = apiResponse.statusCode, let data = apiResponse.data as? NSObject, statusCode == 200 {
                let modelObject: [T] = DataRequest.EVReflectionRTArraySerializer(key, result: data)
                return .success(apiResponse,modelObject,nil)
            } else {
                return .failure(apiResponse,nil)
            }
        case .failure(let error):
            return .failure(nil,error)
        }
    }
}

