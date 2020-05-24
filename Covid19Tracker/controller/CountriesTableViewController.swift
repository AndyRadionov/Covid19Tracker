//
//  CountriesTableViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit

class CountriesTableViewController: BaseCountriesViewController, CountriesUiUpdater {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalSummaryButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBarView: UITabBarItem!
    
    override func loadView() {
        super.loadView()
        countriesUiUpdater = self
        initTableView()
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        loadDataFromNetwork()
    }
    
    func updateData(_ countriesSummary: [CountrySummary]) {
        tableView.reloadData()
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
        tableView.isUserInteractionEnabled = enable
    }
    
    private func initTableView() {
        let headerNib = UINib.init(nibName: "CountriesTableHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CountriesTableHeaderView")
    }
}

extension CountriesTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountrySummaryCell")!
        let countrySummary = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = countrySummary.country
        cell.detailTextLabel?.text = "\(countrySummary.totalConfirmed)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountrySummary = countriesSummary![indexPath.row]
        performSegue(withIdentifier: "showCountrySummary", sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "CountriesTableHeaderView") as! CountriesTableHeaderView
    }
}
