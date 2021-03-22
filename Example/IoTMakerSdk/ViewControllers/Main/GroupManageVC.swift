//
//  GroupManageVC.swift
//  demoapp
//
//  Created by Coding on 06.03.21.
//

import UIKit

class GroupManageVC: UIViewController {
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var emptyV: UIView!
    @IBOutlet weak var groupTV: UITableView!
    
//    var groups: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let border = CAShapeLayer()
        border.strokeColor = #colorLiteral(red: 0.3411764706, green: 0.2666666667, blue: 0.2156862745, alpha: 1)
        border.lineDashPattern = [2,2]
        border.frame = addBtn.bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: addBtn.bounds, cornerRadius: 20).cgPath
        
        addBtn.layer.addSublayer(border)
        
        groupTV.delegate = self
        groupTV.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTV.reloadData()
    }
    
    @IBAction func onBtnAdd(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupAddVC") as! GroupAddVC

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnTool(_ sender: Any) {
        MyPickerVC.show(items: ["그룹 추가", "그룹 순서 변경"]) { (index) in
            if index == 0 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupAddVC") as! GroupAddVC

                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupOrderSettingVC") as! GroupOrderSettingVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension GroupManageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = Global.groups.count
        if cnt < 1 {
            groupTV.isHidden = true
            emptyV.isHidden = false
        } else {
            groupTV.isHidden = false
            emptyV.isHidden = true
        }
        return cnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTVC", for: indexPath) as! GroupTVC
        cell.nameLbl.text = Global.groups[indexPath.row].devGroupNm
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupInfoVC") as! GroupInfoVC
        vc.selectedGroup = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class GroupTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    
}
