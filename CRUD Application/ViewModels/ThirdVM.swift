//
//  ThirdVM.swift
//  CRUD Application
//
//  Created by Asif Newaz on 12/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation

class ThirdVM: NSObject {
    
    var cellViewModels = Observable([EmployeeCellViewModel]())
    var cellViewModelsFiltered = [EmployeeCellViewModel]()
    var isLoading = Observable(false)
    
    
    override init() {
    }
    
    func getEmplyeeList(id: Int = 0){
        self.isLoading.value = true
        let manager = EVReflectionDataManager()
        var list = manager.listRecords(Employee.self)
        
        if list.count > 0 {
            self.isLoading.value = false
            if id == 0 {
                list = list.filter({ $0.getConvertedSalary() > 300000 })
            } else if id == 1 {
                list = list.filter({ ($0.getConvertedSalary() < 300000) && ($0.getConvertedSalary() > 100000) })
            } else  {
                list = list.filter({ $0.getConvertedSalary() < 100000 })
            }
            
            self.buildViewModels(list: list.sorted(by: {$0.getEmployeeName() < $1.getEmployeeName()}))
        }
    }
    
    
    private func buildViewModels(list: [Employee]) {
        let dataList = list.map { (item) -> EmployeeCellViewModel in
            let vm = EmployeeCellViewModel(employeeId: item.id, employeeName: item.employee_name, employeeSalary: item.employee_salary, employeeAge: item.employee_age, employeeImage: item.profile_image)
            return vm
        }
        self.cellViewModels.value = dataList
        self.cellViewModelsFiltered = dataList
    }
    

}
