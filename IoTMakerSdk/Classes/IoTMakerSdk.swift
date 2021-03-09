//
//  IoTMakerSdk.swift
//  IoTMakerSdk
//
//  Created by Coding on 09.03.21.
//

import Foundation
import Alamofire

public class IoTMakerSdk: NSObject {
//    static let shared: IoTMakerSdk = {
//        let value = IoTMakerSdk()
//        return value
//    }()
    
    public static func configure(isPublic: Bool = true, apiUrl: String? = nil) {
        Constants.TEST_MODE = !isPublic
        if let apiUrl = apiUrl {
            Constants.BASE_URL = apiUrl
        } else {
            Constants.BASE_URL = isPublic ? Constants.PUBLIC_API_URL : Constants.TEST_API_URL
        }
    }
    
    public static func gigaIotOAuth( username: String, password: String, completion: @escaping ([String: Any]?, String?)->Void) {
        guard let data = ("\(Constants.CLIENT_ID):\(Constants.CLIENT_SECRET)").data(using: .utf8) else {
            return
        }
        
        let authString = "Basic " + data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let header = [
            "Authorization": authString
        ]
        
        let params = [
            "username": username,
            "password": password,
            "grant_type": password == "" ? "client_credentials" : "password"
        ]
        
        print(params)

        Alamofire.request(Constants.BASE_URL + "/oauth/token", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [String: Any], nil)
            }
        }

    }
}
