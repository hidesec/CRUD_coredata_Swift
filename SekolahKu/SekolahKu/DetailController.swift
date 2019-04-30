//
//  DetailController.swift
//  SekolahKu
//
//  Created by sarkom3 on 29/04/19.
//  Copyright © 2019 sarkom3. All rights reserved.
//

import UIKit
import CoreData

class DetailController: UIViewController {

    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var labelLastName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelBirthOfDate: UILabel!
    
    var studentID = 0
    //core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        print(studentID)
    }
    
    //setup edit button
    func setupView(){
        let editButton = UIBarButtonItem(image: UIImage(named: "pencil"), style: .plain, target: self, action: #selector(edit))
        let trashButton = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(deleteButton))
        self.navigationItem.rightBarButtonItems = [editButton, trashButton]
    }
    @objc func edit(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "StudentFormController") as! StudentFormController
        controller.StudentID = studentID
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @objc func deleteButton(){
        let alertController = UIAlertController(title: "Warning!", message: "Are you sure to delete this item", preferredStyle: .actionSheet)
        let aletActionYes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
            studentFetch.fetchLimit = 1
            studentFetch.predicate = NSPredicate(format: "id == \(self.studentID)")
            
            //run query
            let result = try! self.context.fetch(studentFetch)
            let studentToDelete = result[0] as! NSManagedObject
            self.context.delete(studentToDelete)
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let alertAtionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(aletActionYes)
        alertController.addAction(alertAtionNo)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //get data student by field id
        let studentData = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
        studentData.fetchLimit = 1
        
        //kondisi dengan predicate
        studentData.predicate = NSPredicate(format: "id == \(studentID)")
        
        //run
        let result = try! context.fetch(studentData)
        let student: Students = result.first as! Students
        
        labelFirstName.text = student.firstName
        labelLastName.text = student.lastName
        labelEmail.text = student.email
        labelBirthOfDate.text = student.birthDate
        
        if let imageData = student.image {
            imageDetail.image = UIImage(data: imageData as Data)
            imageDetail.layer.cornerRadius = imageDetail.frame.height / 2
            imageDetail.clipsToBounds = true
        }
        self.navigationItem.title = student.firstName
    }
}
