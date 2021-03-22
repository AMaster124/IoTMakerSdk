//
//  UICapItemModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public class UICapItemModel: NSObject {
    public var uiType = UIType.TEXT
    public var uiValues = [UIValueModel]()
    
    func loadFields(json: [String: Any]) {
        uiType = UIType(rawValue: json["uiType"] as? String ?? UIType.TEXT.rawValue) ?? .TEXT
        
        if let arry = json["uiValues"] as? [[String: Any]] {
            self.uiValues = []
            for i in 0 ..< arry.count {
                let uiValue = UIValueModel()
                uiValue.loadFields(json: arry[i])
                self.uiValues.append(uiValue)
            }
        }
    }
}
