//
//  EmployeeDetailsViewController.swift
//  CRUD Application
//
//  Created by Asif Newaz on 12/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import UIKit
import Cosmos

class EmployeeDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    var employeeDetailsVM: EmployeeDetailsVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let details = employeeDetailsVM {
            self.initBinding()
            self.setupInitialData(data: details)
        }
    }
    

    private func setupInitialData(data: EmployeeDetailsVM){
        if let name = data.employee.employee_name {
            self.nameLabel.text = "Name: \(name)"
        }
        
        if let ag = data.employee.employee_age {
            self.ageLabel.text = "Age: \(ag)"
            self.employeeDetailsVM?.getRatingsBasedOnAge(age: ag)
        } else {
            self.ratingView.rating = 1.0
        }
        
        if let sl = data.employee.employee_salary {
            self.salaryLabel.text = "Salary: \(sl)"
        }
    }
    
    private func initBinding() {
        self.employeeDetailsVM?.employeeRatings.valueChanged = { [weak self] rate in
            self?.ratingView.rating = rate
        }
    }
}
