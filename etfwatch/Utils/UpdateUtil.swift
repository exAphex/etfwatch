//
//  UpdateUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 19.04.21.
//

import Foundation

class Updater {
    var version = "";
    
    init(version:String) {
        self.version = version;
    }
    
    func checkUpdate(callback: ((String, [String])->())?) {
        
        let url = URL(string: "https://raw.githubusercontent.com/sagan001/pr0grammNotifier/master/pr0grammNotifier/update.json")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let updateObj = try jsonDecoder.decode(UpdateModel.self, from: data)
                
                if (updateObj.req_version != self.version) {
                    callback!(updateObj.req_version, updateObj.features)
                }
                
            } catch {
                print("JSONSerialization error:", error)
            }
        }

        task.resume()
    }
}
