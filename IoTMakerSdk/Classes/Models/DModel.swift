//
//  DModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public class DModel: NSObject {
    public var id = ""
    public var name = ""
    public var type = ""
    public var protocolType = ""
    public var bindingType = ""
    public var createdDate = ""
    public var modifiedDate = ""
    public var modifier = ""
    public var serviceCode = ""
    public var resources: [ResourceModel]? = nil
    public var uiCapability: [String: [String: UICapItemModel]]? = nil
    
    public func loadFields(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        type = json["type"] as? String ?? ""
        protocolType = json["protocolType"] as? String ?? ""
        bindingType = json["bindingType"] as? String ?? ""
        createdDate = json["createdDate"] as? String ?? ""
        modifiedDate = json["modifiedDate"] as? String ?? ""
        modifier = json["modifier"] as? String ?? ""
        serviceCode = json["serviceCode"] as? String ?? ""
        let arry = json["resources"] as? [[String: Any]]
        if let arry = arry, arry.count > 0 {
            resources = []
            for i in 0 ..< arry.count {
                let r = ResourceModel()
                r.loadFields(json: arry[i])
                resources?.append(r)
            }
        }
        
        if let jsonStr = json["uiCapability"] as? String,
           let uiCapability = jsonStr.toJSON() as? [[String: Any]] {
            self.uiCapability = [:]
            if uiCapability.count > 0 {
                for i in 0 ..< uiCapability.count {
                    guard let id = uiCapability[i]["id"] as? String else {
                        continue
                    }
                    
                    guard let propArry = uiCapability[i]["properties"] as? [[String: Any]] else {
                        self.uiCapability![id] = [String: UICapItemModel]()
                        continue
                    }
                    
                    var properties = [String: UICapItemModel]()
                    for j in 0 ..< propArry.count {
                        let keys = Array(propArry[j].keys)
                        for k in 0 ..< keys.count {
                            let item = UICapItemModel()
                            item.loadFields(json: propArry[j][keys[k]] as! [String : Any])
                            properties[keys[k]] = item
                        }
                    }
                    self.uiCapability![id] = properties
                }
            }
        }
    }
}

extension String {
    func toJSON() -> Any? {
        let str1 = self.dropFirst(1).dropLast(1).replacingOccurrences(of: "\\", with: "")
        
        return try? JSONSerialization.jsonObject(with: String(str1).data(using: .utf8)!, options: [])
    }
}
