//
//  PropertyModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 18.03.21.
//

import Foundation

public enum UIType: String, CaseIterable {
    case BUTTON
    case TOGGLE
    case SWITCH
    case RADIO
    case COMBO
    case TEXT
    case SLIDER
}

public enum DataType: String, CaseIterable {
    case INTEGER
    case DOUBLE
    case STRING
    case BINARY
    case BOOLEAN
    case INTEGER_ARRAY
    case DOUBLE_ARRAY
    case STRING_ARRAY
    case BOOLEAN_ARRAY
}

public class PropertyModel: NSObject {
    public var id = ""
    public var name = ""
    public var order = ""
    public var dataType = DataType.STRING
    public var uiType = UIType.TEXT
    public var unit = ""
    public var accessMode = ""
    public var resourceId = ""
    public var creator = ""
    public var modifier = ""
    public var createdDate = ""
    public var modifiedDate = ""
    
    public var logControl: Any? = nil
    public var logCollect: Any? = nil

    func loadFields(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        order = json["order"] as? String ?? ""
        dataType = DataType(rawValue: json["dataType"] as? String ?? DataType.STRING.rawValue) ?? .STRING
        uiType = UIType(rawValue: json["uiType"] as? String ?? UIType.TEXT.rawValue) ?? .TEXT
        unit = json["unit"] as? String ?? ""
        accessMode = json["accessMode"] as? String ?? ""
        resourceId = json["resourceId"] as? String ?? ""
        creator = json["creator"] as? String ?? ""
        modifier = json["modifier"] as? String ?? ""
        createdDate = json["createdDate"] as? String ?? ""
        modifiedDate = json["modifiedDate"] as? String ?? ""
    }
}
