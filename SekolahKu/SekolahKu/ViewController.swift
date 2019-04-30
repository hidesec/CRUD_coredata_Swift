//
//  ViewController.swift
//  SekolahKu
//
//  Created by sarkom3 on 26/04/19.
//  Copyright © 2019 sarkom3. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var studentID = 0
    var students:[Students] = []
    var filteredStudents:[Students] = []
    
    //Simple contains
    var simpleArray = ["Jakarta", "Malang", "Surabaya", "Bandung"]

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //search
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //logic simple contains
        if simpleArray.contains("Jakarta"){
            print("Success")
        }else{
            print("Failure")
        }
    }
    
    func setupView(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        //set search controller ke TableView
        //set placehoder
        searchController.searchBar.placeholder = "Find Students"
        //navigasi akan hilang ketika kita klik x
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
        
        //set search controller ke tableView di header tableview
        tableView.tableHeaderView = searchController.searchBar
        
        self.navigationItem.title = "Sekolah"
        //set background color
        self.navigationController?.navigationBar.barTintColor =  UIColor(red: 0.14, green: 0.86, blue: 0.73, alpha: 1.0)
        //set item color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //title color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //title large color
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get data Students entities
        do{
            let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
            students = try context.fetch(studentFetch) as! [Students]
        }catch{
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !((searchController.searchBar.text?.isEmpty)!){
            return filteredStudents.count
        }
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let student = students[indexPath.row]
        var student: Students
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        //configure the cell...
        if searchController.isActive && !((searchController.searchBar.text?.isEmpty)!){
            student = filteredStudents[indexPath.row]
        }else{
            student = students[indexPath.row]
        }
        //convert Binary data to Image
        let image:UIImage = UIImage(data: student.image!)!
        cell.titleCell.text = student.firstName
        cell.subtitleCell.text = student.email
        cell.imageCell.image = image
        
        //mengatur gambar
        cell.imageCell.layer.cornerRadius = cell.imageCell.frame.height / 2
        cell.imageCell.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailController") as! DetailController
        controller.studentID = Int(students[indexPath.row].id)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let keyword = searchController.searchBar.text!
        if keyword.count > 0 {
            print("kata kunci = \(keyword)")
            let studentSearch = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
            
            let predicate1 = NSPredicate(format: "firstName CONTAINS[c] %@", keyword)
            let predicate2 = NSPredicate(format: "lastName CONTAINS[c] %@", keyword)
            
            let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
            studentSearch.predicate = predicateCompound
            
            //run query
            do{
                let studentFilters = try context.fetch(studentSearch) as! [NSManagedObject]
                filteredStudents = studentFilters as! [Students]
            }catch{
                print(error)
            }
        }
        self.tableView.reloadData()
    }
}
