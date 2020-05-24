//
//  SummaryResponse.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

class SummaryResponse: Codable {
    let global: GlobalSummary
    let countries: [CountrySummary]
    let date: Date
}
