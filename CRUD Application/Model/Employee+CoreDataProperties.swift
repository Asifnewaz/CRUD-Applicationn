//
//  Employee+CoreDataProperties.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var id: String?
    @NSManaged public var employee_name: String?
    @NSManaged public var employee_salary: String?
    @NSManaged public var employee_age: String?
    @NSManaged public var profile_image: String?

    func getEmployeeName() -> String {
        if let name = employee_name {
            return name
        }
        return ""
    }
    
    func getConvertedSalary() -> Double {
        if let salary = employee_salary, let convertedSalary = Double(salary) {
            return convertedSalary
        }
        return 0.0
    }
}
