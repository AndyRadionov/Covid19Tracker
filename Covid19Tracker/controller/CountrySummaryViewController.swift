//
//  CountryDetailsViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit

class CountrySummaryViewController: UIViewController {

    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var totalConfirmedLabel: UILabel!
    @IBOutlet weak var totalDeathsLabel: UILabel!
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newConfirmedLabel: UILabel!
    @IBOutlet weak var newDeathsLabel: UILabel!
    @IBOutlet weak var newRecoveredLabel: UILabel!
    
    var countrySummary: CountrySummary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        
        countryLabel.text = countrySummary.country
        totalConfirmedLabel.text = "\(countrySummary.totalConfirmed)"
        totalDeathsLabel.text = "\(countrySummary.totalDeaths)"
        totalRecoveredLabel.text = "\(countrySummary.totalRecovered)"
        dateLabel.text = dateFormatterGet.string(from: countrySummary.date)
        newConfirmedLabel.text = "\(countrySummary.newConfirmed)"
        newDeathsLabel.text = "\(countrySummary.newDeaths)"
        newRecoveredLabel.text = "\(countrySummary.newRecovered)"
    }

}
