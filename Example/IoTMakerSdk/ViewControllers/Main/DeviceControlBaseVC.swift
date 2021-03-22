//
//  DeviceControlBaseVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlBaseVC: UIViewController {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var iconIV: UIImageView!
    

    var selectedDevice = 0
    var resource = ResourceModel()
    var selectedProperty = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    func initUI() {
        let device = Global.devices[selectedDevice]
        let property = resource.properties[selectedProperty]
        
        nameLbl.text = "\(resource.name)-\(property.name)"
        if let resId = device.resIndex {
            iconIV.image = UIImage(named: Global.IMAGE_LIST[resId])
        } else if let img = device.img {
            iconIV.image = img
        } else {
            iconIV.image = UIImage(named:"img_device_default")
        }
    }
    
    func validateControlValue(value: Any) -> Any? {
        let property = resource.properties[selectedProperty]
        switch property.dataType {
        case .DOUBLE:
            if let val = value as? String {
                return Double(val)
            } else {
                return nil
            }
        case .INTEGER:
            if let val = value as? String {
                return Int(val)
            } else {
                return nil
            }
        default:
            return value as? String
        }

    }
    
    func sendCtrlMsg(value: Any, completion: @escaping((Bool)->Void)) {
        guard let val = validateControlValue(value: value) else {
            MyAlertVC.show(message: "데이터의 자료형이 타당하지 않습니다.", isConfirm: false)
            completion(false)
            return
        }
        
        let property = resource.properties[selectedProperty]
        var params = [String: Any]()
        
        switch property.dataType {
        case .DOUBLE:
            params[property.id] = val as! Double
        case .INTEGER:
            params[property.id] = val as! Int
        default:
            params[property.id] = val as! String
        }
        
        let device = Global.devices[selectedDevice]
        let contentType = "application/json;charset=utf-8"

        MyLoadingVC.show()
        IoTMakerSdk.postResourceCtrl(token: Global.token, contentType: contentType, targetId: device.target.id, deviceId: device.id, resourceId: resource.id, params: params) { (response, error) in
            if let error = error {
                MyAlertVC.show(message: error, isConfirm: false) {
                    MyLoadingVC.hide()
                    completion(false)
                }
            } else {
                MyLoadingVC.hide()
                print(response)
                completion(true)
            }
        }
    }

    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
