//
//  ViewDetailViewController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit

class ViewDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionsLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBAction func editSightButton(_ sender: Any) {
    }
    @IBAction func viewInMapButton(_ sender: Any) {
    }
    
    var selectedSight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if selectedSight != nil{
            imageView.image = loadImageData(fileName: (selectedSight?.image)!)
            nameLabel.text = "Name: " + selectedSight!.name!
            descriptionsLabel.text = "Descriptions: " + selectedSight!.descriptions!
            latitudeLabel.text = "Latitude: \(selectedSight!.latitude)"
            longitudeLabel.text = "Longitude: \(selectedSight!.longitude)"
            iconImageView.image = UIImage(named: selectedSight!.icon!)
        }
    }
    

    //load image
    func loadImageData(fileName: String) -> UIImage? {
        switch fileName {
        case "Melbourne Museum":
            return UIImage(named: "Melbourne Museum")
        case "Immigration Museum":
            return UIImage(named: "Immigration Museum")
        case "Old Melbourne Gaol":
            return UIImage(named: "Old Melbourne Gaol")
        case "Yarra Bend Park":
            return UIImage(named: "Yarra Bend Park")
        case "Albert Park":
            return UIImage(named: "Albert Park")
            
        case "NGV":
            return UIImage(named: "NGV")
        case "Burnswick":
            return UIImage(named: "Burnswick")
        case "QVM":
            return UIImage(named: "QVM")
        case "sk":
            return UIImage(named: "sk")
        case "Royal Exhibition Building":
            return UIImage(named: "Royal Exhibition Building")
        case "Curtin House":
            return UIImage(named: "Curtin House")
        case "Chinatown":
            return UIImage(named: "Chinatown")
        case "Great Ocean Road":
            return UIImage(named: "Great Ocean Road")
            
        case "Phillip Island":
            return UIImage(named: "Phillip Island")
        case "Federation Square":
            return UIImage(named: "Federation Square")
            
        case "Melbourne Zoo":
            return UIImage(named: "Melbourne Zoo")
        default:
            break
        }
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSightSegue"{
            let controller: EditSightViewController = segue.destination as! EditSightViewController
            controller.selectedSight = self.selectedSight
        }
    }

}
