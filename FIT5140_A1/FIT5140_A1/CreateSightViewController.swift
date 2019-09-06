//
//  CreateSightViewController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol NewLocationDelegate{
    func locationAnnotationAdded(annotation: LocationAnnotation)
}

class CreateSightViewController: UIViewController, UIImagePickerControllerDelegate,CLLocationManagerDelegate, UINavigationControllerDelegate {

    weak var databaseController: DatabaseProtocol?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var delegate: NewLocationDelegate?
    var image: String?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionsTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    @IBOutlet weak var iconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Get the database controller once from the App Delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        managedObjectContext = appDelegate.persistantContainer?.viewContext
        image = ""
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation{
            latTextField.text = "\(currentLocation.latitude)"
            longTextField.text = "\(currentLocation.longitude)"
        }
        else{
            let alertController = UIAlertController(title:"Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    //Get icon's name which is choosed
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
    
    //screen for choosing a picture
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
   
    
    
    //create and validation
    @IBAction func createSight(_ sender: Any) {
        savePhoto()
        if nameTextField.text != "" && descriptionsTextField.text != "" && vaildlat()&&vaildlon()&&(Double(latTextField.text!) != nil) && (Double(longTextField.text!) != nil) && getIconName() != "" && image != ""{
            let name = nameTextField.text!
            let descriptions = descriptionsTextField.text!
            let latitude = Double(latTextField.text!)!
            let longitude = Double(longTextField.text!)!
            let icon = getIconName()
            let _ = databaseController!.addSight(name: name, descriptions: descriptions, latitude: latitude, longitude: longitude, icon: icon, image: image!)
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
        if (Double(latTextField.text!) == nil) {
            errorMsg += "- Must provide a numeric latitude\n"
        }
        if (Double(longTextField.text!) == nil) {
            errorMsg += "- Must provide a numeric longitude\n"
        }
        if vaildlat() == false{
            errorMsg += "-latitude Must in range\n"
        }
        if vaildlon() == false{
            errorMsg += "-longitude Must in range\n"
        }
        if getIconName() == "" {
            errorMsg += "- Must choose an icon\n"
        }
        if image == "" {
            errorMsg += "- Must take a photo\n"
        }
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    
    func vaildlon() -> Bool {
        if (Double(longTextField.text!) != nil){
        let lonva = Double(longTextField.text!)!
        
        if(lonva < 180.0000 && lonva > -180.0){
            return true
            
        }
        
        }
        return false
    }
    
    func vaildlat() -> Bool {
        if (Double(latTextField.text!) != nil){
            let latva = Double(latTextField.text!)!
            
            if(latva < 90.0000 && latva > -90.0){
                return true
                
            }
            
        }
        return false
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
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

