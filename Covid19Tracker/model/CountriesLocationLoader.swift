//
//  CountriesLocationLoader.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

class CountriesLocationLoader {
    
    class func loadCountriesCoordinate(completion: @escaping ([String: [String]], AppError?) -> Void) {
        let url = Bundle.main.url(forResource: "countries_location", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let countriesLocation = try JSONDecoder().decode([String: [String]].self, from: data)
            completion(countriesLocation, nil)
        } catch {
            completion([:], .decodeError)
        }
    }
}
