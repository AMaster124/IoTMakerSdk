//
//  ResourceModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public class ResourceModel: NSObject {
    public var id = ""
    public var name = ""
    public var order = ""
    public var creator = ""
    public var modifier = ""
    public var properties = [PropertyModel]()
    public var createdDate = ""
    public var modifiedDate = ""
    
    func loadFields(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        order = json["order"] as? String ?? ""
        creator = json["creator"] as? String ?? ""
        modifier = json["modifier"] as? String ?? ""
        createdDate = json["createdDate"] as? String ?? ""
        modifiedDate = json["modifiedDate"] as? String ?? ""

        let arry = json["properties"] as? [[String: Any]]
        if let arry = arry {
            properties = []
            for j in arry {
                let p = PropertyModel()
                p.loadFields(json: j)
                properties.append(p)
            }
        }

    }
}
