//
//  BaseCountriesViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 25.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit
import CoreData

class BaseCountriesViewController: UIViewController {

    var globalSummary: GlobalSummary?
    var countriesSummary: [CountrySummary]?
    var selectedCountrySummary: CountrySummary?
    var countriesUiUpdater: CountriesUiUpdater!
    var fetchedResultsController: NSFetchedResultsController<CountrySummary>!
    private var countriesLocation: [String: [String]]!
    
    var dataController: DataController {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFetchedResultsController()
        updateDataIfNeeded()
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
    
    func loadDataFromNetwork() {
        countriesUiUpdater.enableViews(false)
        CountriesLocationLoader.loadCountriesCoordinate(completion: handleLoadCountriesCoordinate)
    }
    
    private func loadFromDb() {
        countriesUiUpdater.enableViews(false)
        countriesSummary = fetchedResultsController.fetchedObjects
        if (countriesSummary?.count ?? 0 > 0) {
            globalSummary = countriesSummary![0].globalSummary
            countriesUiUpdater.updateData(countriesSummary!)
            countriesUiUpdater.enableViews(true)
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
}

extension BaseCountriesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadFromDb()
    }
}

protocol CountriesUiUpdater {
    func updateData(_ countriesSummary: [CountrySummary])
    func enableViews(_ enable: Bool)
}
