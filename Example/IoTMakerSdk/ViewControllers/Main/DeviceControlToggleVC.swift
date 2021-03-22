//
//  DeviceControlToggleVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlToggleVC: DeviceControlBaseVC {
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var powerIV: UIImageView!
    
    var uiValues: [UIValueModel]? = nil
    var stateName = [String: String]()
    
    var isOn: Bool = false {
        didSet {
            if isOn {
                if let str = stateName["0"] {
                    stateLbl.text = str
                } else {
                    stateLbl.text = "켜짐"
                }
            } else {
                if let str = stateName["1"] {
                    stateLbl.text = str
                } else {
                    stateLbl.text = "꺼짐"
                }
            }
            
            powerIV.tintColor = isOn ? #colorLiteral(red: 0.8823529412, green: 0.2588235294, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let property = resource.properties[selectedProperty]
        uiValues = Global.devices[selectedDevice].model.uiCapability?[resource.id]?[property.id]?.uiValues

        if let uiValues = uiValues, uiValues.count > 0 {
            for i in 0 ..< uiValues.count {
                stateName[String(describing: uiValues[i].data)] = uiValues[i].name
            }
        }

        if let log = property.logControl, String(describing: log) == "0" {
            isOn = true
        } else {
            isOn = false
        }
    }
    
    @IBAction func onBtnTurn(_ sender: UIButton) {
        sendCtrlMsg(value: isOn ? "1" : "0") { success in
            if success {
                self.resource.properties[self.selectedProperty].logControl = self.isOn ? "1" : "0"
                self.isOn = !self.isOn
            }
        }
        
//        if let uiValues = uiValues {
            
//            if isOn == false, let value = uiValues.first(where: { (v) -> Bool in
//                return v.data == "ON"
//            }) {
//                sendCtrlMsg(value: value.data) { success in
//                    if success {
//                        self.isOn = !self.isOn
//                    }
//                }
//            } else if isOn == true, let value = uiValues.first(where: { (v) -> Bool in
//                return v.name.uppercased() == "OFF"
//            }) {
//                sendCtrlMsg(value: value.data) { success in
//                    if success {
//                        self.resource.properties[self.selectedProperty].logControl = value.data
//                        self.isOn = !self.isOn
//                    }
//                }
//            }
//        }
    }
}
