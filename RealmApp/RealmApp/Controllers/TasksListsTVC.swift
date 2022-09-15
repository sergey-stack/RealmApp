//
//  TasksListsTVC.swift
//  RealmApp
//
//  Created by сергей on 13.09.22.
//

import RealmSwift
import UIKit

class TasksListsTVC: UITableViewController {
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // StorageManager.deleteAll()
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    // MARK: - Table view data source

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tasksList = tasksLists[indexPath.row]
        cell.textLabel?.text = tasksList.name
        cell.detailTextLabel?.text = tasksList.tasks.count.description // дескрип переведёт инт в строчку
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green
        let swipeAtion = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])
        return swipeAtion
    }

    // MARK: - Table view delegate

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks { [weak self] in
            self?.navigationItem.title = "alertForAddAndUpdatesListTasks"
            print("ListTasks")
        }
    }

    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil,
                                                complition: @escaping () -> Void)
    {
        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButtonName = tasksList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else {
                return
            }

            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName, complition: complition)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
                self.tableView.reloadData()
                //                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
            }
        }

        //  @objc  func addBarButtonSystemItemSelector() {
//      let title = "New List"
//      let message = "Please insert list name"
//       let doneBtnName = "Save"
//
//      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)//принимает 3 параметра
//
//      var alerTextField:UITextField!//создаём текстфилд
//      alert.addTextField{ textField in
//          alerTextField = textField
//          alerTextField.placeholder = "List Name"
//      }
//
//      let saveAction = UIAlertAction(title: doneBtnName, style: .default){ _ in
//          guard let newListName = alerTextField.text, !newListName.isEmpty else {//из текстфилдов вытаскиваем новое имя
//              return
//          }
//          let tasksList = TasksList()//создание экземпляра
//          tasksList.name = newListName
//
//          StorageManager.saveTasksList(tasksList: tasksList)
//         // self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .fade)
//          self.tableView.reloadData()
//      }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
