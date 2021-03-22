//
//  DeviceVC.swift
//  demoapp
//
//  Created by Coding on 06.03.21.
//

import UIKit
import IoTMakerSdk
import ExpyTableView

class DeviceVC: UIViewController {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var deviceNameLbl: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var resourceTV: ExpyTableView!
    @IBOutlet weak var emptyLbl: UILabel!
    
    var selectedDevice = 0
    var device = DeviceModel()
    var resources: [ResourceModel]? = nil
    
    var refreshControl = UIRefreshControl()
    var loadingByPull = false

    var logFrom = ""
    var logTo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.device = Global.devices[selectedDevice]
        resources = device.model.resources
        
        emptyLbl.isHidden = true
        resourceTV.isHidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadByPull), for: .valueChanged)
        resourceTV.addSubview(refreshControl)
        resourceTV.alwaysBounceVertical = true

        self.resourceTV.dataSource = self
        self.resourceTV.delegate = self

        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let device = Global.devices[selectedDevice]
        deviceNameLbl.text = device.name
        groupNameLbl.text = device.groupNm
        if let resId = device.resIndex {
            iconIV.image = UIImage(named: Global.IMAGE_LIST[resId])
        } else if let img = device.img {
            iconIV.image = img
        } else {
            iconIV.image = UIImage(named:"img_device_default")
        }
        
        resourceTV.reloadData()
    }
    
    @objc func reloadByPull() {
        loadingByPull = true
        reloadData()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.setLogTime()
            if !self.loadingByPull {
                MyLoadingVC.show()
            }
            
            self.loadingByPull = false
            if self.resources == nil {
                self.loadResources {
                    self.loadValues {
                        MyLoadingVC.hide()
                        self.refreshControl.endRefreshing()
                        self.setContentView()
//                        self.expandCells()
                        self.resourceTV.reloadData()
                    }
                }
            } else {
                self.loadValues {
                    MyLoadingVC.hide()
                    self.refreshControl.endRefreshing()
                    self.setContentView()
                    self.resourceTV.reloadData()
                }
            }
        }
    }
    
    func setContentView() {
        if let rs = resources, rs.count > 0 {
            emptyLbl.isHidden = true
            resourceTV.isHidden = false
        } else {
            emptyLbl.isHidden = false
            resourceTV.isHidden = true
        }
    }
    
    func expandCells() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            for i in 0 ..< self.resourceTV.numberOfSections {
                self.resourceTV.expand(i)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func setLogTime() {
        let to = Date()
        let from = Calendar.current.date(byAdding: .day, value: -100, to: to)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        logTo = formatter.string(from: to)
        logFrom = formatter.string(from: from!)
    }
    
    func loadResources(completion: @escaping(()->Void)) {
        let device = Global.devices[selectedDevice]
        IoTMakerSdk.getModelList(token: Global.token, modelId: device.model.id) { (response, error) in
            if let response = response {
                Global.devices[self.selectedDevice].model.loadFields(json: response)
                self.device = Global.devices[self.selectedDevice]
                self.resources = self.device.model.resources
            } else {
                completion()
            }
            completion()
        }
    }
    
    func loadValues(completion: @escaping(()->Void)) {
        guard let resources = resources else {
            completion()
            return
        }
        
        if resources.count < 1 {
            completion()
        }
        
        loadCollectionValue(index: 0) {
            self.loadControlValues(index: 0) {
                completion()
            }
        }
    }
    
    func loadCollectionValue(index: Int, completion: @escaping(()->Void)) {
        guard let resource = resources?[index] else {
            completion()
            return;
        }
        
        IoTMakerSdk.getResourceLogCollect(token: Global.token, targetId: device.target.id, deviceId: device.id, resourceId: resource.id, createdFrom: logFrom, createdTo: logTo, serviceCode: device.model.serviceCode, offset: 0, limit: 1) { (response, error) in
            if let response = response {
                for collect in response {
                    if let properties = collect["properties"] as? [String: Any] {
                        for key in properties.keys {
                            let i = resource.properties.firstIndex { (r) -> Bool in
                                return r.id == key
                            }
                            
                            if let i = i, i >= 0 {
                                self.resources?[index].properties[i].logCollect = properties[key]
                            }
                        }
                    }
                }
                
                if index < self.resources!.count-1 {
                    self.loadCollectionValue(index: index+1, completion: completion)
                } else {
                    completion()
                }
            } else {
                completion()
                print(error)
           }
        }
    }
    
    func loadControlValues(index: Int, completion: @escaping(()->Void)) {
        guard let resource = resources?[index] else {
            completion()
            return
        }
        
        IoTMakerSdk.getResourceLogControl(token: Global.token, targetId: device.target.id, deviceId: device.id, resourceId: resource.id, createdFrom: logFrom, createdTo: logTo, serviceCode: device.model.serviceCode, offset: 0, limit: 1) { (response, error) in
            if let response = response {
                for control in response {
                    if let properties = control["properties"] as? [String: Any] {
                        for key in properties.keys {
                            let i = resource.properties.firstIndex { (r) -> Bool in
                                return r.id == key
                            }
                            
                            if let i = i, i >= 0 {
                                self.resources?[index].properties[i].logControl = properties[key]
                            }
                        }
                    }
                }
                
                if index < self.resources!.count-1 {
                    self.loadControlValues(index: index+1, completion: completion)
                } else {
                    completion()
                }
            } else {
                completion()
                print(error)
           }
        }

    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnTool(_ sender: Any) {
        MyPickerVC.show(items: ["디바이스 아이콘 설정", "디바이스 명 설정"]) { (index) in
            if index == 0 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceIconSettingVC") as! DeviceIconSettingVC
                vc.selectedDevice = self.selectedDevice
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceNameSettingVC") as! DeviceNameSettingVC
                vc.selectedDevice = self.selectedDevice
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
}

extension DeviceVC: ExpyTableViewDelegate, ExpyTableViewDataSource {
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        
    }
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resources?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources![section].properties.count+1
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceHeaderTVC") as! ResourceHeaderTVC
        cell.nameLbl.text = resources![section].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceTVC", for: indexPath) as! ResourceTVC
        
        let resource = resources![indexPath.section]
        let property = resource.properties[indexPath.row-1]
        let accessMode = property.accessMode
        
        cell.nameLbl.text = property.name
        
        cell.valueLbl.isHidden = true
        cell.unitLbl.isHidden = true

//        var uiType: UIType? = nil
//        if accessMode == "0001" || accessMode == "0003" {
//            if let uicapability = Global.devices[selectedDevice].model.uiCapability, let capItem = uicapability[resource.id]?[property.id] {
//                uiType = capItem.uiType
//            } else if accessMode == "0003" {
//                uiType = .TEXT
//            }
//        }
//
//        if uiType != nil {      // 제어인 경우
            if let _ = property.logControl {     // 제어 데이터 있는 경우
                cell.valueLbl.isHidden = true
                cell.unitLbl.isHidden = true
            }
//        } else {     // 수집인 경우
            else if let collect = property.logCollect {     // 수집데이터 있는 경우
                cell.valueLbl.isHidden = false
                cell.unitLbl.isHidden = false
                cell.valueLbl.text = String(describing: collect)
                cell.unitLbl.text = property.unit
            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 1 {
            return
        }
        
        let device = Global.devices[selectedDevice]
        let resource = resources![indexPath.section]
        let property = resource.properties[indexPath.row-1]
        
        if property.accessMode == "0001" || property.accessMode == "0003" {
            guard let uiCapability = device.model.uiCapability,
                  let resCap = uiCapability[resource.id] as? [String: Any],
                  let propCap = resCap[property.id] as? UICapItemModel else {
                if property.accessMode == "0001", let _ = property.logCollect {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceCollectVC") as! DeviceCollectVC
                    vc.resource = resource
                    vc.selectedProperty = indexPath.row-1
                    vc.selectedDevice = selectedDevice
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlStringVC") as! DeviceControlStringVC
                    vc.resource = resource
                    vc.selectedDevice = selectedDevice
                    vc.selectedProperty = indexPath.row-1
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                return
            }
            
            switch propCap.uiType {
            case .TEXT:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlStringVC") as! DeviceControlStringVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .BUTTON:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlButtonVC") as! DeviceControlButtonVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .SWITCH:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlSwitchVC") as! DeviceControlSwitchVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .TOGGLE:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlToggleVC") as! DeviceControlToggleVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .SLIDER:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlSliderVC") as! DeviceControlSliderVC
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlCircleSliderVC") as! DeviceControlCircleSliderVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .COMBO:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlComboVC") as! DeviceControlComboVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            case .RADIO:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceControlRadioVC") as! DeviceControlRadioVC
                vc.resource = resource
                vc.selectedDevice = selectedDevice
                vc.selectedProperty = indexPath.row-1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if property.accessMode == "0002" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceCollectVC") as! DeviceCollectVC
            vc.resource = resource
            vc.selectedDevice = selectedDevice
            vc.selectedProperty = indexPath.row-1
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class ResourceHeaderTVC: UITableViewCell, ExpyTableViewHeaderCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var arrowIV: UIImageView!
    @IBOutlet weak var lineV: UIView!
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        
        switch state {
        case .willExpand:
            lineV.isHidden = true
            arrowDown()
            
        case .willCollapse:
            lineV.isHidden = false
            arrowRight()
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            print("DID COLLAPSE")
        }
    }
    
    private func arrowDown() {
        UIView.animate(withDuration: (0.3)) {
            self.arrowIV.transform = CGAffineTransform(rotationAngle: (-CGFloat.pi / 2))
        }
    }
    private func arrowRight() {
        UIView.animate(withDuration: (0.3)) {
            self.arrowIV.transform = CGAffineTransform(rotationAngle: (CGFloat.pi / 2))
        }
    }

}

class ResourceTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var propertyV: UIView!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
}
