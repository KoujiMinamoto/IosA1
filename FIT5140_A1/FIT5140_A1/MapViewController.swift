//
//  MapViewController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,  MKMapViewDelegate,DatabaseListener ,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var allSight: [Sight] = []
    var filteredsight: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var locationList = [LocationAnnotation]()
   
    var locationManager: CLLocationManager = CLLocationManager()

    var selectedForFocus: Sight?




    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        self.mapView.delegate = self

        filteredsight = allSight

        //let CBD = CLLocation(latitude: -37.8124, longitude: 144.9623)
        //let region = MKCoordinateRegion(center: CBD.coordinate, latitudinalMeters: 7000, longitudinalMeters: 7000)
        //mapView.setRegion(region, animated: true)
        
        
        //locationList = [LocationAnnotation(newTitle: selectedForFocus!.name!, newSubtitle: selectedForFocus!.descriptions!, lat:Double( selectedForFocus!.latitude), long: Double(selectedForFocus!.longitude))]
        if selectedForFocus != nil {
           
           focusOn(annotation: LocationAnnotation(newTitle: selectedForFocus!.name!, newSubtitle: selectedForFocus!.descriptions!, lat: Double(selectedForFocus!.latitude), long: Double(selectedForFocus!.longitude)))
            
        }
        else
        {
            let CBD = CLLocation(latitude: -37.8124, longitude: 144.9623)
            let region = MKCoordinateRegion(center: CBD.coordinate, latitudinalMeters: 7000, longitudinalMeters: 7000)
            mapView.setRegion(region, animated: true)
            
            
        }
       



        //

    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }






    func onSightsChange(change: DatabaseChange, sights: [Sight]) {
        allSight = sights

        let allAnnotations = mapView.annotations

        for j in allAnnotations{
            mapView.removeAnnotation(j)
        }

        for i in allSight{
            let location = LocationAnnotation(newTitle: i.name!, newSubtitle: i.descriptions!, lat: i.latitude, long: i.longitude)
            locationList.append(location)
            mapView.addAnnotation(location)
            var geoLocation = CLCircularRegion(center: location.coordinate, radius: 500, identifier: location.title!)
            geoLocation.notifyOnExit = true
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: geoLocation)

        }

    }

    func mapView(mapview: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if !(annotation is MKPointAnnotation) {
            return nil
        }

        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapview.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }else{
            annotationView!.annotation = annotation
        }

        //didnt work
        let pinImage = UIImage(named: "a")
        annotationView!.image = pinImage

        return annotationView
    }



    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
      
        
            
        
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "detailSegue"{
            let destination = segue.destination as! ViewDetailViewController
            let selectedAnnotation = mapView.selectedAnnotations[0]
            var indexOfAnnotation = 0

            for i in locationList{
                if selectedAnnotation.title == i.title{
                    //print("\(selectedAnnotation.title) and \(i.title) match")
                    break
                }else{
                    //print("\(selectedAnnotation.title) and \(i.title) not")
                    indexOfAnnotation += 1
                }
                //print(indexOfAnnotation)
            }

            // print(selectedAnnotation)
            destination.selectedSight = allSight[indexOfAnnotation]
        }
    }




}
