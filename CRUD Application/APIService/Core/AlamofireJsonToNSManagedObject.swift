//
//  AlamofireJsonToNSManagedObject.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation
import EVReflection
import Alamofire
import CoreData

extension DataRequest {
    
    internal static func EVReflectionNSManagedObjSerializer<T: EVManagedObject>(_ keyPath: String?, mapToObject object: T? = nil, saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType)-> DataResponseSerializer<T> {
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
            
            print("response code:  \(String(describing: response?.statusCode))")
            print("result after serialize data:  \(String(describing: result.value))")
            
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
                let manager = EVReflectionDataManager()
                if saveData, response?.statusCode == 200 {
                    let jsonString = String(data: data!, encoding: .utf8)
                    let instance: T = T(context: manager.boc, json: jsonString)
                    do {
                        try manager.boc.save()
                        let status = instance.evReflectionStatus()
                        print("Json parse errors : \(status)")
                    } catch let err {
                        print("\(err)")
                    }
                    
                    let parsedObject: T = ((instance.getSpecificType(JSONToMap!) as? T) ?? instance)
                    let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: parsedObject)
                    if JSONToMap!["data"] != nil {
                        let data = JSONToMap!["data"]
                        parsedObject.setValue(data, forKey: "data")
                        return .success(parsedObject)
                    }
                    return .success(parsedObject)
                } else {
                    let instance: T = T(context: manager.boc)
                    let parsedObject: T = ((instance.getSpecificType(JSONToMap!) as? T) ?? instance)
                    let _ = EVReflection.setPropertiesfromDictionary(JSONToMap!, anyObject: parsedObject)
                    if JSONToMap!["data"] != nil {
                        let data = JSONToMap!["data"]
                        parsedObject.setValue(data, forKey: "data")
                        return .success(parsedObject)
                    }
                    return .success(parsedObject)
                }
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
    open func responseManagedObject<T: EVManagedObject>(endPoint: EndPointCompatible, encoding: URLEncoding, saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataRequest.EVReflectionNSManagedObjSerializer(keyPath, mapToObject: object, saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                ManageUnAuthorizeResponse.ManageUnAuthorizeSessionObject(){ isSuccess in
                    if isSuccess == true {
                        CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: encoding, headers: [:]) { newRequest in
                            newRequest?.responseCustomManagedObject(endPoint: endPoint, encoding: encoding,  saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type ,  completionHandler: { (response: DataResponse<T>) in
                                print(response)
                                return completionHandler(response)
                            })
                        }
                    }
                }
                
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                return completionHandler(dataResponse)
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    @discardableResult
    open func responseCustomManagedObject<T: EVManagedObject>(endPoint: EndPointCompatible, encoding: URLEncoding, saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataRequest.EVReflectionNSManagedObjSerializer(keyPath, mapToObject: object, saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type)
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                return completionHandler(dataResponse)
            }else if let statusCode = dataResponse.response?.statusCode, statusCode == 422 {
                return completionHandler(dataResponse)
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    
    
    internal static func EVReflectionManagedArraySerializer<T: EVManagedObject>(_ keyPath: String?, mapToObject object: T? = nil, saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType) -> DataResponseSerializer<[T]> {
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
            print("response code:  \(String(describing: response?.statusCode))")
            print("result after serialize data:  \(String(describing: result.value))")
            var JSONToMap: NSArray?
            var jsonString: String?
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
            
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: JSONToMap,
                options: .prettyPrinted
                ),
                let jsonStr = String(data: theJSONData,
                                        encoding: String.Encoding.ascii) {
                jsonString =  jsonStr
            }
            
            
            let manager = EVReflectionDataManager()
            
            if response?.statusCode == 200 {
                if saveData {
                    //let jsonString = String(data: data!, encoding: .utf8)
                    let obj = [T](context: manager.boc, json: jsonString, entityNameString: entityNameString, identifierKey: identifierKey, type: type)
                    do {
                        try manager.boc.save()
                        let status = obj.first?.evReflectionStatus() ?? [.None]
                        print("Json parse errors : \(status)")
                    } catch let err {
                        print("\(err)")
                    }
                }
            }
            
            
            let parsedObject:[T] = (JSONToMap!).map {
                let instance: T = T(context: manager.boc)
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
    open func responseManagedArray<T: EVManagedObject>(endPoint: EndPointCompatible, encoding: URLEncoding, saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        let serializer = DataRequest.EVReflectionManagedArraySerializer(keyPath, mapToObject: object, saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type)
        
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                ManageUnAuthorizeResponse.ManageUnAuthorizeSessionObject(){ isSuccess in
                    if isSuccess == true {
                        CheckTokenAlive(endPoint.method, endPoint.path, parameters: endPoint.query, encoding: encoding, headers: [:]) { newRequest in
                            newRequest?.responseCustomManagedArray(endPoint: endPoint, encoding: encoding,  saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type ,  completionHandler: { (response: DataResponse<[T]>) in
                                print(response)
                                return completionHandler(response)
                            })
                        }
                    }
                }
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                //ProgressHUDManager.sharedProgressHUD.end()
                //RCTAPIManager.logoutFromAPI()
                //                AuthManager.manageSessionOut()
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    @discardableResult
    open func responseCustomManagedArray<T: EVManagedObject>(endPoint: EndPointCompatible, encoding: URLEncoding,  saveData: Bool = false, entityNameString: String = "", identifierKey: String = "", type: FetchRequestDataType = .intType, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        let serializer =  DataRequest.EVReflectionManagedArraySerializer(keyPath, mapToObject: object, saveData: saveData, entityNameString: entityNameString, identifierKey: identifierKey, type: type)
        
        response(queue: queue, responseSerializer: serializer, completionHandler: { dataResponse in
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 401 {
                return completionHandler(dataResponse)
            } else if let statusCode = dataResponse.response?.statusCode, statusCode == 403 {
                return completionHandler(dataResponse)
            }else if let statusCode = dataResponse.response?.statusCode, statusCode == 422 {
                return completionHandler(dataResponse)
            } else {
                return completionHandler(dataResponse)
            }
        })
        return self
    }
    
    
}

