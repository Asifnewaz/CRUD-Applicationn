//
//  EVReflectionDataManager.swift
//  CRUD Application
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Asif Newaz. All rights reserved.
//

import Foundation
import CoreData
import EVReflection

public class EVReflectionDataManager {
    
    static var customIdForEmployee: Int = 1000
    static let manager = EVReflectionDataManager()
    // MARK - Helper functions which you usually have in seperate class
    
    init() {
        let stack = try! CoreDataStack(modelName: "CrudOperation")
        moc = stack.mainContext
        boc = stack.backgroundContext
    }
    
    var moc: NSManagedObjectContext! // Main object context should be used for reading
    var boc: NSManagedObjectContext! // Background object context should be used for writing (from service API)
    
    //Generic method for featching data
    func listRecords<T>(_ entityType: T.Type) -> [T] {
        let entityName = String(describing: entityType)
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedList = try moc.fetch(fetch) as! [T]
            return fetchedList
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        return []
    }
    
    //Generic method for clearing data
    func clearRecords<T>(_ entityType: T.Type) {
        let entityName = String(describing: entityType)
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        boc.perform {
            do {
                try self.boc.execute(request)
                try self.boc.save()
                print("🦋 entityName deleted 🦋")
            } catch {
                print("There is an error in deleting records")
            }
        }
    }
    
    //Generic method for updating featching data
    func updateEmployeeName<T>(_ entityType: T.Type, id: String, name: String) -> [T]{
        let entityName = String(describing: entityType)
        let fetchAll = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.predicate = NSPredicate(format: "id = %@", id)
        do {
            let fetchedList = try moc.fetch(fetch) as! [T]
            if let data = fetchedList.first as? NSManagedObject {
                data.setValue(name, forKey: "employee_name")
                do {
                    try self.moc.save()
                    let fetchedList = try moc.fetch(fetchAll) as! [T]
                    return fetchedList
                } catch {
                    print("There is an error in updating records")
                    return []
                }
            } else {
                return []
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
            return []
        }
    }
    
    func setUpID(){
        let list = EVReflectionDataManager.manager.listRecords(Employee.self)
        var idList: [Int] = []
        if list.count > 0 {
            for item in list {
                if let id = item.id, let convertedId = Int(id) {
                    idList.append(convertedId)
                }
            }
        }
        
        if idList.count > 0 {
            if let maxValue = idList.max() {
                print(maxValue)
                EVReflectionDataManager.customIdForEmployee = maxValue + 1
            }
        }
    }
    
    func addEmployee<T>(_ entityType: T.Type, name: String, age: String, salary: String, completion: @escaping ((Bool) -> Void) = { _ in }){
        let entityName = String(describing: entityType)
        let employeeEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc)!
        let employee = NSManagedObject(entity: employeeEntity, insertInto: moc)
        
        employee.setValue(name, forKeyPath: "employee_name")
        employee.setValue(age, forKeyPath: "employee_age")
        employee.setValue(salary, forKeyPath: "employee_salary")
        employee.setValue("\(EVReflectionDataManager.customIdForEmployee)", forKeyPath: "id")
        employee.setValue("", forKeyPath: "profile_image")
        
        EVReflectionDataManager.customIdForEmployee += 1
        print(EVReflectionDataManager.customIdForEmployee)
        do {
            try self.moc.save()
            completion(true)
        } catch {
            print("There is an error in updating records")
            completion(false)
        }
    }
}
