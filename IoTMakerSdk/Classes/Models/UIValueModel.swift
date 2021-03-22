//
//  UIValueModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public class UIValueModel: NSObject {
    public var name = ""
    public var data = ""
    public var min = ""
    public var max = ""
    public var step = ""

    func loadFields(json: [String: Any]) {
        data = json["data"] as? String ?? ""
        name = json["name"] as? String ?? ""
        min  = json["min"]  as? String ?? ""
        max  = json["max"]  as? String ?? ""
        step = json["step"] as? String ?? ""
    }
}
