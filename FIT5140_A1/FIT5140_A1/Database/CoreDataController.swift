//
//  CoreDataController.swift
//  FIT5140_A1
//
//  Created by KoujiMinamoto on 6/9/19.
//  Copyright © 2019 KoujiMinamoto. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {

    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer

    
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "Sights")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
                
            }
        }
        
        super.init()
        
        // If there are no sights in the database assume that the app is running
        // for the first time. Create the initial sights.
        if fetchAllSights().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSight(name: String, descriptions: String, latitude: Double, longitude: Double, icon: String, image: String) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into:
            persistantContainer.viewContext) as! Sight
        sight.name = name
        sight.descriptions = descriptions
        sight.latitude = latitude
        sight.longitude = longitude
        sight.icon = icon
        sight.image = image
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return sight
    }
    
    func deleteSight(sight: Sight) {
        persistantContainer.viewContext.delete(sight)
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onSightsChange(change: .update, sights: fetchAllSights())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func fetchAllSights() -> [Sight] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest:
                fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            
            do {
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [Sight]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightsFetchedResultsController {
            listeners.invoke { (listener) in
                listener.onSightsChange(change: .update, sights: fetchAllSights())
            }
        }
    }
    
    // Default sights
    func createDefaultEntries() {
        let _ = addSight(name: "Melbourne Museum", descriptions: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", latitude: -37.8032, longitude: 144.9711, icon: "museum", image: "Melbourne Museum")
        let _ = addSight(name: "Old Melbourne Gaol", descriptions: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.", latitude: -37.8077, longitude: 144.9653, icon: "museum", image: "Old Melbourne Gaol")
        let _ = addSight(name: "Yarra Bend Park", descriptions: "Yarra Bend Park is a picturesque native park near the heart of Melbourne. The park features steep river escarpments, open woodlands, playing fields and golf courses.", latitude: -37.7937, longitude: 145.0107, icon: "nationalPark", image: "Yarra Bend Park")
        let _ = addSight(name: "Albert Park", descriptions: "Only three kilometres from the heart of the city, Albert Park is popular for a range of activities like dog walking, jogging, cycling, sailing and rowing. ", latitude: -37.8477, longitude: 144.9620, icon: "nationalPark", image: "Albert Park")
        let _ = addSight(name: "Royal Botanic Gardens", descriptions: "The Royal Botanic Gardens is the place to escape the madness of the CBD without actually leaving it. It's on the edge of the city, and more than 8,500 plant species call this place home. There lush lawns and glittering lakes that are perfect for revitalising the mind and soul with a quick stroll, or for lingering longer with a weekend picnic. Tours, walks, workshops and talks are on offer to teach you more of the intricacies of the gardens, while the Aboriginal Heritage Walk takes you on a journey into the rich history of the Kulin nation.", latitude: -37.829865, longitude: 144.975296, icon: "nationalPark", image: "RoyalGarden")
        
        let _ = addSight(name: "National Gallery of Victoria", descriptions: "The National Gallery of Victoria is made up of two venues - the NGV International and NGV Australia. Both our impressive spaces, filled with world class art, so you could easily while away an entire day at each. The International's permanent collections includes a Rembrandt, a Bonnard and a Tiepolo, plus a much-loved water-wall at the entrance. Over at Fed Square, the Ian Potter Centre houses art from Indigenous and non Indigenous Australians from the colonial era to the current day.", latitude: -37.822594, longitude: 144.968928, icon: "restaurant", image: "NGV")
//        let _ = addSight(name: "Brunswick Street", descriptions: "Melbourne’s famed alternative side is in full-force in Fitzroy, the city-centre hub of all things hip and kooky. Wandering up Brunswick Street, Fitzroy’s main strip, youll be confronted by everything from trency bike shops and cool hairdressers, second-hand bookshops and hometown fashion heroes such as Gorman, Búl, Kloke and Alpha 60. It's the vintage clothes stores, though, that Brunswick is most celebreated for. Pre-loved clothing specialists like Hunter Gatherer, Vintage Sole and Yesteryear Vintage Clothing are just a few of the spots to head for that new leather bag, pair of vintage slacks or ripper denim jacket from the '80s you've been after forever. ", latitude:  -37.791609, longitude: 144.979605, icon: "shoppingMall", image: "Burnswick")
        let _ = addSight(name: "Queen Victoria Markets", descriptions: "Every great city has a great market, and the open-air Queen Victoria Market does Melbourne proud. The place is rammed full of veteran stallholders who are passionate about fresh produce and more than happy to talk you through their wares. ", latitude: -37.80758, longitude: 144.956785, icon: "shoppingMall", image: "QVM")
        let _ = addSight(name: "St Kilda", descriptions: "St Kilda is defined by two main strips, Fitzroy Street and Acland Street, with the famous St Kilda Esplanade providing a pleasant link between the two. While Fitzroy Street is all retail shops, gyms and fancy restaurants, Acland is a haven for cake lovers. The cake shops and bakeries lining the street have been making Melbourne a sweeter place since 1934, and are still serving up Eastern European classics thick and fast: make sure you try the plain cheesecake from Europa Cake Shop, the vanilla slice at Le Bon Continental Cake Shop and the chocolate Kugelhaumpf at Monarch.", latitude: -37.867876, longitude: 144.974005, icon: "shoppingMall", image: "sk")
        let _ = addSight(name: "Royal Exhibition Building", descriptions: "The Royal Exhibition Building in Carlton Gardens is one of the world's oldest remaining exhibition pavilions (and was the first building in Australia to be named on the UNESCO Heritage List). Aside from having a fascinating history, the REB is drop-dead gorgeous inside and out. Tours are held most days at 2pm, or you can snap the façade any time (try getting a pic from in front of the fountain of from in between the many tree-lined pathways nearby). ", latitude: -37.804689, longitude: 144.97165, icon: "shoppingMall", image: "Royal Exhibition Building")
        
        let _ = addSight(name: "Curtin House", descriptions: "If you do one thing in Melbourne, we recommend hitting the extremely Melbourne Curtin House on Swanston Street. This six-storey vertical lane houses some of Melbourne's most interesting tenants. There's Metropolis specialist bookshop, Human Salon the hairdresser, bar/restaurants Cookie and Mesa Verde, high fashion mavens Dot Comme, the swanky bar and band room at the Toff in Town, and Melbourne's crowning glory Rooftop Bar right at the top. Visitors can practically get the full Melbourne experience without setting foot outside the building.", latitude: -37.811994, longitude: 144.965251, icon: "shoppingMall", image: "Curtin House")
        
        let _ = addSight(name: "Chinatown", descriptions: "Melbourne's Chinatown district was first established back in the 1850s during the Victorian gold rush era, making it the longest continuous Chinese settlement in the western world. As such, it's also the oldest Chinatown in the southern hemisphere. This vibrant quarter of town is lined with karaoke bars, duty-free stores and so many fantastic little restaurants, it's hard to know which one to choose. Located along Little Bourke Street and it's surrounding lanes and streets, we recommend dumplings at Shanghai Village, mains at Supper Inn, and the desserts at Secret Kitchen.", latitude:-37.811484, longitude:144.968745 , icon: "shoppingMall", image: "Chinatown")
        
        let _ = addSight(name: "Great Ocean Road", descriptions: "Head southwest from Geelong and you’ll soon see it: the faded log arch announcing your arrival at the Great Ocean Road. Sandwiched between dense coastal eucalypt forests and the ocean, the road is one of the most spectacular drives in Australia. Technically the road starts just outside of Torquay but the best ocean vistas happen between Airey’s Inlet and Apollo Bay, where you’ll drive right along the precipice of the coastal cliffs. There’s regular opportunities to stop at beaches and koala sightings are not uncommon. Travel off season to avoid crowds – the road is just as great in the cooler months.", latitude: -38.680564, longitude: 143.391618 , icon: "shoppingMall", image: "Great Ocean Road")
        let _ = addSight(name: "Phillip Island", descriptions: "A two and a half hour trip from Melbourne is Phillip Island: a chunk of coastal heaven famed for its penguins and seals. The craggy shoreline is broken up by numerous beaches perfect for swimming, surfing and seal watching: there are more seals living on the isalnd than humans. However, giving the seals a run for their money in the cute stakes are Phillip Island’s Little Penguins. Every night, like clockwork, you can watch the tiny penguins come ashore at Summerland beach and march like little, feathery soldiers into their sandy burrows.", latitude:  -38.516547, longitude: 145.123624, icon: "shoppingMall", image: "Phillip Island")
        let _ = addSight(name: "Melbourne Zoo", descriptions: "Australia’s oldest zoo is an inner-cty oasis that's home to hundreds of creatures great and small, housed in lovingly cared for, stimulating environments. Watch seals and penguins gliding through blue water in the Wild Sea exhibit, then head to the sprawling Orang-utan Sanctuary, where a family of intelligent orang-utans swing from tree to tree. And don't miss the Trail of the Elephants; an immersive South-East Asian village and garden where you can learn about and see the gentle giants up close.", latitude: -37.784135, longitude: 144.951547 , icon: "shoppingMall", image: "Melbourne Zoo")
        let _ = addSight(name: "Federation Square", descriptions: "Melbourne’s central community hub is, shall we say, divisive – its geometric design isn’t loved by all. But architecture aside, it’s always buzzing with events, screenings, talks, performances and activities. Whether it’s a weekend craft market, an exhibition at NGV Australia or a panel talk, you’re almost guaranteed to find something to pique your interest. Events still run despite the Metro Tunnel works, so don't be put off by that huge cnstruction site on the corner of Flinders Street and St Kilda Road.", latitude: -37.817979, longitude: 144.969058, icon: "shoppingMall", image: "Federation Square")

    }
}
