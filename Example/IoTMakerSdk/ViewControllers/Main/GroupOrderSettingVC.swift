//
//  GroupOrderSettingVC.swift
//  demoapp
//
//  Created by Coding on 07.03.21.
//

import UIKit
import IoTMakerSdk

class GroupOrderSettingVC: UIViewController {
    @IBOutlet weak var groupTV: UITableView!
    @IBOutlet weak var btnV: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var baseOrders = [Int]()
    var procGroups = [GroupModel]()
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

        getBaseOrders()

        groupTV.delegate = self
        groupTV.dataSource = self
        groupTV.isEditing = true
        
        updated = false

        btnV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func getBaseOrders() {
        procGroups = Global.groups
        baseOrders = []
        for i in 0 ..< procGroups.count {
            baseOrders.append(procGroups[i].groupIndcOdrg)
        }
    }
    
    func setGroupOrder(index: Int, completion: @escaping(()->Void)) {
        if baseOrders[index] == procGroups[index].groupIndcOdrg {
            if index < baseOrders.count-1 {
                setGroupOrder(index: index+1, completion: completion)
            } else {
                completion()
            }
        } else {
            let group = procGroups[index]
            let contentType = "application/json;charset=utf-8"
            let params = [
                "devGroupNm": group.devGroupNm,
                "groupIndcOdrg": baseOrders[index]
            ] as [String : Any]
            
            IoTMakerSdk.postGroupModify(token: Global.token, contentType: contentType, devGroupId: procGroups[index].devGroupId, params: params) { (response, error) in
                if let response = response {
                    Global.groups[index].groupIndcOdrg = self.baseOrders[index]
                    if index < self.baseOrders.count-1 {
                        self.setGroupOrder(index: index+1, completion: completion)
                    } else {
                        completion()
                    }
                } else {
                    MyAlertVC.show(message: error ?? "Server error", isConfirm: false) {
                        MyLoadingVC.hide()
                    }
                }
            }
        }
    }
    
    @IBAction func onBtnSave(_ sender: Any) {
        Global.groups = procGroups
        if baseOrders.count > 0 {
            MyLoadingVC.show()
            setGroupOrder(index: 0) {
                MyLoadingVC.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 순서 변경을\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "그룹 순서 변경을\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension GroupOrderSettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return procGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupOrderTVC", for: indexPath) as! GroupOrderTVC
        cell.nameLbl.text = procGroups[indexPath.row].devGroupNm
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        updated = true
        let movedObject = procGroups[sourceIndexPath.row]
        procGroups.remove(at: sourceIndexPath.row)
        procGroups.insert(movedObject, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
}

class GroupOrderTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
}
