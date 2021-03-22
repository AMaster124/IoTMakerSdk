//
//  IoTMakerSdk.swift
//  IoTMakerSdk
//
//  Created by Coding on 09.03.21.
//

import Foundation
import Alamofire

public class IoTMakerSdk: NSObject {
    public static func configure(isPublic: Bool = true, apiUrl: String? = nil) {
        Constants.TEST_MODE = !isPublic
        if let apiUrl = apiUrl {
            Constants.BASE_URL = apiUrl
        } else {
            Constants.BASE_URL = isPublic ? Constants.PUBLIC_API_URL : Constants.TEST_API_URL
        }
    }
    
    public static func gigaIotOAuth( username: String, password: String, completion: @escaping ([String: Any]?, String?)->Void) {
        guard let data = ("\(Constants.CLIENT_ID):\(Constants.CLIENT_SECRET)").data(using: .utf8) else {
            return
        }
        
        let authString = "Basic " + data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let header = [
            "Authorization": authString
        ]
        
        let params = [
            "username": username,
            "password": password,
            "grant_type": password == "" ? "client_credentials" : "password"
        ]
        
        Alamofire.request(Constants.BASE_URL + "/oauth/token", method: .post, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [String: Any], nil)
            }
        }

    }
    
    public static func getDeviceList( token: String, offset: Int, limit: Int, username: String, completion: @escaping ([DeviceModel]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString
        ]
        
        let params = [
            "offset": offset,
            "limit": limit,
            "requester": username
        ] as [String : Any]
        
        Alamofire.request(Constants.BASE_URL + "/devices", method: .get, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let jsonArray = response.result.value as? [[String: Any]] {
                var devices = [DeviceModel]()
                for i in 0 ..< jsonArray.count {
                    let device = DeviceModel()
                    device.loadFields(json: jsonArray[i])
                    devices.append(device)
                }
                
                completion(devices, nil)
            } else {
                if let error = response.error {
                    completion(nil, error.localizedDescription)
                } else if let data = response.result.value as? [String: Any] {
                    completion(nil, data["error"] as? String ?? "Unknown Error")
                } else {
                    completion(nil, "Unknown Error")
                }
            }
            
        }

    }
    
    public static func getDeviceStatus( token: String, deviceId: String, targetId: String, completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        let params = [
            "deviceId": deviceId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/\(deviceId)/connectionStatus", method: .get, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else if let json = response.result.value as? [String: Any] {
                if let error = json["error"] as? String {
                    completion(nil, error)
                } else {
                    completion(json, nil)
                }
            }
        }

    }
    
    public static func postDeviceModify( token: String, contentType: String, targetId: String, deviceId: String, memberId: String, params: [String: Any], completion: @escaping (String?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/\(deviceId)?memberId=\(memberId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let device = response.result.value as? [String: Any] {
                if let name = device["name"] as? String {
                    completion(name, nil)
                } else if let error = device["error"] as? String {
                    completion(nil, error)
                } else {
                    completion(nil, "Unknown Error")
                }
            } else {
                completion(nil, "Unknown Error")
            }
        }
    }
    
    public static func getModelList( token: String, modelId: String, completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/models/\(modelId)", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                if let json = response.result.value as? [String: Any] {
                    completion(json, "Server Error")
                } else {
                    completion(nil, "Server Error")
                }
            }
        }

    }
    
    public static func getResources( token: String, targetId: String, deviceId: String, resourceId: String, params: [String: Any], completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/\(deviceId)/resources/\(resourceId)", method: .get, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [[String : Any]], nil)
            }
        }
    }
    
    public static func getResourceLogCollect( token: String, targetId: String, deviceId: String, resourceId: String, createdFrom: String, createdTo: String, serviceCode: String, offset: Int, limit: Int, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
//        let urlCreateFrom = createdFrom.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
//        let urlCreateTo = createdFrom.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlCreateFrom = createdFrom.replacingOccurrences(of: " ", with: "%20")
        let urlCreateTo = createdTo.replacingOccurrences(of: " ", with: "%20")

        let url = "\(Constants.BASE_URL)/devices/logs/collect/\(deviceId)/resources/\(resourceId)?createdFrom=\(urlCreateFrom)&createdTo=\(urlCreateTo)&serviceCode=\(serviceCode)&offset=\(offset)&limit=\(limit)"
        Alamofire.request(url, method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                if let list = response.result.value as? [[String: Any]] {
                    completion(list, nil)
                } else {
                    if let json = response.result.value as? [String: Any] {
                        completion(nil, json["message"] as? String ?? "Server Error")
                    } else {
                        completion(nil, "Server Error")
                    }
                }
            }
        }
    }
    
    public static func getResourceLogCollect2( token: String, targetId: String, deviceId: String, resourceId: String, serviceCode: String, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        let params = [
            "serviceCode": serviceCode
        ] as [String : Any]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/logs/collect/\(deviceId)/resources/\(resourceId)", method: .get, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [[String : Any]], nil)
            }
        }
    }
    
    public static func getResourceLogControl( token: String, targetId: String, deviceId: String, resourceId: String, createdFrom: String, createdTo: String, serviceCode: String, offset: Int, limit: Int, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        let urlCreateFrom = createdFrom.replacingOccurrences(of: " ", with: "%20")
        let urlCreateTo = createdTo.replacingOccurrences(of: " ", with: "%20")

        let url = "\(Constants.BASE_URL)/devices/logs/control/\(deviceId)/resources/\(resourceId)?createdFrom=\(urlCreateFrom)&createdTo=\(urlCreateTo)&serviceCode=\(serviceCode)&offset=\(offset)&limit=\(limit)"

        Alamofire.request(url, method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            if let list = response.result.value as? [[String: Any]] {
                completion(list, nil)
            } else {
                if let json = response.result.value as? [String: Any] {
                    completion(nil, json["message"] as? String ?? "Server Error")
                } else {
                    completion(nil, "Server Error")
                }
            }
        }
    }
    
    public static func getResourceLogControl2( token: String, targetId: String, deviceId: String, resourceId: String, serviceCode: String, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        let params = [
            "serviceCode": serviceCode
        ] as [String : Any]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/logs/control/\(deviceId)/resources/\(resourceId)", method: .get, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [[String : Any]], nil)
            }
        }
    }
    
    public static func postResourceCtrl( token: String, contentType: String, targetId: String, deviceId: String, resourceId: String, params: [String: Any], completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId,
            "Content-Type": contentType
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/devices/\(deviceId)/resources/\(resourceId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else if let json = response.result.value as? [String: Any] {
                if let message = json["message"] as? String {
                    completion(nil, message)
                } else {
                    completion(json, nil)
                }
            } else {
                completion(nil, "Server Error")
            }
        }
    }
    
    public static func getEventList( token: String, targetId: String, completion: @escaping ([EventModel]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/events", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                var events = [EventModel]()
                if let json = response.result.value as? [String: Any] {
                    if let jsonArry = json["events"] as? [[String: Any]] {
                        for i in 0 ..< jsonArry.count {
                            let event = EventModel()
                            event.loadFields(json: jsonArry[i])
                            events.append(event)
                        }
                        completion(events, nil)
                    } else {
                        completion(nil, json["message"] as? String ?? "Server Error")
                    }
                } else {
                    completion(nil, "Server Error")
                }
            }
        }
    }
    
    public static func getEventLogList( token: String, targetId: String, eventId: String, to: String, offset: Int, limit: Int, completion: @escaping ([EventLogModel]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId,
            "X-KT-IM-PAGING-OFFSET": "\(offset)",
            "X-KT-IM-PAGING-LIMIT": "\(limit)"
        ]
        
//        let to = to.replacingOccurrences(of: " ", with: "%20")
        let to = to.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        Alamofire.request("\(Constants.BASE_URL)/events/\(eventId)/logs?to=\(to)", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                var logs = [EventLogModel]()
                if let json = response.result.value as? [String: Any] {
                    if let jsonArry = json["eventHistories"] as? [[String: Any]] {
                        for i in 0 ..< jsonArry.count {
                            let event = EventLogModel()
                            event.loadFields(json: jsonArry[i])
                            logs.append(event)
                        }
                        completion(logs, nil)
                    } else {
                        completion(nil, json["message"] as? String ?? "Server Error")
                    }
                } else {
                    completion(nil, "Server Error")
                }
            }

        }
    }
    
    public static func getMemberInfo( token: String, memberId: String, completion: @escaping (MemberModel?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/members/\(memberId)", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let json = response.result.value as? [String: Any] {
                let member = MemberModel()
                member.loadFields(json: json)
                
                completion(member, nil)
            } else {
                if let error = response.error {
                    completion(nil, error.localizedDescription)
                } else if let data = response.result.value as? [String: Any] {
                    completion(nil, data["error"] as? String ?? "Unknown Error")
                } else {
                    completion(nil, "Unknown Error")
                }
            }

        }
    }
    
    public static func postPushSessionReg( token: String, targetId: String, someTestFcmSubId: String, params: [String: Any], completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/subscriptions/\(someTestFcmSubId)", method: .post, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [[String : Any]], nil)
            }
        }
    }
    
    public static func postPushSessionDel( token: String, targetId: String, someTestFcmSubId: String, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/subscriptions/\(someTestFcmSubId)", method: .delete, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [[String : Any]], nil)
            }
        }
    }
    
    public static func getGroupList( token: String, completion: @escaping ([GroupModel]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                if let jsonArray = response.result.value as? [[String: Any]] {
                    var groups = [GroupModel]()
                    for i in 0 ..< jsonArray.count {
                        let group = GroupModel()
                        group.loadFields(json: jsonArray[i])
                        groups.append(group)
                    }
                    
                    completion(groups, nil)
                } else {
                    if let error = response.error {
                        completion(nil, error.localizedDescription)
                    } else if let data = response.result.value as? [String: Any] {
                        completion(nil, data["error"] as? String ?? "Unknown Error")
                    } else {
                        completion(nil, "Unknown Error")
                    }
                }

            }
        }
    }
    
    public static func postGroupModify( token: String, contentType: String, devGroupId: String, params: [String: Any], completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups/\(devGroupId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [String : Any], nil)
            }
        }
    }
    
    public static func postAddGroup( token: String, contentType: String, params: [String: Any], completion: @escaping (GroupModel?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                if let json = response.result.value as? [String: Any] {
                    let group = GroupModel()
                    group.loadFields(json: json)
                    
                    if let message = json["message"] as? String {
                        completion(nil, message)
                    } else {
                        completion(group, nil)
                    }
                } else {
                    completion(nil, "Server Error")
                }
            }
        }
    }
    
    public static func deleteGroup( token: String, contentType: String, devGroupId: String, completion: @escaping (Bool, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups/\(devGroupId)", method: .delete, encoding: URLEncoding.default, headers: header).responseData { data in
            
            if let statusCode = data.response?.statusCode, statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, "No group is deleted.")
            }
        }
    }
    
    public static func getGroupDevices( token: String, devGroupId: String, completion: @escaping ([[String: Any]]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups/\(devGroupId)/list", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let jsonArray = response.result.value as? [[String: Any]] {
                completion(jsonArray, nil)
            } else {
                if let error = response.error {
                    completion(nil, error.localizedDescription)
                } else if let data = response.result.value as? [String: Any] {
                    completion(nil, data["error"] as? String ?? "Unknown Error")
                } else {
                    completion(nil, "Unknown Error")
                }
            }
        }
    }
    
    public static func postAddGroupDevice( token: String, contentType: String, targetId: String, devGroupId: String, params: [String: Any], completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups/\(devGroupId)/list", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let array = response.result.value as? [[String: Any]], array.count > 0 {
                completion(array[0], nil)
            } else if let json = response.result.value as? [String: Any],
                      let message = json["message"] as? String {
                completion(nil, message)
            } else if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(nil, "No device is added to group")
            }
        }
    }
    
    public static func deleteGroupDevice( token: String, contentType: String, targetId: String, devGroupId: String, params: [String: Any], completion: @escaping (Bool, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/deviceGroups/\(devGroupId)/list", method: .delete, parameters: params, encoding: JSONEncoding.default, headers: header).responseData { (data) in
            if let statusCode = data.response?.statusCode, statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, "No device is deleted in group")
            }
        }
    }
    
    public static func postDeviceExtModify( token: String, contentType: String, targetId: String, deviceId: String, params: [String: Any], completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/devices/\(deviceId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                 completion(response.result.value as? [String : Any], nil)
            }
        }
    }
    
    public static func getDeviceImage( token: String, contentType: String, targetId: String, deviceId: String, completion: @escaping ([String: Any]?, String?)->Void) {
        let authString = "Bearer " + token
        let header = [
            "Authorization": authString,
            "Content-Type": contentType,
            "X-KT-IM-TARGET-ID": targetId
        ]
        
        Alamofire.request("\(Constants.BASE_URL)/opensvc/devices/\(deviceId)/image", method: .get, encoding: URLEncoding.default, headers: header).responseJSON { response in
            
            if let error = response.error {
                completion(nil, error.localizedDescription)
            } else {
                completion(response.result.value as? [String : Any], nil)
            }
        }
    }
    
}
