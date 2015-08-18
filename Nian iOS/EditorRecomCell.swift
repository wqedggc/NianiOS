//
//  EditorRecomCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class EditorRecomCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sepLine: UIView!
    
    var data: NSMutableArray?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.sepLine.setHeightHalf()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        _layoutSubview()
        
    }

    func _layoutSubview() {
        
        
        
        if data?.count > 0 {
            self.collectionView.reloadData()
        }
        
    }
    
    @IBAction func onEditorMore(sender: UIButton) {
        
    }

}

extension EditorRecomCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _count = self.data?.count {
            return _count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionViewCell
        var _tmpData = self.data?.objectAtIndex(indexPath.row) as! NSDictionary
        
        if let _img = _tmpData.objectForKey("image") as? String {
            collectionCell.imageView?.setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
        }
        
        collectionCell.label?.text = _tmpData.objectForKey("title") as? String
        
        return collectionCell
    }
    
    
}

