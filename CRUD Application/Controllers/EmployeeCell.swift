//
//  EmployeeCell.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var employeeAge: UILabel!
    @IBOutlet weak var employeeSalary: UILabel!
    @IBOutlet weak var editButton: UIButtonX!
    
    
    var cellVM: EmployeeCellViewModel? {
        didSet {
            self.setupCellData()
        }
    }
    
    func setupCellData(){
        if let name = cellVM?.employeeName, let age = cellVM?.employeeAge, let salary = cellVM?.employeeSalary {
            self.employeeName.text = "Name:   \(String(describing: name))"
            self.employeeAge.text = "Age:    \(String(describing: age))"
            self.employeeSalary.text = "Salary: \(String(describing: salary))"
        }
    }
    
    @IBAction func editEmployee(_ sender: UIButtonX) {
        cellVM?.editButtonSelect?()
    }
}
