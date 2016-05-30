//
//  ViewController.swift
//  Geofence
//
//  Created by YANGSHENG ZOU on 2016-05-26.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import MapKit



class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var eventLabel: UILabel!
    
    @IBOutlet weak var activationSwitch: UISwitch!
    
    let locationManager = CLLocationManager.init()
    
    let myLocationCoordinateAnnotation = MKPointAnnotation.init()
    
    let geoRegionCoordinateAnnotation = MKPointAnnotation.init()
    
    var geoRegion:CLCircularRegion?
    
    var isMapViewMoving:Bool = false
    
    var destinationLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationCoordinateAnnotation.coordinate = mapView.userLocation.coordinate
        myLocationCoordinateAnnotation.title = "here am I"
        
        let coordinate = mapView.userLocation.coordinate
        var viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        viewRegion = mapView.regionThatFits(viewRegion)
        mapView.region = viewRegion
       
        
        if(CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self)){
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
                
                activationSwitch.userInteractionEnabled = true
                
            }
                
            else{
                locationManager.requestAlwaysAuthorization()
            }
            let notificationSetting = UIUserNotificationSettings.init(forTypes: UIUserNotificationType.Alert, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSetting)
        }
        else{
            eventLabel.text! = "geofence not available"
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocationCoordinateAnnotation.coordinate = (locations.last?.coordinate)!
       
        if(geoRegion != nil){
           
        }
        else{
            setGeoregion()
            
            
            locationManager.startMonitoringForRegion(geoRegion!)
        }
        
        
        if isMapViewMoving == false {
            if(distanceLabel.text?.characters.count==0){
            mapView.showAnnotations([geoRegionCoordinateAnnotation], animated: false)
            }
            self.mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
        }
        distanceLabel.text = geoRegion!.containsCoordinate(mapView.userLocation.coordinate).description
        locationManager.requestStateForRegion(geoRegion!)

        
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        isMapViewMoving = true
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        isMapViewMoving = false
    }
    
    
    
    func setGeoregion(){
        let coodrinate = mapView.userLocation.coordinate
        let geoCoordinate = CLLocationCoordinate2D.init(latitude: coodrinate.latitude-0.008, longitude: coodrinate.longitude)
        
        geoRegion = CLCircularRegion.init(center: geoCoordinate, radius: 1100, identifier: "region")
        geoRegionCoordinateAnnotation.coordinate = geoCoordinate
        
        
    }
    
    
    
    @IBAction func switchAction(sender: AnyObject) {
        if(activationSwitch.on == true){
            mapView.showsUserLocation = true
            for region in locationManager.monitoredRegions {
                locationManager.stopMonitoringForRegion(region)
            }
            locationManager.startUpdatingLocation()
            
            
        }
        else{
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringForRegion(geoRegion!)
            geoRegion = nil
            distanceLabel.text = ""
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        setGeoregion()
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let inNotification = UILocalNotification.init()
        inNotification.fireDate = nil
        inNotification.alertTitle = "location"
        inNotification.alertBody = "enter!"
        UIApplication.sharedApplication().scheduleLocalNotification(inNotification)
      
        eventLabel.text = "IN"
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let inNotification = UILocalNotification.init()
        inNotification.fireDate = nil
        inNotification.alertTitle = "location"
        inNotification.alertBody = "exit!"
        UIApplication.sharedApplication().scheduleLocalNotification(inNotification)
        eventLabel.text = "OUT"
    }
    
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        if(status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            activationSwitch.userInteractionEnabled = true
            
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print(state.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}



