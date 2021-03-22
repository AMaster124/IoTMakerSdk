//
//  DeviceControlSwitchVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlSwitchVC: DeviceControlBaseVC {
    @IBOutlet weak var switchTV: UITableView!
    @IBOutlet weak var stateLbl: UILabel!

    var uiValues: [UIValueModel]? = nil
    var stateName = [String: String]()

//    var selectedCell = 0 {
//        didSet {
//            if selectedCell >= 0 {
//                switchTV.reloadData()
//            }
//        }
//    }
    
    var isOn: Bool = false {
        didSet {
            if isOn {
                stateLbl.text = stateName["0"] ?? "켜짐"
            } else {
                stateLbl.text = stateName["1"] ?? "꺼짐"
            }
            switchTV.reloadData()
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

        if let uiValues = uiValues,
           let log = property.logControl,
           let index = uiValues.firstIndex(where: { (v) -> Bool in
               return String(describing: v.data) == String(describing: log)
           }),
           index >= 0,
           uiValues[index].name.uppercased() == "ON" {
            isOn = true
        } else {
            isOn = false
        }

        switchTV.delegate = self
        switchTV.dataSource = self
    }
}

extension DeviceControlSwitchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uiValues != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ControlSwitchCell", for: indexPath) as! ControlSwitchCell
        
        cell.nameLbl.text = isOn ? "켜짐" : "꺼짐"
        if isOn {
            if let str = stateName["0"] {
                cell.nameLbl.text = str
            } else {
                cell.nameLbl.text = "켜짐"
            }
        } else {
            if let str = stateName["1"] {
                cell.nameLbl.text = str
            } else {
                cell.nameLbl.text = "꺼짐"
            }
        }

        cell.controlSwitch.layer.cornerRadius = cell.controlSwitch.frame.height/2
        cell.controlSwitch.isOn = isOn
        
        cell.handlerSwitch = { isOn in
            self.sendCtrlMsg(value: self.isOn ? "1" : "0") { success in
                if success {
                    self.resource.properties[self.selectedProperty].logControl = self.isOn ? "1" : "0"
                    self.isOn = !self.isOn
                } else {
                    tableView.reloadData()
                }
            }

//            if let uiValues = self.uiValues {
//                if isOn == true, let value = uiValues.first(where: { (v) -> Bool in
//                    return v.name.uppercased() == "ON"
//                }) {
//                    self.sendCtrlMsg(value: value.data) { success in
//                        if success {
//                            self.resource.properties[self.selectedProperty].logControl = value.data
//                            self.isOn = isOn
//                        } else {
//                            self.isOn = !isOn
//                        }
//                    }
//                } else if isOn == false, let value = uiValues.first(where: { (v) -> Bool in
//                    return v.name.uppercased() == "OFF"
//                }) {
//                    self.sendCtrlMsg(value: value.data) { success in
//                        if success {
//                            self.isOn = isOn
//                            self.resource.properties[self.selectedProperty].logControl = value.data
//                        } else {
//                            self.isOn = !isOn
//                        }
//                    }
//                }
//            }
        }
        
        return cell
    }
}

class ControlSwitchCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var controlSwitch: UISwitch!
    
    var handlerSwitch: ((Bool)->Void)? = nil
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        handlerSwitch?(sender.isOn)
    }
}
