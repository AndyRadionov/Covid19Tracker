//
//  TotalStatisticsViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit

class GlobalSummaryViewController: UIViewController {

    var globalSummary: GlobalSummary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
