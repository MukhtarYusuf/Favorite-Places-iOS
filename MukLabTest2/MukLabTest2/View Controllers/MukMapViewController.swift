//
//  MukMapViewController.swift
//  MukLabTest2
//
//  Created by Mukhtar Yusuf on 2/1/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MukMapViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukMapView: MKMapView!
    
    // MARK: Properties
    var mukCoreDataStack: CoreDataStack! {
        didSet {
            NotificationCenter.default.addObserver(forName:
                Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: mukManagedObjectContext,
                                                   queue: OperationQueue.main)
            { [weak self] notification in
                if self?.isViewLoaded ?? false {
                    self?.mukFetchAndUpdateUI()
                }
            }
        }
    }
    lazy var mukManagedObjectContext = {
        return mukCoreDataStack.managedContext
    }()
    var mukLocations: [MukLocation] = []
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLocation" || segue.identifier == "EditLocation" {
            if let mukLocationDetailsVC = segue.destination as? MukLocationDetailsViewController {
                mukLocationDetailsVC.mukCoreDataStack = mukCoreDataStack
                
                if let mukButton = sender as? UIButton {
                    let mukLocationToEdit = mukLocations[mukButton.tag]
                    mukLocationDetailsVC.mukLocationToEdit = mukLocationToEdit
                }
            }
        }
    }
    
    // MARK: Action Methods
    @objc func mukEditLocation(_ sender: UIButton) {
         performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukMapView.delegate = self
        mukFetchAndUpdateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Utilities
    private func mukFetchAndUpdateUI() {
        mukMapView.removeAnnotations(mukLocations)
        let mukFetchRequest: NSFetchRequest<MukLocation> = MukLocation.fetchRequest()
        do {
            mukLocations = try mukManagedObjectContext.fetch(mukFetchRequest)
            for location in mukLocations {
                if location.mukTitle == "" {
                    mukManagedObjectContext.delete(location)
                    mukCoreDataStack.saveContext()
                }
            }
            mukMapView.addAnnotations(mukLocations)
            
            let mukMapRegion = region(for: mukLocations)
            mukMapView.setRegion(mukMapRegion, animated: true)
        } catch let error as NSError {
            mukHandleFetchError(error: error)
        }
    }
    
    private func mukHandleFetchError(error: NSError) {
        print("Fetching Error \(error), \(error.userInfo)")
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion( center: mukMapView.userLocation.coordinate,
                                         latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
    
            let centerLatitude = topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2
            let centerLongitude = topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
            let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) *
                                            extraSpace,
                                        longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mukMapView.regionThatFits(region)
    }
    
}

// MARK: MKMapView Delegate
extension MukMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MukLocation else {
            return nil
        }
        
        let mukIdentifier = "MukLocation"
        var mukAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mukIdentifier)
        if mukAnnotationView == nil {
            let mukPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: mukIdentifier)
            mukPinView.isEnabled = true
            mukPinView.canShowCallout = true
            mukPinView.animatesDrop = true
            mukPinView.pinTintColor = UIColor(red: 0.0, green: 186/255, blue: 135/255, alpha: 1.0)
            
            let mukEditLocationButton = UIButton(type: .detailDisclosure)
            mukEditLocationButton.addTarget(self, action: #selector(mukEditLocation), for: .touchUpInside)
            mukPinView.rightCalloutAccessoryView = mukEditLocationButton
            
            mukAnnotationView = mukPinView
        }
        
        if let mukAnnotationView = mukAnnotationView {
            mukAnnotationView.annotation = annotation
            if let mukButton = mukAnnotationView.rightCalloutAccessoryView as? UIButton,
                let mukIndex = mukLocations.firstIndex(of: annotation as! MukLocation) {
                mukButton.tag = mukIndex
            }
        }
        
        return mukAnnotationView
    }
}

/*
// Coordinates
1). Lambton: 43.773580791681646, -79.33599846022913
2). Toronto Airport: 43.67853196389666, -79.62464807792082
3). Costco: 43.76004279881852, -79.29763946511994
4). Casa Loma: 43.678168989401975, -79.40942244489115
5.  Michael Garron Hospital: 43.69011635260322, -79.32482648722
*/
