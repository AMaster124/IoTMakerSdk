//
//  GroupInfoVC.swift
//  demoapp
//
//  Created by Coding on 07.03.21.
//

import UIKit
import IoTMakerSdk

class GroupInfoVC: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var btnV: UIView!
    @IBOutlet weak var btnVBottom: NSLayoutConstraint!
    @IBOutlet weak var deviceTV: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectedGroup = 0
    var registeredDevices = [Int]()
    var unregisteredDevices = [Int]()
    var addedDevices = [Int]()
    var removedDevices = [Int]()

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

    let contentType = "application/json;charset=utf-8"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let tapManager = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped))
        self.view.addGestureRecognizer(tapManager)

//        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        updated = false
        nameTF.text = Global.groups[selectedGroup].devGroupNm
        
        reloadData()
        deviceTV.delegate = self
        deviceTV.dataSource = self
        deviceTV.isEditing = true
        deviceTV.contentInset = UIEdgeInsets(top: -32, left: 0, bottom: 20, right: 0)
        self.deviceTV.tableFooterView = UIView(frame: .zero)

        nameTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 {
                return
            }
            
            UIView.animate(withDuration: 0.5) {
                self.btnVBottom.constant = keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.5) {
            self.btnVBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func viewDidTapped() {
        self.view.endEditing(true)
    }
    
    func reloadData() {
        registeredDevices = Global.groups[selectedGroup].devices ?? []
        setUnregisteredDevices()
        deviceTV.reloadData()
    }
    
    func setUnregisteredDevices() {
        unregisteredDevices = []
        
        for i in 0 ..< Global.devices.count {
            let device = Global.devices[i]
            if device.groupId == nil {
                unregisteredDevices.append(i)
            }
        }
    }
    
    func addDevice(index: Int, dvIndex: Int, completion: @escaping(()-> Void)) {
        
        let device = Global.devices[dvIndex]
        let group = Global.groups[selectedGroup]
        
        let params = [
            "svcTgtId": device.target.id,
            "spotDevId": device.id
        ] as [String : Any]
        
        IoTMakerSdk.postAddGroupDevice(token: Global.token, contentType: contentType, targetId: device.target.id, devGroupId: group.devGroupId, params: params) { (response, error) in
            if let response = response {
                Global.devices[dvIndex].target.id = response["svcTgtId"] as? String ?? ""
                Global.devices[dvIndex].groupId = response["devGroupId"] as? String ?? ""
                Global.devices[dvIndex].groupNm = response["devGroupNm"] as? String ?? ""
                Global.groups[self.selectedGroup].devices?.append(dvIndex)
                if index < self.addedDevices.count-1 {
                    self.addDevice(index: index+1, dvIndex: self.addedDevices[index+1], completion: completion)
                } else {
                    completion()
                }
            } else {
                MyAlertVC.show(message: error!, isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    func deleteGroup(completion: @escaping(()-> Void)) {
        IoTMakerSdk.deleteGroup(token: Global.token, contentType: contentType, devGroupId: Global.groups[selectedGroup].devGroupId) { (response, error) in
            if let error = error {
                MyAlertVC.show(message: error, isConfirm: false)
            } else {
                Global.groups.remove(at: self.selectedGroup)
                completion()
            }
        }
    }
    
    func removeDeviceForDelete(index: Int, completion: @escaping(()-> Void)) {
        let device = Global.devices[index]
        let group = Global.groups[selectedGroup]
        
        let params = [
            "svcTgtId": device.target.id,
            "spotDevId": device.id
        ] as [String : Any]
        
        IoTMakerSdk.deleteGroupDevice(token: Global.token, contentType: contentType, targetId: device.target.id, devGroupId: group.devGroupId, params: params) { (success, error) in
            if success == true {
                Global.devices[index].groupId = nil
                Global.devices[index].groupNm = nil
                
                if index < group.devices!.count-1 {
                    self.removeDeviceForDelete(index: index+1, completion: completion)
                } else {
                    completion()
                }
            } else {
                MyAlertVC.show(message: error!, isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    func removeDevice(index: Int, dvIndex: Int, completion: @escaping(()-> Void)) {
        let device = Global.devices[dvIndex]
        let group = Global.groups[selectedGroup]
        
        let params = [
            "svcTgtId": device.target.id,
            "spotDevId": device.id
        ] as [String : Any]
        
        IoTMakerSdk.deleteGroupDevice(token: Global.token, contentType: contentType, targetId: device.target.id, devGroupId: group.devGroupId, params: params) { (success, error) in
            if success == true {
                Global.devices[dvIndex].groupId = nil
                Global.devices[dvIndex].groupNm = nil
                
                let id = Global.groups[self.selectedGroup].devices?.firstIndex(of: dvIndex)
                if let id = id, id >= 0 {
                    Global.groups[self.selectedGroup].devices?.remove(at: id)
                }
                
                if index < self.removedDevices.count-1 {
                    self.removeDevice(index: index+1, dvIndex: self.removedDevices[index+1], completion: completion)
                } else {
                    completion()
                }
            } else {
                MyAlertVC.show(message: error!, isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    func updateGroupName( completion: @escaping(()->Void)) {
        let group = Global.groups[selectedGroup]
        
        let params = [
            "devGroupNm": nameTF.text!,
            "groupIndcOdrg": group.groupIndcOdrg
        ] as [String : Any]
        
        MyLoadingVC.show()
        IoTMakerSdk.postGroupModify(token: Global.token, contentType: contentType, devGroupId: group.devGroupId, params: params) { (response, error) in
            MyLoadingVC.hide()
            if let response = response {
                Global.groups[self.selectedGroup].devGroupNm = response["devGroupNm"] as? String ?? ""
                Global.groups[self.selectedGroup].updator = response["updater"] as? String ?? ""
                Global.groups[self.selectedGroup].updatedDate = response["updatedDate"] as? String ?? ""
                completion()
            }
        }
    }
    
    func updateGroupDevices() {
        if removedDevices.count > 0 {
            MyLoadingVC.show()
            removeDevice(index: 0, dvIndex: removedDevices[0]) {
                if self.addedDevices.count > 0 {
                    self.addDevice(index: 0, dvIndex: self.addedDevices[0]) {
                        MyLoadingVC.hide()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    MyLoadingVC.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else if addedDevices.count > 0 {
            MyLoadingVC.show()
            self.addDevice(index: 0, dvIndex: self.addedDevices[0]) {
                MyLoadingVC.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        updated = true
    }
    
    @IBAction func onBtnInputClear(_ sender: Any) {
        updated = true
        nameTF.text = ""
    }
    
    @IBAction func onBtnDeleteGroup(_ sender: Any) {
        MyAlertVC.show(message: "그룹을\n삭제 하시겠습니까?") {
            MyLoadingVC.show()
            if let devices = Global.groups[self.selectedGroup].devices, devices.count > 0 {
                self.removeDeviceForDelete(index: 0) {
                    self.deleteGroup {
                        MyLoadingVC.hide()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                self.deleteGroup() {
                    MyLoadingVC.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 정보 수정을\n취소 하시겠습니까?") {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 정보 수정을\n취소 하시겠습니까?") {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnSave(_ sender: Any) {
        let groupName = nameTF.text!
        if nameTF.text!.count < 1 {
            MyAlertVC.show(message: "그룹이름을 입력해주세요", isConfirm: false)
            return
        }
        
        
        if Global.groups[selectedGroup].devGroupNm == groupName {
            updateGroupDevices()
        } else {
            updateGroupName {
                self.updateGroupDevices()
            }
        }
    }
}

extension GroupInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return registeredDevices.count > 0 ? registeredDevices.count : 1
        } else {
            return unregisteredDevices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoTVC", for: indexPath) as! GroupInfoTVC
        if indexPath.section == 0 {
            if registeredDevices.count < 1 {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyTVC")
                return emptyCell!
            } else {
                cell.controlBtn.setImage(UIImage(named: "ic-minus"), for: .normal)
                cell.nameLbl.text = Global.devices[registeredDevices[indexPath.row]].name
                
                cell.addOrRemoveToGroup = { () in
                    self.updated = true
                    let dvIndex = self.registeredDevices[indexPath.row]
                    self.unregisteredDevices.append(dvIndex)
                    self.removedDevices.append(dvIndex)
                    let index = self.addedDevices.firstIndex(of: dvIndex)
                    if let index = index, index >= 0 {
                        self.addedDevices.remove(at: index)
                    }
                    self.registeredDevices.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
        } else {
            cell.controlBtn.setImage(UIImage(named: "ic-plus"), for: .normal)
            cell.nameLbl.text = Global.devices[unregisteredDevices[indexPath.row]].name
            
            cell.addOrRemoveToGroup = { () in
                self.updated = true
                let dvIndex = self.unregisteredDevices[indexPath.row]
                self.registeredDevices.append(dvIndex)
                self.addedDevices.append(dvIndex)
                let index = self.removedDevices.firstIndex(of: dvIndex)
                if let index = index, index >= 0 {
                    self.removedDevices.remove(at: index)
                }
                self.unregisteredDevices.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        headerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                
        let label = UILabel()
        headerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.text = section == 0 ? "등록 디바이스" : "미등록 디바이스"
        label.font = UIFont(name: "NotoSansKR-Regular", size: 16)
        label.textColor = #colorLiteral(red: 0.3411764706, green: 0.2666666667, blue: 0.2156862745, alpha: 1)
        
        let line = UIView()
        headerView.addSubview(line)
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        line.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        line.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        line.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -0.5).isActive = true
        
        line.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9725490196, blue: 0.8784313725, alpha: 0.5)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return registeredDevices.count > 0
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.section != 0 {
            tableView.reloadData()
        } else {
            let movedObject = registeredDevices[sourceIndexPath.row]
            registeredDevices.remove(at: sourceIndexPath.row)
            registeredDevices.insert(movedObject, at: destinationIndexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for view in cell.subviews where view.description.contains("Reorder") {
            for case let subview as UIImageView in view.subviews {
                subview.image = UIImage(named: "ic_reorder")
                subview.contentMode = .scaleAspectFill
            }
        }
    }
}

extension GroupInfoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

class GroupInfoTVC: UITableViewCell {
    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
   
    var addOrRemoveToGroup: (() -> Void)? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        for view in subviews where view.description.contains("Reorder") {
            for case let subview as UIImageView in view.subviews {
                subview.image = UIImage(named: "ic_reorder")
                subview.contentMode = .scaleAspectFit
                
            }
        }
    }

    @IBAction func onBtnAddOrRemove(_ sender: Any) {
        addOrRemoveToGroup?()
    }
}
