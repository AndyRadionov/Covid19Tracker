//
//  ViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var countriesCoordinate: [String: [String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiClient.loadSummary { (summary, error) in
            self.setLocations(countriesSummary: summary!.countries)
        }
        loadCountriesCoordinate()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView {
//            let app = UIApplication.shared
//            if let toOpen = view.annotation?.subtitle! {
//                app.open(URL(string: toOpen)!)
//            }
//        }
    }
    
    private func setLocations(countriesSummary: [CountrySummary]) {
        var annotations = [MKPointAnnotation]()
        
        for countrySummary in countriesSummary {
            if countrySummary.totalConfirmed < 100 || countrySummary.totalRecovered == countrySummary.totalConfirmed {
                continue
            }
            guard let coordinates = countriesCoordinate[countrySummary.countryCode.lowercased()] else { continue }
            let lat = CLLocationDegrees(coordinates[0])
            let long = CLLocationDegrees(coordinates[1])
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = countrySummary.country
            
            annotations.append(annotation)
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
    
    private func loadCountriesCoordinate() {
        let url = Bundle.main.url(forResource: "countries_location", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        countriesCoordinate = try! JSONDecoder().decode([String: [String]].self, from: data)
    }
}

