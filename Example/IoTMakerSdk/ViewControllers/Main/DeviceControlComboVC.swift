//
//  DeviceControllComboVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlComboVC: DeviceControlBaseVC {

    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var stateLbl: UILabel!
    
    var comboItems = [String]()
    var uiValues: [UIValueModel]? = nil
    var selectedCombo = -1 {
        didSet {
            if selectedCombo >= 0 {
                inputTF.text = uiValues![selectedCombo].name
                stateLbl.text = uiValues![selectedCombo].name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let property = resource.properties[selectedProperty]
        uiValues = Global.devices[selectedDevice].model.uiCapability?[resource.id]?[property.id]?.uiValues
        if let uiValues = uiValues {
            comboItems = []
            for i in 0 ..< uiValues.count {
                comboItems.append(uiValues[i].name)
            }
            
            if let log = property.logControl {
                let index = uiValues.firstIndex(where: { (v) -> Bool in
                    return String(describing: v.data) == String(describing: log)
                })
                
                if let index = index, index >= 0 {
                    selectedCombo = index
                }
            }
        }

    }
    
    @IBAction func onBtnCombo(_ sender: Any) {
        MyPickerVC.show(items: comboItems, selected: selectedCombo) { (index) in
            if index >= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.sendCtrlMsg(value: self.uiValues![index].data) { (sucess) in
                        if sucess {
                            self.resource.properties[self.selectedProperty].logControl = self.uiValues![index].data
                            self.selectedCombo = index
                        }
                    }
                }
            }
        }
    }
}
