//
//  DeviceModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 10.03.21.
//

import Foundation

public class GroupModel: NSObject {
    public var devGroupId = ""
    public var devGroupNm = ""
    public var groupIndcOdrg = 0
    public var creator = ""
    public var updator = ""
    public var createdDate = ""
    public var updatedDate = ""
    
    public var devices: [Int]? = nil
    
    func loadFields(json: [String: Any]) {
        devGroupId = json["devGroupId"] as? String ?? ""
        devGroupNm = json["devGroupNm"] as? String ?? ""
        groupIndcOdrg = json["groupIndcOdrg"] as? Int ?? 0
        creator = json["creator"] as? String ?? ""
        updator = json["updator"] as? String ?? ""
        createdDate = json["createdDate"] as? String ?? ""
        updatedDate = json["updatedDate"] as? String ?? ""
    }
}
