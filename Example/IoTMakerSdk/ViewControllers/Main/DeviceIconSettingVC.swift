//
//  DeviceIconSettingVC.swift
//  demoapp
//
//  Created by Coding on 06.03.21.
//

import UIKit
import IoTMakerSdk

class DeviceIconSettingVC: UIViewController {
    @IBOutlet weak var iconCV: UICollectionView!
    @IBOutlet weak var btnV: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectedDevice = 0

    var selected = -1 {
        didSet {
            iconCV.reloadData()
        }
    }
    
    var updated = false {
        didSet {
            if updated {
                saveBtn.isEnabled = true
                saveBtn.alpha = 1
            } else {
                saveBtn.isEnabled = false
                saveBtn.alpha = 0.5
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        iconCV.delegate = self
        iconCV.dataSource = self
        
        btnV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        updated = false
        let device = Global.devices[selectedDevice]
        if let resId = device.resIndex {
            selected = resId
        }
    }
    
    func updateDeviceImage() {
        let device = Global.devices[selectedDevice]
        if selected < 0 {
            return
        }
        
        let targetId = device.target.id
        let params = [
            "devImg": "resource_\(selected)"
        ]
        
        let contentType = "application/json;charset=utf-8"
        
        MyLoadingVC.show()
        IoTMakerSdk.postDeviceExtModify(token: Global.token, contentType: contentType, targetId: targetId, deviceId: device.id, params: params) { (response, error) in
            if let response = response {
                MyLoadingVC.hide()
                Global.devices[self.selectedDevice].resIndex = self.selected
                Global.devices[self.selectedDevice].updatedDate = response["updatedDate"] as? String ?? ""
                Global.devices[self.selectedDevice].createdDate = response["createdDate"] as? String ?? ""
                Global.devices[self.selectedDevice].deleted = response["deleted"] as? String ?? ""
                Global.devices[self.selectedDevice].target.id = response["svcTgtId"] as? String ?? ""
                self.navigationController?.popViewController(animated: true)
            } else {
                MyAlertVC.show(message: error ?? "", isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "디바이스 아이콘 설정을\n취소 하시겠습니까?", isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "디바이스 아이콘 설정을\n취소 하시겠습니까?", isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnSave(_ sender: Any) {
        if selected >= 0 {
            updateDeviceImage()
        }
    }
}

extension DeviceIconSettingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Global.ICON_LIST.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceIconCVC", for: indexPath) as! DeviceIconCVC
        
        cell.iconIV.image = UIImage(named: Global.ICON_LIST[indexPath.row])
        cell.nameLbl.text = Global.NAME_LIST[indexPath.row]
        
        if selected == indexPath.row {
            cell.containerV.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.2588235294, blue: 0.368627451, alpha: 1)
            cell.nameLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.circleYellowV.isHidden = true
            cell.iconIV.image = cell.iconIV.image?.imageWithColor(color1: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        } else {
            cell.containerV.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.nameLbl.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            cell.circleYellowV.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updated = true
        selected = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let w = collectionView.frame.width/3
        return CGSize(width: w, height: w)
    }

}

class DeviceIconCVC: UICollectionViewCell {
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var circleYellowV: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
}
