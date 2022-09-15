//
//  StorageManager.swift
//  RealmApp
//
//  Created by сергей on 13.09.22.
//

import Foundation
import RealmSwift
let realm = try! Realm()

enum StorageManager {
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll() // удаление всех объектов из баззы данных
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }

    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self) // достаём из реалма все объекты из тасклист
    }
    
    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
        } catch {
            print("saveTasksList  error:\(error)")
        }
    }
    
    static func deleteList(_ tasksList: TasksList) { // принимаем таксклист который нужно удалить
        do {
            try realm.write {
                let tasks = tasksList.tasks // вытаскиваем все задачи
                realm.delete(tasks) // сначала удаляем таски
                realm.delete(tasksList) // удаляем сам список
            }
        } catch {
            print("deleteList error:\(error)")
        }
    }
    
    static func makeAllDone(_ tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.tasks.setValue(true, forKey: "isComplete")
            }
        } catch {
            print("makeAllDone error: \(error)")
        }
    }
    
    static func editList(_ tasksList: TasksList,
                         newListName: String,
                         complition: @escaping () -> Void)
    {
        do {
            try realm.write {
                tasksList.name = newListName
                complition()
            }
        } catch {
            print("editList error")
        }
    }
}
