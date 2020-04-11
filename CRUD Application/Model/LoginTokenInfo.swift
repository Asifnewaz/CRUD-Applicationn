//
//  LoginTokenInfo.swift
//  BoilerCode
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import EVReflection


public class TokenInformationModel: EVObject {
    var token_type : String?
    var expires_in : Double?
    var access_token : String?
    var refresh_token: String?
    var role: String?
    
    var refreshTokenExpiresIn: String?
    var tokenGenerationTime: Double?
    
    // Device Update Data Model
    var message : String?
    var details: String?
    var code: String?
    var statusCode: Int?
    var idenitifier: String?
    
    // Errors
    var error: String?
    var error_description: String?
    var errors: LoginErrorResponse?
    var title: String?
    var status: String?
    var traceId: String?
}

public class LoginErrorResponse: EVObject {
    var Scope: [String]?
    var DeviceId: [String]?
    var DeviceName: [String]?
    var DeviceModel: [String]?
    var GrantType: [String]?
}
