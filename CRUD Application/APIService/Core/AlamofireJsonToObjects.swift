//
//  AlamofireJsonToObjects.swift
//  BoilerCode
//
//  Created by Asif Newaz on 10/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import EVReflection
import Alamofire
import CoreData


extension DataRequest {
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofirejsontoobjects.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    internal static func EVReflectionRTObjectSerializer<T: EVObject>(_ keyPath: String?, result: NSObject, mapToObject object: T? = nil) -> T {
        var JSONToMap: NSDictionary?
        if let keyPath = keyPath , keyPath.isEmpty == false {
            JSONToMap = (result as AnyObject?)?.value(forKeyPath: keyPath) as? NSDictionary
        } else {
            JSONToMap = result as? NSDictionary
        }
        if JSONToMap == nil {
            JSONToMap = NSDictionary()
        }
        
        if object == nil {
            let instance: T = T()
            let parsedObject: T = ((instance.getSpecificType(JSONToMap!) as? T) ?? instance)
            let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: parsedObject)
            return parsedObject
        } else {
            let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: object!)
            return object!
        }
        //}
    }
    
    internal static func EVReflectionRTArraySerializer<T: EVObject>(_ keyPath: String?, result: NSObject, mapToObject object: T? = nil) -> [T] {
        
        var JSONToMap: NSArray?
        if let keyPath = keyPath, keyPath.isEmpty == false {
            JSONToMap = (result as AnyObject?)?.value(forKeyPath: keyPath) as? NSArray
        } else {
            JSONToMap = result as? NSArray
        }
        if JSONToMap == nil {
            JSONToMap = NSArray()
        }
        
        let parsedObject:[T] = (JSONToMap!).map {
            let instance: T = T()
            let _ = EVReflection.setPropertiesfromDictionary($0 as? NSDictionary ?? NSDictionary(), anyObject: instance)
            return instance
            } as [T]
        
        return parsedObject
    }
    
    
    internal static func EVReflectionSerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            
            print("Response code:  \(String(describing: response?.statusCode))")
            print("Result after serialize data:  \(String(describing: result.value))")
            
            var JSONToMap: NSDictionary?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath) as? NSDictionary
            } else {
                JSONToMap = result.value as? NSDictionary
            }
            if JSONToMap == nil {
                JSONToMap = NSDictionary()
            }
            if response?.statusCode ?? 0 > 300 {
                let newDict = NSMutableDictionary(dictionary: JSONToMap! as! [AnyHashable : Any])
                newDict["__response_statusCode"] = response?.statusCode ?? 0
                JSONToMap = newDict
            }
            
            if object == nil {
                let instance: T = T()
                let parsedObject: T = ((instance.getSpecificType(JSONToMap!) as? T) ?? instance)
                let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: parsedObject)
                if JSONToMap!["data"] != nil {
                    let data = JSONToMap!["data"]
                    parsedObject.setValue(data, forKey: "data")
                    return .success(parsedObject)
                }
                return .success(parsedObject)
            } else {
                let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: object!)
                if JSONToMap!["data"] != nil {
                    let data = JSONToMap!["data"]
                    object!.setValue(data, forKey: "data")
                    return .success(object!)
                }
                return .success(object!)
            }
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where EVReflection mapping should be performed
     - parameter object: An object to perform the mapping on to
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by EVReflection.
     
     - returns: The request.
     */
    @discardableResult
    open func responseObject<T: EVObject>(endPoint: EndPointCompatible, encoding: URLEncoding, evObject: T? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataRequest.EVReflectionSerializer(keyPath, mapToObject: object)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                ManageUnAuthorizeResponse.ManageUnAuthorizeSessionObject(){ isSuccess in
                    if isSuccess == true {
                        CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: encoding, headers: [:]) { newRequest in
                            newRequest?.responseCustomObject(endPoint: endPoint, encoding: encoding,  completionHandler: { (response: DataResponse<T>) in
                                print(response)
                                return completionHandler(response)
                            })
                        }
                    } else {
                        //ProgressHUDManager.sharedProgressHUD.end()
                        //RCTAPIManager.logoutFromAPI()
                    }
                }
                
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    @discardableResult
    open func responseCustomObject<T: EVObject>(endPoint: EndPointCompatible, encoding: URLEncoding, evObject: T? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataRequest.EVReflectionSerializer(keyPath, mapToObject: object)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 422 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    
    internal static func EVReflectionArraySerializer<T: EVObject>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in
            
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = newError(.noData, failureReason: failureReason)
                return .failure(error)
            }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            print("Response code:  \(String(describing: response?.statusCode))")
            print("Result after serialize data:  \(String(describing: result.value))")
            var JSONToMap: NSArray?
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath) as? NSArray
            } else {
                JSONToMap = result.value as? NSArray
            }
            if JSONToMap == nil {
                JSONToMap = NSArray()
            }
            
            if response?.statusCode ?? 0 > 300  {
                if JSONToMap?.count ?? 0 > 0 {
                    let newDict = NSMutableDictionary(dictionary: (JSONToMap![0] as? NSDictionary ?? NSDictionary()) as! [AnyHashable : Any])
                    newDict["__response_statusCode"] = response?.statusCode ?? 0
                    let newArray: NSMutableArray = NSMutableArray(array: JSONToMap!)
                    newArray.replaceObject(at: 0, with: newDict)
                    JSONToMap = newArray
                }
                
                // The following code is added to return failed message : By asif : 20/1/2020
                if let JSONData = data {
                    let jsonObject = JSON(data: JSONData)
                    if let message = jsonObject["details"].string {
                        let error = newError(.noData, failureReason: message)
                        return .failure(error)
                    } else if let message = jsonObject["message"].string  {
                        let error = newError(.noData, failureReason: message)
                        return .failure(error)
                    } else {
                        let failureReason = "Data could not be serialized. Input data was nil."
                        let error = newError(.noData, failureReason: failureReason)
                        return .failure(error)
                    }
                }
            }
            
            let parsedObject:[T] = (JSONToMap!).map {
                let instance: T = T()
                let _ = EVReflection.setPropertiesfromDictionary($0 as? NSDictionary ?? NSDictionary(), anyObject: instance)
                return instance
                } as [T]
            
            return .success(parsedObject)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where EVReflection mapping should be performed
     - parameter object: An object to perform the mapping on to (parameter is not used, only here to make the generics work)
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by EVReflection.
     
     - returns: The request.
     */
    @discardableResult
    open func responseArray<T: EVObject>(endPoint: EndPointCompatible, encoding: URLEncoding,  queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        let serializer = DataRequest.EVReflectionArraySerializer(keyPath, mapToObject: object)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                ManageUnAuthorizeResponse.ManageUnAuthorizeSessionObject(){ isSuccess in
                    if isSuccess == true {
                        CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: encoding, headers: [:]) { newRequest in
                            newRequest?.responseCustomArray(endPoint: endPoint, encoding: encoding,  completionHandler: { (response: DataResponse<[T]>) in
                                print(response)
                                return completionHandler(response)
                            })
                        }
                        
                    } else {
                        //ProgressHUDManager.sharedProgressHUD.end()
                        //RCTAPIManager.logoutFromAPI()
                    }
                }
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    @discardableResult
    open func responseCustomArray<T: EVObject>(endPoint: EndPointCompatible, encoding: URLEncoding,  queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        let serializer = DataRequest.EVReflectionArraySerializer(keyPath, mapToObject: object)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            }else if let statusCode = dataResponse.response?.statusCode, statusCode == 422 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter options:           The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseRCTJSON(endPoint: EndPointCompatible, encoding: URLEncoding,
                                queue: DispatchQueue? = nil,
                                options: JSONSerialization.ReadingOptions = .allowFragments,
                                completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Self
    {
        response(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(options: options),
            completionHandler: { dataResponse in
                if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                    return completionHandler(dataResponse)
                } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                    ManageUnAuthorizeResponse.ManageUnAuthorizeSessionObject(){ isSuccess in
                        if isSuccess == true {
                            print("⛳️⛳️⛳️⛳️⛳️")
                            print(endPoint.path)
                            print(endPoint.method)
                            print(endPoint.query)
                            print("⛳️⛳️⛳️⛳️⛳️")
                            CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: encoding, headers: [:]) { newRequest in
                                newRequest?.responseCustomRCTJSON(endPoint: endPoint, encoding: encoding,  completionHandler: { (response: DataResponse<Any>) in
                                    print(response)
                                    return completionHandler(response)
                                })
                            }
                        } else {
                            //ProgressHUDManager.sharedProgressHUD.end()
                            //RCTAPIManager.logoutFromAPI()
                        }
                    }
                } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                    //                    ProgressHUDManager.sharedProgressHUD.end()
                    //                    RCTAPIManager.logoutFromAPI()
                } else {
                    return completionHandler(dataResponse)
                }
        })
        return self
    }
    
    @discardableResult
    public func responseCustomRCTJSON(endPoint: EndPointCompatible, encoding: URLEncoding,
                                      queue: DispatchQueue? = nil,
                                      options: JSONSerialization.ReadingOptions = .allowFragments,
                                      completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Self
    {
        response(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(options: options),
            completionHandler: { dataResponse in
                if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                    return completionHandler(dataResponse)
                } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                    
                } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                    
                } else if let statusCode = dataResponse.response?.statusCode, statusCode == 422 {
                    //                    ProgressHUDManager.sharedProgressHUD.end()
                    //                    RCTAPIManager.logoutFromAPI()
                    
                } else {
                    return completionHandler(dataResponse)
                }
        })
        return self
    }
}

