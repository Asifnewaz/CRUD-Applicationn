//
//  EmployeeCellViewModel.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation

class EmployeeCellViewModel {
    var employeeId: String?
    var employeeName: String?
    var employeeSalary: String?
    var employeeAge: String?
    var employeeImage: String?
    var employeeDidSelect: (() -> Void)?
    var editButtonSelect: (() -> Void)?
    
    init(employeeId: String?, employeeName: String?, employeeSalary: String?, employeeAge: String?, employeeImage: String?) {
        self.employeeId = employeeId
        self.employeeName = employeeName
        self.employeeSalary = employeeSalary
        self.employeeAge = employeeAge
        self.employeeImage = employeeImage
    }
    
    func getEmployeeName() -> String {
        if let name = employeeName {
            return name
        }
        return ""
    }
    
    func getConvertedSalary() -> Double {
        if let salary = employeeSalary, let convertedSalary = Double(salary) {
            return convertedSalary
        }
        return 0.0
    }
}
