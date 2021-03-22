//
//  TargetModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public class TargetModel: NSObject {
    public var id = ""
    public var serviceCode = ""
    
    func loadFields(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        serviceCode = json["serviceCode"] as? String ?? ""
    }
}
