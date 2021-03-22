//
//  DeviceControlButtonVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 15.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlButtonVC: DeviceControlBaseVC {
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var buttonTV: UITableView!
    
    var uiValues: [UIValueModel]? = nil
    
    var selectedCell = 0 {
        didSet {
            if selectedCell >= 0 {
                stateLbl.text = uiValues![selectedCell].name
                buttonTV.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateLbl.text = ""

        let property = resource.properties[selectedProperty]
        uiValues = Global.devices[selectedDevice].model.uiCapability?[resource.id]?[property.id]?.uiValues
        if let uiValues = uiValues {
            if let log = property.logControl {
                let index = uiValues.firstIndex(where: { (v) -> Bool in
                    return String(describing: v.data) == String(describing: log)
                })
                
                if let index = index, index >= 0 {
                    selectedCell = index
                } else {
                    selectedCell = 0
                }
            } else {
                selectedCell = 0
            }
        }

        buttonTV.delegate = self
        buttonTV.dataSource = self
    }
}

extension DeviceControlButtonVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uiValues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ControlButtonCell") as! ControlButtonCell
        
        let val = uiValues![indexPath.row]
        cell.controlLbl.text = val.name
        if selectedCell == indexPath.row {
            cell.controlLbl.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.controlLbl.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        } else {
            cell.controlLbl.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.2666666667, blue: 0.2156862745, alpha: 1)
            cell.controlLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendCtrlMsg(value: uiValues![indexPath.row].data) { success in
            if success {
                self.resource.properties[self.selectedProperty].logControl = self.uiValues![indexPath.row].data
                self.selectedCell = indexPath.row
            }
        }
    }
}

class ControlButtonCell: UITableViewCell {
    @IBOutlet weak var controlLbl: UILabel!
    
}
