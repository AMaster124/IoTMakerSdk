//
//  Global.swift
//  demoapp
//
//  Created by Coding on 07.03.21.
//

import Foundation
import IoTMakerSdk
import SDWebImage

class Global: NSObject {
    static let shared: Global = {
        let value = Global()
        return value
    }()
    
    static var token = ""
    static var username = ""
    static var member = MemberModel()
    
    static var devices: [DeviceModel] = []
    
    static var groups = [GroupModel]()

    static var ICON_LIST = [
        "ic_device_energy", "ic_device_safe", "ic_device_media", "ic_device_health",
        "ic_device_car", "ic_device_edu", "ic_device_logistics", "ic_device_travel",
        "ic_device_smarthome", "ic_device_smartcity", "ic_device_plant", "ic_device_entertain", "ic_device_smartfactory"
    ]
    
    static var IMAGE_LIST = [
        "ic-energy", "ic-safe", "ic-media", "ic-medical",
        "ic-connected", "ic-edu", "ic-trans", "ic-airplane",
        "ic-home", "ic-city", "ic-farm",
        "ic-intertainment", "ic-factory"
    ]
    
    static var NAME_LIST = [
        "에너지", "보안/안전", "미디어", "헬스/의료",
        "커넥티드카", "교육", "유통/물류", "여행/레져",
        "스마트홈", "스마트시티", "농업",
        "엔터테인먼트", "스마트팩토리"
    ]
    
    static func loadData(completion: @escaping ()->Void) {
        loadDevices() {
            loadGroups {
                if groups.count > 0 {
                    loadGroupDevices(groupId: 0, completion: completion)
                } else {
                    completion()
                }
            }
        }
    }
    
    static func loadDeviceImage(index: Int, completion: (() -> Void)?) {
        if index > Global.devices.count - 1 {
            completion?()
            return
        }

        let device = Global.devices[index]
        if device.groupId != nil {
            loadDeviceImage(index: index+1, completion: completion)
            return
        }

        let contentType = "application/json;charset=utf-8"
        IoTMakerSdk.getDeviceImage(token: Global.token, contentType: contentType, targetId: device.target.id, deviceId: device.id) { (response, error) in
            if let devImg = response?["devImg"] as? String {
                Global.getDeviceImage(devImg: devImg) { (img, resId) in
                    if let img = img {
                        Global.devices[index].icon = img
                        Global.devices[index].img = img
                        Global.devices[index].resIndex = nil
                    } else if let resId = resId {
                        Global.devices[index].icon = nil
                        Global.devices[index].img = nil
                        Global.devices[index].resIndex = resId
                    } else {
                        let img = UIImage(named: "ic_device_default")
                        Global.devices[index].icon = img
                        Global.devices[index].img = img
                        Global.devices[index].resIndex = nil
                    }
                }
            }
            
            loadDeviceImage(index: index+1, completion: completion)
        }
    }
    
    static func loadDeviceStatus(index: Int, completion: (() -> Void)?) {
        if index > Global.devices.count - 1 {
            completion?()
            return
        }

        let device = Global.devices[index]

        IoTMakerSdk.getDeviceStatus(token: Global.token, deviceId: device.id, targetId: device.target.id, completion: { (response, error) in
            if let response = response {
                Global.devices[index].connectionId = response["connectionId"] as? String ?? ""
                Global.devices[index].isConnected = (response["isConnected"] as? String ?? "") == "true"
            }
            loadDeviceStatus(index: index+1, completion: completion)
        })
    }
    
    static func loadGroups(completion: (() -> Void)?) {
        IoTMakerSdk.getGroupList(token: Global.token) { (groups, error) in
            if let groups = groups {
                Global.groups = groups
            } else {
                MyAlertVC.show(message: error!, isConfirm: false)
            }
            completion?()
        }
    }
    
    static func loadDevices(completion: (()->Void)? = nil) {
        IoTMakerSdk.getDeviceList(token: Global.token, offset: 0, limit: 20, username: Global.username) { (devices, error) in
            if let devices = devices {
                Global.devices = devices
            }
            completion?()
        }
    }

    static func loadGroupDevices(groupId: Int, completion: (() -> Void)?) {
        IoTMakerSdk.getGroupDevices(token: Global.token, devGroupId: Global.groups[groupId].devGroupId) { (devices, error) in
            if let devices = devices {
                var indexes = [Int]()
                let tempIV = UIImageView()
                for i in 0 ..< devices.count {
                    let deviceId = devices[i]["spotDevId"] as? String ?? ""
                    let index = Global.devices.firstIndex { (d) -> Bool in
                        return d.id == deviceId
                    }
                    
                    if let index = index {
                        Global.devices[index].groupId = devices[i]["devGroupId"] as? String ?? ""
                        Global.devices[index].groupNm = devices[i]["devGroupNm"] as? String ?? ""
                        Global.devices[index].target.id = devices[i]["svcTgtId"] as? String ?? ""
                        if let devImg = devices[i]["devImg"] as? String {
                            Global.getDeviceImage(devImg: devImg) { (img, resId) in
                                if let img = img {
                                    Global.devices[index].icon = img
                                    Global.devices[index].img = img
                                    Global.devices[index].resIndex = nil
                                } else if let resId = resId {
                                    Global.devices[index].icon = nil
                                    Global.devices[index].img = nil
                                    Global.devices[index].resIndex = resId
                                } else {
                                    let img = UIImage(named: "ic_device_default")
                                    Global.devices[index].icon = img
                                    Global.devices[index].img = img
                                    Global.devices[index].resIndex = nil
                                }
                            }
                        }
                        
                        indexes.append(index)
                    }
                }
                
                Global.groups[groupId].devices = indexes
                if groupId < Global.groups.count - 1 {
                    loadGroupDevices(groupId: groupId+1, completion: completion)
                } else {
                    completion?()
                }
            }
        }
    }


    static func getDeviceImage(devImg: String, completion: @escaping ((UIImage?, Int?)->Void)) {
        if devImg.starts(with: "http") {
            let tempIV = UIImageView()
            tempIV.sd_setImage(with: URL(string: devImg)) { (img, error, cacheType, url) in
                if let img = img {
                    completion(img, nil)
                } else {
                    completion(UIImage(named: "ic_device_default")!, nil)
                }
            }
        } else if devImg.starts(with: "resource_") {
            let iStr = devImg.replacingOccurrences(of: "resource_", with: "")
            let i = Int(iStr) ?? -1
            completion(nil, i)
        } else {
            if let index = devImg.index(of: "base64,") {
                let base64 = devImg[index...].replacingOccurrences(of: "base64,", with: "")
                if let imgData = Data(base64Encoded: base64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) {
                    completion(UIImage(data: imgData), nil)
                } else {
                    completion(UIImage(named: "ic_device_default")!, nil)
                }
            } else {
                completion(UIImage(named: "ic_device_default")!, nil)
            }
        }
    }
}
