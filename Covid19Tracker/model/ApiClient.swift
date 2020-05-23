//
//  ApiClient.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

class ApiClient {
    
    private static let decoder = JSONDecoder()
    
    enum Endpoints {
        static let base = "https://api.covid19api.com"
        
        case summary
        
        var stringValue: String {
            switch self {
            case .summary:
                return "\(Endpoints.base)/summary"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    enum ApiError: LocalizedError {
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
    
    class func loadSummary(completion: @escaping (SummaryResponse?, ApiError?) -> Void) {
        
        makeGETRequest(url: Endpoints.summary.url, responseType: SummaryResponse.self) { (summary, error) in
            if error != nil {
                completion(nil, error!)
            } else {
                completion(summary, nil)
            }
        }
    }
    
    
    private class func makeGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, ApiError?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, .networkError)
                return
            }
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                decoder.keyDecodingStrategy = .convertFromUpperCamelCase
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, .decodeError)
            }
        }
        task.resume()
    }
    
}


