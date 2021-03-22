//
//  DeviceControllerRadioVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlRadioVC: DeviceControlBaseVC {

    @IBOutlet weak var radioTV: UITableView!
    @IBOutlet weak var stateLbl: UILabel!
    
    var selectedItem = -1
    
    var uiValues: [UIValueModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let property = resource.properties[selectedProperty]
        uiValues = Global.devices[selectedDevice].model.uiCapability?[resource.id]?[property.id]?.uiValues
        if let uiValues = uiValues {
            if let log = property.logControl {
                
                let index = uiValues.firstIndex(where: { (v) -> Bool in
                    return String(describing: v.data) == String(describing: log)
                })
                
                if let index = index, index >= 0 {
                    selectedItem = index
                    stateLbl.text = uiValues[index].name
                }
            }
        }

        radioTV.delegate = self
        radioTV.dataSource = self
    }

}

extension DeviceControlRadioVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uiValues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ControlRadioTVC", for: indexPath) as! ControlRadioTVC
            
        cell.nameLbl.text = uiValues![indexPath.row].name
        cell.radioIV.image = selectedItem == indexPath.row ? UIImage(named: "radio-on") : nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedItem == indexPath.row {
            return
        }
        
        sendCtrlMsg(value: uiValues![indexPath.row].data) { success in
            if success {
                self.selectedItem = indexPath.row
                self.resource.properties[self.selectedProperty].logControl = self.uiValues![self.selectedItem].data
                self.stateLbl.text = self.uiValues![self.selectedItem].name
                tableView.reloadData()
            }
        }
    }
}

class ControlRadioTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var radioIV: UIImageView!
}
