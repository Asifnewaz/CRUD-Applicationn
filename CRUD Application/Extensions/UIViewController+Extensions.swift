//
//  UIViewController+Extensions.swift
//  CRUD Application
//
//  Created by Asif Newaz on 12/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func alertWithMessage(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            print("ok")
        })
        navigationController?.present(alert, animated: true)
    }
    
    public func alertWithTextField(title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String?) -> Void) = { _ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion("") })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if let textFields = alert.textFields, let tf = textFields.first, let result = tf.text {
                completion(result)
            } else {
                completion(nil)
            }
        })
        navigationController?.present(alert, animated: true)
    }
    
    public func addNewEmployee(title: String? = nil, message: String? = nil, placeholder1: String? = nil,  placeholder2: String? = nil,  placeholder3: String? = nil, completion: @escaping ((String?, String?, String?) -> Void) = { _,_,_  in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField1 in
            newTextField1.placeholder = placeholder1
        }
        
        alert.addTextField() { newTextField2 in
            newTextField2.placeholder = placeholder2
        }
        
        alert.addTextField() { newTextField3 in
            newTextField3.placeholder = placeholder3
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion(nil, nil, nil) })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if let textFields = alert.textFields {
                let tf1 = textFields[0]
                let tf2 = textFields[1]
                let tf3 = textFields[2]
                completion(tf1.text, tf2.text, tf3.text)
            } else {
                completion(nil, nil, nil)
            }
        })
        navigationController?.present(alert, animated: true)
    }
    
}
