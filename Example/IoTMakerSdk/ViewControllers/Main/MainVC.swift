//
//  MainVC.swift
//  demoapp
//
//  Created by Coding on 04.03.21.
//

import UIKit
import IoTMakerSdk
import SDWebImage

class MainVC: UIViewController {
    @IBOutlet weak var tabHomeIV: UIImageView!
    @IBOutlet weak var tabGroupIV: UIImageView!
    @IBOutlet weak var tabProfileIV: UIImageView!
    
    // for Home
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var deviceCV: UICollectionView!
    @IBOutlet weak var emptyDeviceLbl: UILabel!
    @IBOutlet weak var listTypeCBtn: UIButton!
    @IBOutlet weak var listTypeLBtn: UIButton!
    @IBOutlet weak var deviceCollectionH: NSLayoutConstraint!
    
    // for Group
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet weak var groupContainerV: UIView!
    
    // for Profile
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var profileV: UIView!
    @IBOutlet weak var profileTopInsetV: UIView!
    
    var refreshControl = UIRefreshControl()
    var tabBtns = [UIImageView]()
    var loadingByPull = false
    var firstLoaded = false
    
    var deviceCollectionType = 0
    var groupCollectionType = 0
    var collectionType = 0 {   // 0 => collection, 1 => list
        didSet {
            if collectionType == 0 {
                listTypeCBtn.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                listTypeLBtn.tintColor = #colorLiteral(red: 0.1294117647, green: 0.1215686275, blue: 0.1176470588, alpha: 1)
            } else {
                listTypeCBtn.tintColor = #colorLiteral(red: 0.1294117647, green: 0.1215686275, blue: 0.1176470588, alpha: 1)
                listTypeLBtn.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            
            deviceCV.reloadData()
        }
    }
    
    var selectedTab = 0 {
        didSet {
            initTabBtns()
            tabBtns[selectedTab].tintColor = #colorLiteral(red: 0.8823529412, green: 0.2588235294, blue: 0.368627451, alpha: 1)
            
            checkEmptyDevice()

            deviceCV.reloadData()
        }
    }
    
    var selectedGroup = -1 {
        didSet {
            if selectedGroup >= 0 {
                let group = Global.groups[selectedGroup]
                if group.devices != nil {
                    deviceCV.reloadData()
                } else {
                    MyLoadingVC.show()
                    Global.loadData {
                        MyLoadingVC.hide()
                        self.deviceCV.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileV.alpha = 1
        profileV.isHidden = true
        emptyDeviceLbl.isHidden = true
        
        nameLbl.text = Global.member.name
        profileNameLbl.text = Global.member.name

        tabBtns = [tabHomeIV, tabGroupIV, tabProfileIV]
        
        initHomeView()
        initGroupView()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadByPull), for: .valueChanged)
        deviceCV.addSubview(refreshControl)
        deviceCV.alwaysBounceVertical = true
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedTab != 2 {
            reloadData()
        }
//        refreshUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.groupCV.collectionViewLayout.invalidateLayout()
    }
    
    func initTabBtns() {
        for tab in tabBtns {
            tab.tintColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        }
    }
    
    @objc func reloadByPull() {
        loadingByPull = true
        reloadData()
    }
    
    @objc func reloadData() {
        if !loadingByPull {
            MyLoadingVC.show()
        }
        loadingByPull = false
        
        Global.loadData {
            if Global.devices.count > 0 {
                Global.loadDeviceImage(index: 0) {
                    Global.loadDeviceStatus(index: 0) {
                        MyLoadingVC.hide()
                        if !self.firstLoaded {
                            self.selectedTab = 0
                        }
                        
                        self.checkEmptyDevice()
                        self.refreshUI()
                        self.firstLoaded = true
                        self.refreshControl.endRefreshing()
                    }
                }
            } else {
                MyLoadingVC.hide()
                self.selectedTab = 0
                self.refreshUI()
            }
        }
    }
    
    func refreshUI() {
        if selectedGroup < 1 && Global.groups.count > 0 {
            deviceCV.isHidden = false
            emptyDeviceLbl.isHidden = true
            selectedGroup = 0
        }
        
        if Global.groups.count > 0 && selectedGroup > Global.groups.count - 1 {
            selectedGroup = 0
        }
        
        groupCV.reloadData()
        deviceCV.reloadData()
    }
    
    func checkEmptyDevice() {
        var cnt = 1
        if selectedTab == 2 {
            profileV.isHidden = false
            profileTopInsetV.isHidden = false
            return
        }
        else if selectedTab == 0 {
            groupContainerV.isHidden = true
            cnt = Global.devices.count
            if cnt < 1 {
                emptyDeviceLbl.text = "등록된 디바이스가 없습니다"
            } else {
                deviceCV.isHidden = false
                emptyDeviceLbl.isHidden = true
            }
            collectionType = deviceCollectionType
        } else if selectedTab == 1 {
            groupContainerV.isHidden = false
            if Global.groups.count < 1 {
                cnt = 0
                emptyDeviceLbl.text = "등록된 디바이스가 없습니다"
            } else if selectedGroup >= 0 {
                if Global.groups[selectedGroup].devices?.count ?? 0 < 1 {
                    cnt = 0
                    emptyDeviceLbl.text = "디바이스를 등록해주세요"
                }
            }
            collectionType = groupCollectionType
        }
        
        profileV.isHidden = true
        profileTopInsetV.isHidden = true
        if cnt < 1 {
            deviceCV.isHidden = true
            emptyDeviceLbl.isHidden = false
        } else {
            deviceCV.isHidden = false
            emptyDeviceLbl.isHidden = true
        }
    }
    
    @IBAction func onBtnEventLog(_ sender: Any) {
        if Global.devices.count < 1 {
            MyAlertVC.show(message: "등록된 디바이스가 없습니다.", isConfirm: false)
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventLogVC") as! EventLogVC
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBtnTab(_ sender: UIButton) {
        selectedTab = sender.tag
    }
    
    @IBAction func onBtnDeviceListType(_ sender: UIButton) {
        if selectedTab == 0 {
            deviceCollectionType = sender.tag
        } else {
            groupCollectionType = sender.tag
        }
        collectionType = sender.tag
    }
}


extension MainVC {  // for main tab
    func initHomeView() {
        deviceCV.delegate = self
        deviceCV.dataSource = self
        
        deviceCollectionType = 0
        groupCollectionType = 0
        collectionType = deviceCollectionType
    }
    
}

extension MainVC {  // for group tab
    func initGroupView() {
        groupCV.delegate = self
        groupCV.dataSource = self
        
        if Global.groups.count > 0 {
            selectedGroup = 0
        }
    }
    
    @IBAction func onBtnGroupManager(_ sender: Any) {
        MyPickerVC.show(items: ["그룹관리"]) { (index) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupManageVC") as! GroupManageVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainVC {  // for profile tab
    @IBAction func onBtnGuide(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideVC") as! GuideVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBtnTerms(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndServiceVC") as! TermsAndServiceVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBtnLogout(_ sender: Any) {
        Global.token = ""
        Global.member = MemberModel()
        Global.devices = []
        Global.groups = []
        Global.username = ""
        
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var cnt = 0
        if collectionView == deviceCV {
            if selectedTab == 0 {
                cnt = Global.devices.count
            } else {
                if selectedGroup >= 0 {
                    if let devices = Global.groups[selectedGroup].devices {
                        cnt = devices.count
                    } else {
                        cnt = 0
                    }
                }
            }
        } else if collectionView == groupCV {
            cnt = Global.groups.count
        }
        
        return cnt
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == deviceCV {
            let id = selectedTab == 0 ? indexPath.row : Global.groups[selectedGroup].devices![indexPath.row]
            let device = Global.devices[id]
            if collectionType == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCVC", for: indexPath) as! DeviceCVC
                
                cell.nameLbl.text = device.name
                cell.stateLbl.text = device.isConnected ? "ON" : "OFF"
                if let resId = device.resIndex {
                    cell.iconIV.image = UIImage(named: Global.ICON_LIST[resId])
                } else if let icon = device.icon {
                    cell.iconIV.image = icon
                } else {
                    cell.iconIV.image = UIImage(named: "ic_device_default")
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceListCVC", for: indexPath) as! DeviceListCVC
                cell.nameLbl.text = device.name
                cell.stateLbl.text = device.isConnected ? "ON" : "OFF"
                if let resId = device.resIndex {
                    cell.iconIV.image = UIImage(named: Global.ICON_LIST[resId])
                } else if let icon = device.icon {
                    cell.iconIV.image = icon
                } else {
                    cell.iconIV.image = UIImage(named: "ic_device_default")
                }

                return cell
            }
        } else {
            let group = Global.groups[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCVC", for: indexPath) as! GroupCVC
            cell.nameLbl.text = group.devGroupNm
            cell.nameLbl.textColor = indexPath.row == selectedGroup ? #colorLiteral(red: 0.8823529412, green: 0.2588235294, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            cell.containerV.backgroundColor = indexPath.row == selectedGroup ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == groupCV {
            selectedGroup = indexPath.row
            let cnt = Global.groups[selectedGroup].devices?.count ?? 0
            if cnt < 1 {
                deviceCV.isHidden = true
                emptyDeviceLbl.isHidden = false
                emptyDeviceLbl.text = "디바이스를 등록해주세요"
            } else {
                deviceCV.isHidden = false
                emptyDeviceLbl.isHidden = true
            }
            
            groupCV.reloadData()
            deviceCV.reloadData()
        } else if collectionView == deviceCV {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceVC") as! DeviceVC
            if selectedTab == 0 {
                vc.selectedDevice = indexPath.row
            } else {
                vc.selectedDevice = Global.groups[selectedGroup].devices![indexPath.row]
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == deviceCV {
//            if deviceCollectionType == 0 {
                let w = collectionView.frame.width/3
                deviceCollectionH.constant = w*2
                self.view.layoutIfNeeded()
            if collectionType == 0 {
                return CGSize(width: w, height: w)
            } else {
                return CGSize(width: collectionView.frame.width, height: w)
            }
//            } else {
//                let w = collectionView.frame.width
//                deviceCollectionH.constant = 306
//                self.view.layoutIfNeeded()
//                return CGSize(width: w, height: 102)
//            }
        } else {
            return CGSize(width: 136, height: 60)
        }
    }
}

class DeviceCVC: UICollectionViewCell {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
}

class DeviceListCVC: UICollectionViewCell {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
}

class GroupCVC: UICollectionViewCell {
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var nameLbl: UILabel!
}
