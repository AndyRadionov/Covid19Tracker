//
//  CountriesTableViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit

class CountriesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var countriesLocation: [String: [String]]!
    var globalSummary: GlobalSummary!
    var countriesSummary: [CountrySummary]?
    var selectedCountry: CountrySummary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CountriesLocationLoader.loadCountriesCoordinate { [weak self] (countriesLocation, error) in
            guard let self = self else {
                return
            }
            if error != nil {
                fatalError(error!.localizedDescription)
            }
            self.countriesLocation = countriesLocation
        }
        ApiClient.loadSummary { [weak self] (summary, error) in
            guard let self = self else {
                return
            }
            self.globalSummary = summary!.global
            self.countriesSummary = summary!.countries.filter { (countrySummary) -> Bool in
                countrySummary.totalConfirmed > 500
            }
            self.countriesSummary!.sort { (firstCountry, secondCountry) -> Bool in
                firstCountry.totalConfirmed > secondCountry.totalConfirmed
            }
            self.tableView.reloadData()
        }
        let headerNib = UINib.init(nibName: "CountriesTableHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CountriesTableHeaderView")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountrySummary" {
            let controller = segue.destination as! CountrySummaryViewController
            controller.countrySummary = selectedCountry
        } else if segue.identifier == "showTotalSummary" {
            //let controller = segue.destination as! TotalSummaryViewController
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countriesSummary?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountrySummaryCell")!
        let countrySummary = countriesSummary![indexPath.row]
        cell.textLabel?.text = countrySummary.country
        cell.detailTextLabel?.text = "\(countrySummary.totalConfirmed)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = countriesSummary![indexPath.row]
        performSegue(withIdentifier: "showCountrySummary", sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "CountriesTableHeaderView") as! CountriesTableHeaderView
    }
}
