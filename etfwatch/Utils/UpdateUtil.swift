//
//  UpdateUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 19.04.21.
//

import Foundation
import UserNotifications

class Updater {
    var version = "";
    
    init(version:String) {
        self.version = version;
    }
    
    func checkUpdate(callback: ((String)->())?) {
        
        let url = URL(string: "https://raw.githubusercontent.com/exAphex/etfwatch/main/update.json")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let updateObj = try jsonDecoder.decode(UpdateModel.self, from: data)
                
                if (updateObj.req_version != self.version) {
                    callback!(updateObj.req_version)
                }
                
            } catch {
                print("JSONSerialization error:", error)
            }
        }

        task.resume()
    }
    
    static func notification(title:String, subtitle:String, tag:String) {
        let mathContent = UNMutableNotificationContent()
        mathContent.title = title
        mathContent.subtitle = subtitle
        mathContent.body = tag
        mathContent.badge = 1
        mathContent.categoryIdentifier = "etfwatchCategory"
        mathContent.sound = UNNotificationSound.default
        
        let quizTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let quizRequestIdentifier = "etfWatch"
        let request = UNNotificationRequest(identifier: quizRequestIdentifier, content: mathContent, trigger: quizTrigger)

        UNUserNotificationCenter.current().add(request) { (error) in
        }
    }
}
