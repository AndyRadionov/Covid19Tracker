//
//  ViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: BaseCountriesViewController, CountriesUiUpdater {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var globalSummaryButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBarView: UITabBarItem!
    
    override func loadView() {
        super.loadView()
        countriesUiUpdater = self
        initMap()
    }
    
    private func initMap() {
        if let region = UserDefaultsManager.loadMapState() {
            mapView.region = region
        }
    }

    @IBAction func refreshTapped(_ sender: Any) {
        loadDataFromNetwork()
    }
    
    func updateData(_ countriesSummary: [CountrySummary]) {
        var annotations = [MKPointAnnotation]()
        
        for countrySummary in countriesSummary {
            let lat = CLLocationDegrees(countrySummary.latitude!)
            let long = CLLocationDegrees(countrySummary.longitude!)
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
    
    func enableViews(_ enable: Bool) {
        if enable {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        globalSummaryButton.isEnabled = enable
        refreshButton.isEnabled = enable
        tabBarView.isEnabled = enable
        mapView.isZoomEnabled = enable
        mapView.isScrollEnabled = enable
        mapView.isUserInteractionEnabled = enable
    }
}

extension MapViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let countryName = view.annotation!.title
            selectedCountrySummary = countriesSummary?.first { (countrySummary) -> Bool in
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
}
