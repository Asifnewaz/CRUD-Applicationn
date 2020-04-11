//
//  EmployeeListViewModel.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation

class EmployeeListViewModel: NSObject {
    
    var cellViewModels = Observable([EmployeeCellViewModel]())
    var cellViewModelsFiltered = [EmployeeCellViewModel]()
    var isLoading = Observable(false)
    var navigateToEmployeeInfo: ((Employee) -> Void)?
    var editEmployeeInfo: ((Employee) -> Void)?
    
    
    override init() {
    }
    
    func getEmplyeeList(){
        self.isLoading.value = true
        let manager = EVReflectionDataManager()
        let list = manager.listRecords(Employee.self)
        
        if list.count > 0 {
            self.isLoading.value = false
            self.buildViewModels(list: list.sorted(by: {$0.getEmployeeName() < $1.getEmployeeName()}))
        } else {
            self.getEmplyeeListByAPI()
        }
    }
    
    func getEmplyeeListByAPI(){
        APIManager.fetchEmployeeListFromAPI(completion: {[weak self] result in
            self?.isLoading.value = false
            switch result {
            case .success(_, let transactionResponse, _) :
                if let transacResp = transactionResponse {
                    self?.buildViewModels(list: transacResp.sorted(by: {$0.getEmployeeName() < $1.getEmployeeName()}))
                }
            case .failure(_, _):
                break
            }
        })
    }
    
    private func buildViewModels(list: [Employee]) {
        let dataList = list.map { (item) -> EmployeeCellViewModel in
            let vm = EmployeeCellViewModel(employeeId: item.id, employeeName: item.employee_name, employeeSalary: item.employee_salary, employeeAge: item.employee_age, employeeImage: item.profile_image)
            vm.employeeDidSelect = { [weak self] in
                self?.employeeSelect(item: item)
            }
            vm.editButtonSelect = { [weak self] in
                self?.employeeEditButtonSelect(item: item)
            }
            return vm
        }
        self.cellViewModels.value = dataList
        self.cellViewModelsFiltered = dataList
        print(self.cellViewModelsFiltered.count)
    }

    private func employeeSelect(item: Employee) {
        self.navigateToEmployeeInfo?(item)
    }
    
    private func employeeEditButtonSelect(item: Employee) {
        self.editEmployeeInfo?(item)
    }

    func filterEmployee(text: String){
        self.cellViewModels.value = cellViewModelsFiltered.filter({ vm -> Bool in
            (vm.getEmployeeName().lowercased().contains(text.lowercased()))
        })
        print(self.cellViewModels.value.count)
    }
    
    
    func updateEmployeeName(id: String, name: String){
        let manager = EVReflectionDataManager()
        let list = manager.updateEmployeeName(Employee.self, id: id, name: name)
        
        if list.count > 0 {
            self.isLoading.value = false
            self.buildViewModels(list: list.sorted(by: {$0.getEmployeeName() < $1.getEmployeeName()}))
        } else {
            self.getEmplyeeListByAPI()
        }
    }
    
    func addEmployeeInDB(name: String, age: String, salary: String){
        let manager = EVReflectionDataManager()
        manager.setUpID()
        manager.addEmployee(Employee.self, name: name, age: age, salary: salary) { [weak self] isAdded in
            if isAdded {
                self?.getEmplyeeList()
            }
        }
    }
}



