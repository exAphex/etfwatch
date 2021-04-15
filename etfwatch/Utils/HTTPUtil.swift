//
//  HTTPUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 04.04.21.
//

import Foundation

class HTTPUtil {
    
    static func getRequest(strURL: String) throws -> HistoricDataStruct?  {
        let url = URL(string: strURL)!
        let semaphore = DispatchSemaphore(value: 0)
        var result : HistoricDataStruct? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print(error) // this will print -1009
                semaphore.signal()
                return
            }
            guard let data = data else {
                semaphore.signal()
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                result = try jsonDecoder.decode(HistoricDataStruct.self, from: data)
            } catch {
                print("JSONSerialization error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result
    }
    
    static func getSearch(strURL: String, _ completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let url = URL(string: strURL)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let errorResponse = error {
               completion(nil, nil, errorResponse)
            } else {
                completion(data, response, nil)
            }
        }
        
        task.resume()
    }
    
}
