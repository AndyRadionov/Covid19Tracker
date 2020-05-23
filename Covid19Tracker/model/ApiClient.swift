//
//  ApiClient.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

class ApiClient {
    
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
    
    class func loadSummary(completion: @escaping (SummaryResponse?, AppError?) -> Void) {
        
        makeGETRequest(url: Endpoints.summary.url, responseType: SummaryResponse.self) { (summary, error) in
            if error != nil {
                completion(nil, error!)
            } else {
                completion(summary, nil)
            }
        }
    }
    
    
    private class func makeGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, AppError?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, .networkError)
                return
            }
            do {
                let responseObject = try initDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, .decodeError)
            }
        }
        task.resume()
    }
    
    private static func initDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromUpperCamelCase
        return decoder
    }
}
