//
//  MemberModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 10.03.21.
//

import Foundation

public class MemberModel: NSObject {
    public var id = ""
    public var name = ""
    public var roles = ""
    public var email = ""
    public var enabled = ""
    public var deleted = ""
    public var creator = ""
    public var defaultUnitCode = ""
    public var createdDate = ""
    
    func loadFields(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        roles = json["roles"] as? String ?? ""
        email = json["email"] as? String ?? ""
        enabled = json["enabled"] as? String ?? ""
        deleted = json["deleted"] as? String ?? ""
        creator = json["creator"] as? String ?? ""
        defaultUnitCode = json["defaultUnitCode"] as? String ?? ""
        creator = json["creator"] as? String ?? ""
        createdDate = json["createdDate"] as? String ?? ""
    }
}
