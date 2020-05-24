//
//  ViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var countriesLocation: [String: [String]]!
    var globalSummary: GlobalSummary!
    var countriesSummary: [CountrySummary]!
    var selectedCountry: CountrySummary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CountriesLocationLoader.loadCountriesCoordinate(completion: handleLoadCountriesCoordinate)
        
        if let region = UserDefaultsManager.loadMapState() {
            mapView.region = region
        }
    }
    
    private func handleLoadCountriesCoordinate(countriesLocation: [String: [String]], error: AppError?) {
        if error != nil {
            fatalError(error!.localizedDescription)
        }
        self.countriesLocation = countriesLocation
        ApiClient.loadSummary(completion: handleLoadSummary)
    }
    
    private func handleLoadSummary(summary: SummaryResponse?, error: AppError?) {
        self.globalSummary = summary!.global
        self.countriesSummary = summary!.countries
        self.setLocations(countriesSummary: summary!.countries)
        UserDefaultsManager.saveLastUpdateDate(date: summary!.date)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.glyphText = annotation.subtitle!
            pinView!.subtitleVisibility = .hidden
            pinView!.markerTintColor = getPinColor(Int(annotation.subtitle!!)!)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountrySummary" {
            let controller = segue.destination as! CountrySummaryViewController
            controller.countrySummary = selectedCountry
        } else if segue.identifier == "showTotalSummary" {
            //let controller = segue.destination as! TotalSummaryViewController
        }
    }

    @IBAction func refreshTapped(_ sender: Any) {
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let countryName = view.annotation!.title
            selectedCountry = countriesSummary.first { (countrySummary) -> Bool in
                return countrySummary.country == countryName
            }
            performSegue(withIdentifier: "showCountrySummary", sender: self)
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserDefaultsManager.saveMapState(region: mapView.region)
    }
    
    private func getPinColor(_ casesNumber: Int) -> UIColor {
        switch casesNumber {
        case 0...1000:
            return .green
        case 1000...10000:
            return .yellow
        case 10000...50000:
            return .orange
        default:
            return .red
        }
    }
    
    private func setLocations(countriesSummary: [CountrySummary]) {
        var annotations = [MKPointAnnotation]()
        
        for countrySummary in countriesSummary {
            if countrySummary.totalConfirmed < 100 || countrySummary.totalRecovered == countrySummary.totalConfirmed {
                continue
            }
            guard let coordinates = countriesLocation[countrySummary.countryCode.lowercased()] else { continue }
            let lat = CLLocationDegrees(coordinates[0])
            let long = CLLocationDegrees(coordinates[1])
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotation.title = countrySummary.country
            annotation.subtitle = "\(countrySummary.totalConfirmed)"
            annotations.append(annotation)
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
}
