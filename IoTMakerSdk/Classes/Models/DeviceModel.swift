//
//  DeviceModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 10.03.21.
//

import Foundation

public class DeviceModel: NSObject {
    public var id = ""
    public var name = ""
    public var connectionId = ""
    public var status = ""
    public var model = DModel()
    public var target = TargetModel()
    public var used = false
    public var connectionType = ""
    public var authenticationKey = ""
    public var authenticationType = ""
    public var creator = ""
    public var modifier = ""
    public var createdDate = ""
    public var updatedDate = ""
    public var modifiedDate = ""
    public var deleted = ""
    
    public var isConnected  = false
    
    public var groupId: String? = nil
    public var groupNm: String? = nil
    public var resIndex: Int? = nil
    public var icon: UIImage? = nil
    public var img: UIImage? = nil
    
    public func loadFields(json: [String: Any]) {
        if let id = json["id"] as? String {
            self.id = id
        }

        if let name = json["name"] as? String {
            self.name = name
        }

        if let connectionId = json["connectionId"] as? String {
            self.connectionId = connectionId
        }

        if let status = json["status"] as? String {
            self.status = status
        }

        if let used = json["used"] as? Bool {
            self.used = used
        }

        if let connectionType = json["connectionType"] as? String {
            self.connectionType = connectionType
        }

        if let authenticationType = json["authenticationType"] as? String {
            self.authenticationType = authenticationType
        }

        if let authenticationKey = json["authenticationKey"] as? String {
            self.authenticationKey = authenticationKey
        }

        if let updater = json["updater"] as? String {
            modifier = updater
        } else if let updater = json["modifier"] as? String {
            modifier = updater
        }
        
        if let creater = json["creator"] as? String {
            creator = creater
        }

        if let createdDate = json["createdDate"] as? String {
            self.createdDate = createdDate
        }

        if let updatedDate = json["updatedDate"] as? String {
            self.updatedDate = updatedDate
        }

        if let modifiedDate = json["modifiedDate"] as? String {
            self.modifiedDate = modifiedDate
        }

        if let deleted = json["deleted"] as? String {
            self.deleted = deleted
        }

        if let modelJson = json["model"] as? [String: Any] {
            model.loadFields(json: modelJson)
        }
        
        if let targetJson = json["target"] as? [String: Any] {
            target.loadFields(json: targetJson)
        }
    }
}
