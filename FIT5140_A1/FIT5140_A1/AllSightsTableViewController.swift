//
//  AllSightsTableViewController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import MapKit

class AllSightsTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener,NewLocationDelegate, MKMapViewDelegate{

    let SECTION_SIGHTS = 0;
    let SECTION_COUNT = 1;
    let CELL_SIGHT = "sightCell"
    let CELL_COUNT = "totalSightsCell"
    
    var allSights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()
    //weak var listdid : [Sight]? = nil
    weak var seclectedfromList:Sight? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredSights = allSights
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sights"
        navigationItem.searchController = searchController
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Database Listener
    func onSightsChange(change: DatabaseChange, sights: [Sight]) {
        allSights = sights
        updateSearchResults(for: navigationItem.searchController!)
        mapViewController?.viewWillAppear(true)
    }
    
    
    @IBAction func sorting(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            filteredSights = filteredSights.sorted(by: { (item1, item2) -> Bool in
                return item1.name!.lowercased().compare(item2.name!.lowercased()) == ComparisonResult.orderedAscending
            })
        }else{
            filteredSights = filteredSights.sorted(by: { (item1, item2) -> Bool in
                return item1.name!.lowercased().compare(item2.name!.lowercased()) == ComparisonResult.orderedDescending
            })
        }
        
        tableView.reloadData()
       
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredSights = allSights.filter({(sight: Sight) -> Bool in
                return sight.name!.contains(searchText)
            })
        }
        else {
            filteredSights = allSights;
        }
        tableView.reloadData();
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_SIGHTS {
            return filteredSights.count
        } else {
            return 1
        }
    }
    //method be called whenever is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //print("HI")
        //if indexPath.section == SECTION_SIGHTS{
//            let selectedsight = self.filteredSights[indexPath.row]
//            let name = selectedsight.name!
//            let desc = selectedsight.descriptions!
//            let lat = Double(selectedsight.latitude)
//            let long = Double(selectedsight.longitude)
//            let locationAnnotation = LocationAnnotation(newTitle: name, newSubtitle: desc, lat: lat, long: long)
            //tableView.deselectRow(at:indexPath,animated:false)
            //return
            //call function from mapviewcontroller
//            mapViewController!.focusOn(annotation: locationAnnotation)
//            navigationController?.popViewController(animated: true)
       // }
        let selectedIndexPath = tableView.indexPathsForSelectedRows?.first
        
        seclectedfromList = filteredSights[selectedIndexPath!.row]
        //print("NEXTLINE")
        performSegue(withIdentifier: "backmap", sender: view)

    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.mapViewController?.focusOn(annotation: self.locationList[indexPath.row] as MKAnnotation)
//
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    //create cells in
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        if indexPath.section == SECTION_SIGHTS {
            let sightCell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as!SightTableViewCell
            let sight = filteredSights[indexPath.row]
            
            sightCell.nameLabel.text = sight.name
            sightCell.descriptionsLabel.text = sight.descriptions
            sightCell.iconImageView.image = UIImage(named: sight.icon!)
            
            return sightCell
        }
            
        let countCell = tableView.dequeueReusableCell(withIdentifier: CELL_COUNT, for: indexPath)
        countCell.textLabel?.text = "\(allSights.count) sights in the database"
        countCell.selectionStyle = .none
        return countCell
    }
    
    
    //method be called whenever is selected
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == SECTION_COUNT {
//            tableView.deselectRow(at: indexPath, animated: false)
//            return
//        }
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_SIGHTS {
            return true
        }
        return false
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    //Delete a sight
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedSight = self.filteredSights[indexPath.row]
        if editingStyle == .delete && indexPath.section == SECTION_SIGHTS {
            databaseController?.deleteSight(sight: selectedSight)
        }
        tableView.reloadData();
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetailSegue"{
            let controller: ViewDetailViewController = segue.destination as! ViewDetailViewController
            let selectedIndexPath = tableView.indexPathsForSelectedRows?.first
            controller.selectedSight = filteredSights[selectedIndexPath!.row]
        }
        
        if segue.identifier == "backmap" {
            let controller = segue.destination as! MapViewController
            controller.selectedForFocus = seclectedfromList
            
            
        }
    }
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

 
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
        nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationAnnotationAdded(annotation: LocationAnnotation){
        locationList.append(annotation)
        mapViewController?.mapView.addAnnotation(annotation)
    }
}
