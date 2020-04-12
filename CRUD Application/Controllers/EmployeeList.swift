//
//  ViewController.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import UIKit

class EmployeeList: UIViewController {
    
    @IBOutlet weak var employeeTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var progressHUD: ProgressHUDManager?
    var isCardListEmpty: Bool = false
    
    lazy var viewModel : EmployeeListViewModel = {
        let viewModel = EmployeeListViewModel()
        return viewModel
    }()
    
    deinit {
        print("OS Recalling memory -- No retain cycle/leak!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialData()
        self.initBinding()
        self.viewModel.getEmplyeeList()
    }
    
    private func setupInitialData(){
        self.hideKeyboardWhenTappedAround()
        self.searchBar.delegate = self
        self.employeeTableView.delegate = self
        self.employeeTableView.dataSource = self
        self.employeeTableView.separatorStyle = .none
        self.employeeTableView.tableFooterView = UIView()
    }
    
    private func initBinding() {
        self.viewModel.cellViewModels.valueChanged = { [weak self] (_) in
            self?.employeeTableView.reloadData()
        }
        
        self.viewModel.isLoading.valueChanged = { [weak self] isLoading in
            if isLoading {
                self?.showLoader()
            } else {
                self?.hideLoader()
            }
        }
        
        self.viewModel.navigateToEmployeeInfo = { [weak self] data in
            print(data)
            let vm = EmployeeDetailsVM(data: data)
            self?.navigateToEmployeeInfo(vm: vm)
        }
        
        self.viewModel.editEmployeeInfo = { [weak self] data in
            if let id = data.id {
                self?.alertWithTextField(title: "Edit", message: "", placeholder: "Employee name") { [weak self] result in
                    if let name =  result, name.isNotEmpty {
                        self?.viewModel.updateEmployeeName(id: id, name: name)
                    }
                }
            }
        }
    }
    
    private func showLoader() {
        self.progressHUD = ProgressHUDManager(view: self.view)
        self.progressHUD?.start()
        self.progressHUD?.isNeedShowSpinnerOnly = true
    }
    
    private func hideLoader() {
        self.progressHUD?.end()
    }
    
    private func navigateToEmployeeInfo(vm: EmployeeDetailsVM){
        let storyBoad = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailsVC = storyBoad.instantiateViewController(withIdentifier: "EmployeeDetailsViewController") as! EmployeeDetailsViewController
        detailsVC.employeeDetailsVM = vm
        self.navigationController?.show(detailsVC, sender: nil)
    }
    
    @IBAction func addEmployeeAction(_ sender: UIBarButtonItem) {
        self.addNewEmployee(title: "Add Employee", message: "", placeholder1: "Name", placeholder2: "Age", placeholder3: "Salary") { [weak self] name, age, salary  in
            if let name =  name, let ag = age, let sl = salary {
                self?.viewModel.addEmployeeInDB(name: name, age: ag, salary: sl)
            } 
        }
    }
    
    @IBAction func filterAction(_ sender: UIBarButtonItem) {
        self.alertWithMessage(title: "Sorry", message: "Task was not clear and understandable.") 
    }
    
    
    
}



extension EmployeeList : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.viewModel.cellViewModels.value = self.viewModel.cellViewModelsFiltered
            return
        }
        self.viewModel.filterEmployee(text: searchText)
    }
}



extension EmployeeList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cellViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeCell
        if self.viewModel.cellViewModels.value.count > 0 {
            let employee = self.viewModel.cellViewModels.value[indexPath.row]
            cell.cellVM = employee
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewModel.cellViewModels.value.count > 0 {
            let cellVM = self.viewModel.cellViewModels.value[indexPath.row]
            cellVM.employeeDidSelect?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
}

