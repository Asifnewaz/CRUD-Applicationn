//
//  EmployeeDetailsVM.swift
//  CRUD Application
//
//  Created by Asif Newaz on 12/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation

class EmployeeDetailsVM {
    var employeeRatings = Observable(0.0)
    var employee: Employee
    
    init(data: Employee) {
        self.employee = data
    }
    
    func getRatingsBasedOnAge(age: String){
        if let convertedAge = Double(age) {
            if convertedAge >= 50 {
                employeeRatings.value = 5.0
            } else if convertedAge >= 40 {
                employeeRatings.value = 4.0
            } else if convertedAge >= 30 {
                employeeRatings.value = 3.0
            } else if convertedAge >= 20 {
                employeeRatings.value = 2.0
            } else {
                employeeRatings.value = 1.0
            }
        }
    }
}
