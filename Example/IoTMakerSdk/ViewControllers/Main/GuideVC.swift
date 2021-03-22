//
//  GuideVC.swift
//  demoapp
//
//  Created by Coding on 08.03.21.
//

import UIKit

class GuideVC: UIViewController {
    @IBOutlet weak var guideCV: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let imgList = [
        "guide_1", "guide_2", "guide_3", "guide_4", "guide_5", "guide_6"
    ]
    let descList = [
        "등록된 디바이스 목록을\n조회할 수 있습니다.",
        "그룹별 설정된 디바이스를\n조회할 수 있습니다.",
        "전체 디바이스의 이벤트 로그를\n조회할 수 있습니다.",
        "디바이스의 수집/제어 정보를\n조회할 수 있습니다.",
        "디바이스를 제어할 수 있습니다.",
        "수집된 디바이스 로그 정보를\n리스트와 차트 이용하여\n조회할 수 있습니다."
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guideCV.delegate = self
        guideCV.dataSource = self
        
        pageControl.numberOfPages = imgList.count
        pageControl.currentPage = 0
    }
    
    @IBAction func pageControlSelected(_ sender: UIPageControl) {
        let currPage = sender.currentPage
        guideCV.scrollToItem(at: IndexPath(row: currPage, section: 0), at: .left, animated: true)
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GuideVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCVC", for: indexPath) as! GuideCVC
        cell.guideIV.image = UIImage(named: imgList[indexPath.row])
        cell.descLbl.text = descList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        self.pageControl.currentPage = Int(page)
    }
}

class GuideCVC: UICollectionViewCell {
    @IBOutlet weak var guideIV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
}
