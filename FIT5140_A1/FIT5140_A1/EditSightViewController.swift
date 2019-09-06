//
//  EditSightViewController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import CoreData

class EditSightViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionsTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var iconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    var image: String?
    
    var selectedSight: Sight?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistantContainer?.viewContext
    
        if selectedSight != nil{
            nameTextField.text = selectedSight!.name
            descriptionsTextField.text = selectedSight!.descriptions
            latitudeTextField.text = String(selectedSight!.latitude)
            longitudeTextField.text = String(selectedSight!.longitude)
            if selectedSight?.icon == "museum"
            {iconSegmentedControl.selectedSegmentIndex = 0}
            if selectedSight?.icon == "nationalPark"
            {iconSegmentedControl.selectedSegmentIndex = 1}
            if selectedSight?.icon == "railwayStation"
            {iconSegmentedControl.selectedSegmentIndex = 2}
            if selectedSight?.icon == "restaurant"
            {iconSegmentedControl.selectedSegmentIndex = 3}
            if selectedSight?.icon == "shoppingMall"
            {iconSegmentedControl.selectedSegmentIndex = 4}
            if selectedSight?.image == "default"
            {
                imageView.image = UIImage(named: "museum")
            }
            else
            {
                imageView.image = loadImageData(fileName: (selectedSight?.image)!)
            }
            image = selectedSight?.image
        }
    }
    
    func getIconName () ->String{
        if iconSegmentedControl.selectedSegmentIndex == 0{
            return "museum"
        }
        if iconSegmentedControl.selectedSegmentIndex == 1{
            return "nationalPark"
        }
        if iconSegmentedControl.selectedSegmentIndex == 2{
            return "railwayStation"}
        if iconSegmentedControl.selectedSegmentIndex == 3{
            return "restaurant"}
        if iconSegmentedControl.selectedSegmentIndex == 4{
            return "shoppingMall"}
        return ""
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //save photo and get its id
    func savePhoto() {
        guard let image1 = imageView.image else {
            displayMessage(title:"Error", message:"Cannot save until a photo has been taken!")
            return
        }
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image1.jpegData(compressionQuality: 0.8)!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data,
                                   attributes: nil)
            image = "\(date)"
        }
    }
    
    //After pick
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage(title:"Error", message: "There was an error in getting the image")
    }
    
    //load image
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            if fileData != nil{
            image = UIImage(data: fileData!)
            }
        }
        return image
    }

    @IBAction func saveChangeButton(_ sender: Any) {
        savePhoto()
        if nameTextField.text != "" && descriptionsTextField.text != "" && (Double(latitudeTextField.text!) != nil) && (Double(longitudeTextField.text!) != nil) && getIconName() != "" && image != ""{
            let name = nameTextField.text!
            let descriptions = descriptionsTextField.text!
            let latitude = Double(latitudeTextField.text!)!
            let longitude = Double(longitudeTextField.text!)!
            let icon = getIconName()
            selectedSight!.name = name
            selectedSight!.descriptions = descriptions
            selectedSight!.latitude = latitude
            selectedSight!.longitude = longitude
            selectedSight!.icon = icon
            selectedSight!.image = image
            
            //Reload detail screen
            let i = navigationController?.viewControllers.index(of: self)
            let previousViewController = navigationController?.viewControllers[i!-1]
            previousViewController?.viewDidLoad()
        
            navigationController?.popViewController(animated: true)
            return
        }
        
        var errorMsg = "Please ensure all fields are filled correctly:\n"
        
        if nameTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if descriptionsTextField.text == "" {
            errorMsg += "- Must provide descriptions\n"
        }
        if (Double(latitudeTextField.text!) == nil) {
            errorMsg += "- Must provide a numeric latitude\n"
        }
        if (Double(longitudeTextField.text!) == nil) {
            errorMsg += "- Must provide a numeric longitude\n"
        }
        if getIconName() == "" {
            errorMsg += "- Must choose an icon\n"
        }
        if image == "" {
            errorMsg += "- Must take a photo\n"
        }
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
            nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
