//
//  IoTMakerSdk.swift
//  IoTMakerSdk
//
//  Created by Coding on 09.03.21.
//

import Foundation

class IoTMakerSdk: NSObject {
    static let shared: IoTMakerSdk = {
        let value = IoTMakerSdk()
        return value
    }()
    
    static func configure(isPublic: Bool = true, apiUrl: String? = nil) {
        Constants.TEST_MODE = !isPublic
        if let apiUrl = apiUrl {
            Constants.BASE_URL = apiUrl
        } else {
            Constants.BASE_URL = isPublic ? Constants.PUBLIC_API_URL : Constants.TEST_API_URL
        }
    }
    
    static func gigaIotOAuth( username: String, password: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: Constants.BASE_URL + "/oauth/token")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "username=\(username)&password=\(password)".data(using: .utf8)
        
        guard let data = ("\(Constants.CLIENT_ID):\(Constants.CLIENT_SECRET)").data(using: .utf8) else {
            return
        }
        
        let authString = "Basic " + data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        request.addValue(authString, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let e = error {
                NSLog("An error has occured: \(e.localizedDescription)")
                return
            }
            
            do {
                if let object = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    print(object)
                    completion(object)
                }
            } catch let e as NSError {
                print("An error has occured while parsing JSONObject: \(e.localizedDescription)")
            }
            
        } 
        
        task.resume()
    }
}
