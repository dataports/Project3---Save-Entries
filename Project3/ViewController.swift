//
//  ViewController.swift
//  Project3
//
//  Created by Sophia Amin on 4/17/18.
//  Copyright © 2018 Sophia Amin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

final class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    //zoom into a coordinate
    var region: MKCoordinateRegion{
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}


class ViewController: UIViewController, UITableViewDataSource {
    
    

    
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var latlonString:String? = " "
    var latitude:Double = 0
    var longitude:Double = 0
   // private var data: [String] = []
    private var latlonArr: [String] = [] ?? ["Start"]//array of the combined latlon strings
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = (self as UITableViewDataSource)
        
        
        let selectedCoordinate = CLLocationCoordinate2D(latitude: 42, longitude: -71)
        let selectedAnnotation = LocationAnnotation(coordinate: selectedCoordinate, title: "Location", subtitle: "Selected location")
        
        mapView.addAnnotation(selectedAnnotation)
        mapView.setRegion(selectedAnnotation.region, animated: true)
    
        
//        for i in 0...1000 {
//            data.append("\(i)")
//        }
        
        tableView.dataSource = self
        loadDataToTableView()
    }
    
    //MARK: Actions
    @IBAction func enterLatLonPressed(_ sender: UIButton) {
        //process the lat and lon
        latlonString = getLatLon() //string
        latitude = getLat()
        longitude = getLon()
//        latlonArr.append(getLatLon())
        setUpData(point: latlonString!)//prints the whole thing again?
        latlonArr.append(latlonString!)
      // loadDataToTableView()
    
        //TODO: Find place on the map, load into core data
        showCoordinatesOnMap(lat: latitude, lon: longitude)
        tableView.reloadData() //reload
        
    }
    
    //MARK: TableView
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latlonArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let text = latlonArr[indexPath.row] //2.
        
        cell.textLabel?.text = text //3.
        
        return cell
        
    }
    
    
    //MARK: Functions
    //get the lat and lon and add them into a string
    func getLatLon() -> String{
     
        let latitude:String = latitudeTextField.text!
        let longitude:String = longitudeTextField.text!
        
        let message = "Latitude: \(latitude) Longitude: \(longitude)"
        print(message)
        return message
    }
    
    func getLat() -> Double{
        let latitude = Int(latitudeTextField.text!) ?? 0
        return Double(latitude)
    }
    
    func getLon() -> Double{
        let longitude = Int(longitudeTextField.text!) ?? 0
        return Double(longitude)
    }
    
    //FIND LOCATION
    func showCoordinatesOnMap(lat: Double, lon: Double){
    
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    let selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    let selectedAnnotation = LocationAnnotation(coordinate: selectedCoordinate, title: "Location", subtitle: "Selected location")
    
    mapView.addAnnotation(selectedAnnotation)
    mapView.setRegion(selectedAnnotation.region, animated: true)
    }
    
    //CORE DATA
    
    func setUpData(point: String){
        //        //1. Similar to create database and create SQL table named CarData (SQL comparisons)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        } //instance of app delegate, check if it is the app delegate with a guard statement (safe code)
        let mapPointContext = appDelegate.persistentContainer.viewContext
        let mapPointEntity = NSEntityDescription.entity(forEntityName: "MapPoint", in: mapPointContext)
        
        //2. Similar to INSERT INTO CarData(color, price, type) VALUES(any, any, any) (SQL)
        let newMapPoint = NSManagedObject(entity: mapPointEntity!, insertInto: mapPointContext)
        //~database~ has been created
        
        newMapPoint.setValue(point, forKey: "latlon") //save one more object
        
        saveData(contextSaveObject: mapPointContext)
        loadData(contextLoadObject: mapPointContext)
    }
    
    func saveData(contextSaveObject: AnyObject){
        do{
            try contextSaveObject.save()
        }
        catch {
            print("Error saving")
        }
    }
    
    
    func loadData(contextLoadObject: AnyObject){
        let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapPoint")
        myRequest.returnsObjectsAsFaults = false
        
        //3. important part of Core Data to use the VALUES in the database
        do{
            let result = try contextLoadObject.fetch(myRequest)
            for data in result as! [NSManagedObject]{ //cast as an array (for saving into rows)
                
                let theMapPoint = data.value(forKey: "latlon") as! String //must cast object to String (or Int if needed)
              
               
                //the map point contains ALL the data values in core data
                print("Here is my info from Database:\(String(describing: theMapPoint)) ")
            }
        }catch{
            print("Error loading")
        }
        
    }
    
    func loadDataToTableView(){
        //        //1. Similar to create database and create SQL table named CarData (SQL comparisons)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        } //instance of app delegate, check if it is the app delegate with a guard statement (safe code)
        let mapPointContext = appDelegate.persistentContainer.viewContext
        let mapPointEntity = NSEntityDescription.entity(forEntityName: "MapPoint", in: mapPointContext)
        let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapPoint")
        myRequest.returnsObjectsAsFaults = false
        //fetch request for tableview data
        //3. important part of Core Data to use the VALUES in the database
        do{
            let result = try mapPointContext.fetch(myRequest)
            for data in result as! [NSManagedObject]{ //cast as an array (for saving into rows)
                let theMapPoint = data.value(forKey: "latlon") as? String ?? "Empty"//must cast object to String (or Int if needed)
                //the map point contains ALL the data values in core data
                print("fetch values and put them in a string array")
                latlonArr.append(theMapPoint)

             //   print("Here is my info from Database:\(String(describing: theMapPoint!)) ")
            }
        }catch{
            print("Error loading")
        }

    }
    
}


//MARK: enxtensions
extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let locationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView{
            locationAnnotationView.animatesWhenAdded = true
            locationAnnotationView.titleVisibility = .adaptive
            locationAnnotationView.titleVisibility = .adaptive
            
            return locationAnnotationView
        }
        return nil
    }
}
