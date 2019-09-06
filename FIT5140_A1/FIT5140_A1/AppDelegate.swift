//
//  AppDelegate.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var databaseController: DatabaseProtocol?
    var persistantContainer: NSPersistentContainer?
    //
    let locationManager = CLLocationManager()
    let center = UNUserNotificationCenter.current()
    //var locationManager: CLLocationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = CoreDataController()
        
        persistantContainer = NSPersistentContainer(name: "ImageModel")
        persistantContainer?.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        // configure location manager
//        if (self as! CLLocationManagerDelegate) != nil{
//        locationManager.delegate = (self as! CLLocationManagerDelegate)
//        locationManager.requestAlwaysAuthorization()
//        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // configure notification center
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        
        return true
    }
    
    func handleLeaveEvent(forRegion region: CLRegion!) {
        // display alert
        if UIApplication.shared.applicationState == .active {
            guard let message = leaveMessage(forRegion: region.identifier) else { return }
            let alert = UIAlertController(title: "Leave \(region.identifier)'s territory", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            // Otherwise present a local notification
            let content = UNMutableNotificationContent()
            content.body = leaveMessage(forRegion: region.identifier)!
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: nil)
            center.add(request, withCompletionHandler: nil)
        }
    }
    
    func handleEntryEvent(forRegion region: CLRegion!){
        // display alert
        if UIApplication.shared.applicationState == .active {
            guard let message = entryMessage(forRegion: region.identifier) else { return }
            let alert = UIAlertController(title: "Enter \(region.identifier)'s territory", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Hi there", style: UIAlertAction.Style.default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            let content = UNMutableNotificationContent()
            content.body = entryMessage(forRegion: region.identifier)!
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: nil)
            center.add(request, withCompletionHandler: nil)
            
        }
    }
    
    func leaveMessage(forRegion identifier:String)->String?{
        let leaveString = "Say goodbye to \(identifier)"
        return leaveString
    }
    
    func entryMessage(forRegion identifier:String)->String?{
        let entryString = "Say hello to \(identifier)"
        return entryString
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
   

}
extension AppDelegate: CLLocationManagerDelegate {
    
    // display alert or send notification in the background when enter
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEntryEvent(forRegion: region)
        }
    }
    
    // display alert or send notification in the background when leave
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleLeaveEvent(forRegion: region)
        }
    }
}


