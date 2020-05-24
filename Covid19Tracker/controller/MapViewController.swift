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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var countriesLocation: [String: [String]]!
    var globalSummary: GlobalSummary?
    var countriesSummary: [CountrySummary]?
    var selectedCountrySummary: CountrySummary?
    var fetchedResultsController: NSFetchedResultsController<CountrySummary>!
    
    var dataController: DataController {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFetchedResultsController()
        updateDataIfNeeded()
        initMap()
    }
    
    private func initMap() {
        if let region = UserDefaultsManager.loadMapState() {
            mapView.region = region
        }
    }
    
    private func updateDataIfNeeded() {
        if let lastUpdateDate = UserDefaultsManager.loadLastUpdateDate() {
            let lastUpdateDatePlusDay = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdateDate)!
            let currentDate = Date()
            if lastUpdateDatePlusDay < currentDate {
                loadDataFromNetwork()
            } else {
                loadFromDb()
            }
        } else {
            loadDataFromNetwork()
        }
    }
    
    private func loadFromDb() {
        countriesSummary = fetchedResultsController.fetchedObjects
        if (countriesSummary?.count ?? 0 > 0) {
            globalSummary = countriesSummary![0].globalSummary
            setLocations(countriesSummary: countriesSummary!)
        }
        //        photosCollectionView.reloadData()
        //        activityIndicator.stopAnimating()
        //        refreshButton.isEnabled = true
    }
    
    private func loadDataFromNetwork() {
        CountriesLocationLoader.loadCountriesCoordinate(completion: handleLoadCountriesCoordinate)
    }
    
    private func handleLoadCountriesCoordinate(countriesLocation: [String: [String]], error: AppError?) {
        if error != nil {
            fatalError(error!.localizedDescription)
        }
        self.countriesLocation = countriesLocation
        ApiClient.loadSummary(completion: handleLoadSummary)
    }
    
    private func handleLoadSummary(summary: CovidSummaryResponse?, error: AppError?) {
        UserDefaultsManager.saveLastUpdateDate(date: summary!.date)
        
        let globalSummary = GlobalSummary(context: self.dataController.viewContext)
        globalSummary.date = summary!.date
        globalSummary.newConfirmed = Int32(summary!.global.newConfirmed)
        globalSummary.totalConfirmed = Int32(summary!.global.totalConfirmed)
        globalSummary.newDeaths = Int32(summary!.global.newDeaths)
        globalSummary.totalDeaths = Int32(summary!.global.totalDeaths)
        globalSummary.newRecovered = Int32(summary!.global.newRecovered)
        globalSummary.totalRecovered = Int32(summary!.global.totalRecovered)
        
        let countriesSummaryWithLocation = summary!.countries.filter { (countrySummaryResponse) -> Bool in
            return countriesLocation[countrySummaryResponse.countryCode.lowercased()] != nil
        }
        
        countriesSummaryWithLocation.map { countrySummaryResponse -> CountrySummary in
            let countrySummary = CountrySummary(context: self.dataController.viewContext)
            countrySummary.country = countrySummaryResponse.country
            countrySummary.countryCode = countrySummaryResponse.countryCode
            countrySummary.date = countrySummaryResponse.date
            countrySummary.newConfirmed = Int32(countrySummaryResponse.newConfirmed)
            countrySummary.newDeaths = Int32(countrySummaryResponse.newDeaths)
            countrySummary.newRecovered = Int32(countrySummaryResponse.newRecovered)
            countrySummary.totalConfirmed = Int32(countrySummaryResponse.totalConfirmed)
            countrySummary.totalDeaths = Int32(countrySummaryResponse.totalDeaths)
            countrySummary.totalRecovered = Int32(countrySummaryResponse.totalRecovered)
            let countryLocation = countriesLocation[countrySummaryResponse.countryCode.lowercased()]
            countrySummary.latitude = countryLocation![0]
            countrySummary.longitude = countryLocation![1]
            countrySummary.globalSummary = globalSummary
            return countrySummary
        }
        DispatchQueue.main.async {
            try? self.dataController.viewContext.save()
        }
    }
    
    fileprivate func initFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CountrySummary> = CountrySummary.fetchRequest()
        let predicate = NSPredicate(format: "totalConfirmed > %d", 500)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "totalConfirmed", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
            
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "countriesSummary")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            showErrorAlert(.commonError, self)
        }
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
            controller.countrySummary = selectedCountrySummary
        } else if segue.identifier == "showGlobalSummary" {
            let controller = segue.destination as! GlobalSummaryViewController
            controller.globalSummary = globalSummary
        }
    }

    @IBAction func refreshTapped(_ sender: Any) {
        loadDataFromNetwork()
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
    
    private func setLocations(countriesSummary: [CountrySummary]) {
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
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadFromDb()
    }
}
