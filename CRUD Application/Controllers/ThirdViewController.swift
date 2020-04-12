//
//  ThirdViewController.swift
//  CRUD Application
//
//  Created by Asif Newaz on 12/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalNumberLabel: UILabel!
    
    var progressHUD: ProgressHUDManager?
    
    lazy var viewModel : ThirdVM = {
        let viewModel = ThirdVM()
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialData()
        initBinding()
        self.viewModel.getEmplyeeList()
    }
    
    @IBAction func salaryCaregory(_ sender: UISegmentedControl) {
        self.viewModel.getEmplyeeList(id: sender.selectedSegmentIndex)
    }
    
    private func setupInitialData(){
        self.hideKeyboardWhenTappedAround()
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
    }
    
    
    private func initBinding() {
        self.viewModel.cellViewModels.valueChanged = { [weak self] (_) in
            if let count = self?.viewModel.cellViewModels.value.count {
                self?.totalNumberLabel.text = "Total: \(String(describing: count)) employee"
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.isLoading.valueChanged = { [weak self] isLoading in
            if isLoading {
                self?.showLoader()
            } else {
                self?.hideLoader()
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

}


extension ThirdViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cellViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell2", for: indexPath) as! EmployeeCell
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
}
