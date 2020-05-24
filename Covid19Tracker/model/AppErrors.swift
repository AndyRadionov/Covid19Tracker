//
//  AppErrors.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

enum AppError: LocalizedError {
    case networkError
    case decodeError
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network Error\nPlease try Again later"
        case .decodeError:
            return "Something went wrong\nPlease Try Again later"
        }
    }
}
