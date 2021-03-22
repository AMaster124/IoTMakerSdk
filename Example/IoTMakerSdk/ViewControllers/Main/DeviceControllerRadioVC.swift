//
//  DeviceControllerRadioVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class DeviceControlRadioVC: DeviceControlBaseVC {

    @IBOutlet weak var radioTV: UITableView!
    
    var items = ["제어항목1", "제어항목2"]
    var selectedItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        radioTV.delegate = self
        radioTV.dataSource = self
    }

}

extension DeviceControlRadioVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ControlRadioTVC", for: indexPath) as! ControlRadioTVC
            
        cell.nameLbl.text = items[indexPath.row]
        cell.radioIV.image = selectedItem == indexPath.row ? UIImage(named: "radio-on") : nil
        return cell
    }
    
    
}

class ControlRadioTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var radioIV: UIImageView!
}
