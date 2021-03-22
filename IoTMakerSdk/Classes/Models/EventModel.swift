//
//  EventModel.swift
//  IoTMakerSdk
//
//  Created by Coding on 13.03.21.
//

import Foundation

public class EventModel: NSObject {
    public var eventId = ""
    public var eventName = ""
    public var eventType = ""
    public var eventGradeCode = ""
    public var targetId = ""
    public var themeCode = ""
    public var unitServiceCode = ""
    public var districtCode = ""
    public var eplStatus = ""
    public var eplStatement = ""
    public var billingGradeCode = ""
    public var creatorId = ""
    public var createDate = ""
    public var amenderId = ""
    public var amendDate = ""
    public var extensions = [ExtensionModel]()
    public var deviceExtensions = [DeviceExtensionModel]()
    
    func loadFields(json: [String: Any]) {
        eventId = json["eventId"] as? String ?? ""
        eventName = json["eventName"] as? String ?? ""

        let arry1 = json["extensions"] as? [[String: Any]]
        if let arry1 = arry1 {
            extensions = []
            for j in arry1 {
                let e = ExtensionModel()
                e.loadFields(json: j)
                extensions.append(e)
            }
        }
        
        let arry2 = json["deviceExtensions"] as? [[String: Any]]
        if let arry2 = arry2 {
            deviceExtensions = []
            for j in arry2 {
                let e = DeviceExtensionModel()
                e.loadFields(json: j)
                deviceExtensions.append(e)
            }
        }
    }
}

public class ExtensionModel: NSObject {
    public var attributeName = ""
    public var attributeValue = ""
    
    func loadFields(json: [String: Any]) {
        attributeName = json["attributeName"] as? String ?? ""
        attributeValue = json["attributeValue"] as? String ?? ""
    }
}

public class DeviceExtensionModel: NSObject {
    public var deviceId = ""
    public var propertyId = ""
    public var resourceId = ""
    public var deviceExtensionSequence = 0
    
    func loadFields(json: [String: Any]) {
        deviceId = json["deviceId"] as? String ?? ""
        propertyId = json["propertyId"] as? String ?? ""
        resourceId = json["resourceId"] as? String ?? ""
        deviceExtensionSequence = json["deviceExtensionSequence"] as? Int ?? 0
    }
}

public class EventLogModel: NSObject {
    public var occurrenceDate = ""
    public var targetId = ""
    public var eventHistorySequence = ""
    public var eventId = ""
    public var data = [String: Any]()

    func loadFields(json: [String: Any]) {
        occurrenceDate = json["occurrenceDate"] as? String ?? ""
        targetId = json["targetId"] as? String ?? ""
        eventHistorySequence = json["eventHistorySequence"] as? String ?? ""
        eventId = json["eventId"] as? String ?? ""
        data = json["data"] as? [String: Any] ?? [:]
    }
}

