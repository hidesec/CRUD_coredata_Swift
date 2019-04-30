//
//  StudentFormController.swift
//  SekolahKu
//
//  Created by sarkom3 on 26/04/19.
//  Copyright © 2019 sarkom3. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import Photos

class StudentFormController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var firstNAmeTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var imageStudent: UIImageView!
    
    var StudentID = 0
    
    let imagePicker = UIImagePickerController()
    
    //deklarasi core data dari app delegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        checkpermission()
        
        self.navigationItem.title = "Form Student"
        //set background color
        self.navigationController?.navigationBar.barTintColor =  UIColor(red: 0.14, green: 0.86, blue: 0.73, alpha: 1.0)
        //set item color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //title color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if StudentID != 0{
            //same var data = []()
            let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
            studentFetch.fetchLimit = 1
            
            //kondisi dengan predicate
            studentFetch.predicate = NSPredicate(format: "id == \(StudentID)")
            
            //run
            let result = try! context.fetch(studentFetch)
            let student: Students = result.first as! Students
            
            firstNAmeTextField.text = student.firstName
            lastNameTextField.text = student.lastName
            emailTextField.text = student.email
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.date(from: student.birthDate!)
            
            datePicker.date = date!
            
            imageStudent.image = UIImage(data: student.image!)
        }
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        guard let firstName = firstNAmeTextField.text, firstName != "" else{
            let alertController = UIAlertController(title: "Warning", message: "First Name is Required", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "yes", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard let lastName = lastNameTextField.text, lastName != "" else{
            let alertController = UIAlertController(title: "Warning", message: "Last Name is Required", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "yes", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard let email = emailTextField.text, email != "" else{
            let alertController = UIAlertController(title: "Warning", message: "Email is Required", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "yes", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let birthDate = dateFormatter.string(from: datePicker.date)
        
        //check apakah dari halaman edit atau tidak
        if StudentID > 0 {
            let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Students")
            studentFetch.fetchLimit = 1
            
            //kondisi dengan predicate
            studentFetch.predicate = NSPredicate(format: "id == \(StudentID)")
            
            //run
            let result = try! context.fetch(studentFetch)
            let studentToEdit = result.first as! Students
            
            //set field core data
            studentToEdit.firstName = firstName
            studentToEdit.lastName = lastName
            studentToEdit.email = email
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let stringDate = dateFormatter.string(from: datePicker.date)
            studentToEdit.birthDate = stringDate
            
            if let img = imageStudent.image{
                let data = img.pngData() as NSData?
                studentToEdit.image = data as Data?
            }
            
            //save ke coredata
            do{
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } else{
            //add ke Student entity
            let student = Students(context: context)
            
            //auto increment id
            let request:NSFetchRequest = Students.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1
            
            var maxID = 0
            do{
                let lastStudent = try context.fetch(request)
                maxID = Int(lastStudent.first?.id ?? 0)
            }catch{
                print(error.localizedDescription)
            }
            
            student.id = Int32(maxID) + 1
            student.firstName = firstName
            student.lastName = lastName
            student.email = email
            student.birthDate = birthDate
            
            if let img = imageStudent.image{
                let data = img.pngData() as NSData?
                student.image = data as Data?
            }
            
            do{
                try context.save()
            }catch{
                print(error.localizedDescription)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonAmbilGambar(_ sender: Any) {
        self.selectPhotoFromGallery()
    }
    
    func selectPhotoFromGallery(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageStudent.contentMode = .scaleAspectFill
            self.imageStudent.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkpermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized{
                    print("success")
                }
            }
        case .restricted:
            print("user do not have access to photo album")
        case .denied:
            print("user has denied the permission")
        @unknown default:
            print("something")
        }
    }
}
