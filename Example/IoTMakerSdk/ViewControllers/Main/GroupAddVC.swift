//
//  GroupInfoVC.swift
//  demoapp
//
//  Created by Coding on 07.03.21.
//

import UIKit
import IoTMakerSdk

class GroupAddVC: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var btnV: UIView!
    @IBOutlet weak var btnVBottom: NSLayoutConstraint!
    @IBOutlet weak var deviceTV: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var registeredDevices = [Int]()
    var unregisteredDevices = [Int]()

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
        
        btnV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let tapManager = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped))
        self.view.addGestureRecognizer(tapManager)

        updated = false
        
        deviceTV.delegate = self
        deviceTV.dataSource = self
        deviceTV.isEditing = true
        
        self.deviceTV.tableFooterView = UIView(frame: .zero)
        
        nameTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registeredDevices = []
        reloadData()
    }
    
    @objc func viewDidTapped() {
        self.view.endEditing(true)
    }
    
    func reloadData() {
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
    
    func addGroup(completion: @escaping(()->Void)) {
        let contentType = "application/json;charset=utf-8"
        let params = [
            "devGroupNm": nameTF.text!,
        ] as [String : Any]

        IoTMakerSdk.postAddGroup(token: Global.token, contentType: contentType, params: params) { (group, error) in
            if let error = error {
                MyAlertVC.show(message: error, isConfirm: false) {
                    MyLoadingVC.hide()
                }
            } else {
                group?.devices = []
                Global.groups.append(group!)
                completion()
            }
        }
    }
    
    func addDevice(index: Int, dvIndex: Int, completion: @escaping(()-> Void)) {
        let device = Global.devices[dvIndex]
        let group = Global.groups[Global.groups.count-1]
        
        let contentType = "application/json;charset=utf-8"
        
        let params = [
            "svcTgtId": device.target.id,
            "spotDevId": device.id
        ] as [String : Any]
        
        IoTMakerSdk.postAddGroupDevice(token: Global.token, contentType: contentType, targetId: device.target.id, devGroupId: group.devGroupId, params: params) { (response, error) in
            if let response = response {
                Global.devices[dvIndex].target.id = response["svcTgtId"] as? String ?? ""
                Global.devices[dvIndex].groupId = response["devGroupId"] as? String ?? ""
                Global.devices[dvIndex].groupNm = response["devGroupNm"] as? String ?? ""
                Global.groups[Global.groups.count-1].devices?.append(dvIndex)
                
            } else {
                print(error!)
//                MyAlertVC.show(message: error!, isConfirm: false) {
//                    MyLoadingVC.hide()
//                }
            }
            if index < self.registeredDevices.count-1 {
                self.addDevice(index: index+1, dvIndex: self.registeredDevices[index+1], completion: completion)
            } else {
                completion()
            }
        }
    }
    
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        updated = true
    }
    
    @IBAction func onBtnInputClear(_ sender: Any) {
        nameTF.text = ""
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 추가를\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 추가를\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnSave(_ sender: Any) {
        if nameTF.text!.count < 1 {
            MyAlertVC.show(message: "그룹 이름을 입력해주세요",isConfirm: false)
            return
        }
        
//        MyAlertVC.show(message: "그룹 추가를\n저장 하시겠습니까?", isConfirm: true, okTitle: "저장") {
            MyLoadingVC.show()
            self.addGroup() {
                if self.registeredDevices.count > 0 {
                    self.addDevice(index: 0, dvIndex: self.registeredDevices[0]) {
                        MyLoadingVC.hide()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    MyLoadingVC.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            }
//        }
    }
}

extension GroupAddVC: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupAddTVC", for: indexPath) as! GroupAddTVC
        if indexPath.section == 0 {
            if registeredDevices.count < 1 {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyTVC")
                return emptyCell!
            } else {
                cell.controlBtn.setImage(UIImage(named: "ic-minus"), for: .normal)
                cell.nameLbl.text = Global.devices[registeredDevices[indexPath.row]].name
                
                cell.addOrRemoveToGroup = { () in
                    self.updated = true
                    self.unregisteredDevices.append(self.registeredDevices[indexPath.row])
                    self.registeredDevices.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
        } else {
            cell.controlBtn.setImage(UIImage(named: "ic-plus"), for: .normal)
            cell.nameLbl.text = Global.devices[unregisteredDevices[indexPath.row]].name
            
            cell.addOrRemoveToGroup = { () in
                self.updated = true
                self.registeredDevices.append(self.unregisteredDevices[indexPath.row])
                self.unregisteredDevices.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                
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

extension GroupAddVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

class GroupAddTVC: UITableViewCell {
    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
   
    var addOrRemoveToGroup: (() -> Void)? = nil

    @IBAction func onBtnAddOrRemove(_ sender: Any) {
        addOrRemoveToGroup?()
    }
}
