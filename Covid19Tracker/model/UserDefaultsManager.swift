//
//  UserDefaultsManager.swift
//  Covid19Tracker
//
//  Created by Andy on 24.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation
import MapKit

class UserDefaultsManager {
    
    class func loadLastUpdateDate() -> Date? {
        return UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date
    }
    
    class func saveLastUpdateDate(date: Date) {
        UserDefaults.standard.set(date, forKey: "lastUpdateDate")
    }
    
    class func loadMapState() -> MKCoordinateRegion? {
        guard let region = UserDefaults.standard.object(forKey: "mapRegion") as? [Double] else { return nil }
        let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
        let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
        return MKCoordinateRegion(center: center, span: span)
    }
    
    class func saveMapState(region: MKCoordinateRegion) {
        let locationData = [region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta]
        UserDefaults.standard.set(locationData, forKey: "mapRegion")
    }
}
