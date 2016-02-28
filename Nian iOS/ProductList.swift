//
//  ProductList.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ProductList: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let padding: CGFloat = 16
    var dataArray = NSMutableArray()
    var name = ""
    
    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        _setTitle(name)
        if name == "表情" {
            dataArray = [
                ["title": "幽灵", "image": "banner_ghost", "color": "#86ccf0", "price": "100"],
                ["title": "小白", "image": "banner_cat", "color": "#414141", "price": "100"]
            ]
        } else {
            dataArray = [
                ["title": "请假", "image": "banner_ghost", "color": "#86ccf0", "price": "2"],
                ["title": "推广", "image": "banner_cat", "color": "#414141", "price": "20"],
                ["title": "毕业证", "image": "banner_cat", "color": "#414141", "price": "100"]
            ]
        }
        
        
        let w = (globalWidth - padding * 3) / 2
        let h = w / 3 * 4 + 48
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = padding
        flowLayout.minimumLineSpacing = padding
        flowLayout.itemSize = CGSize(width: w, height: h)
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "ProductListCell", bundle: nil), forCellWithReuseIdentifier: "ProductListCell")
        self.view.addSubview(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: ProductListCell! = collectionView.dequeueReusableCellWithReuseIdentifier("ProductListCell", forIndexPath: indexPath) as? ProductListCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = Product()
        let data = dataArray[indexPath.row] as! NSDictionary
        vc.name = data.stringAttributeForKey("title")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}