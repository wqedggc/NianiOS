//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class PlayerCellTop: UIView, UIGestureRecognizerDelegate{
    
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var BGImage:UIImageView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var UserFo: UILabel!
    @IBOutlet var UserFoed: UILabel!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var labelMenuLeft: UILabel!
    @IBOutlet var labelMenuRight: UILabel!
    @IBOutlet var labelMenuSlider: UIView!
    @IBOutlet var viewBlack: UIView!
    @IBOutlet var viewBanner: UIView!
    @IBOutlet var imageBadge: SABadgeView!
    @IBOutlet var viewHolderHead: UIView!
    @IBOutlet var imageSex: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.BGImage.clipsToBounds = true
        self.viewHolder.frame.size = CGSize(width: globalWidth, height: globalHeight + 44)
        self.viewBanner.setY(320)
        self.viewBanner.setWidth(globalWidth)
        self.viewMenu.frame.origin = CGPoint(x: globalWidth/2 - 160, y: 0)
        self.BGImage.frame.size = CGSize(width: globalWidth, height: 320)
        self.viewHolderHead.setX(globalWidth/2-32)
        self.viewBlack.frame.size = CGSize(width: globalWidth, height: 320)
        self.btnMain.setX(globalWidth/2 - 105)
//        self.btnLetter.setX(globalWidth/2 + 5)
        self.UserFo.setX(globalWidth/2 - 53)
        self.UserFoed.setX(globalWidth/2 + 1)
        self.imageBadge.setX(globalWidth/2 + 60/2 - 14)
        self.labelMenuSlider.backgroundColor = UIColor.HighlightColor()
        self.imageSex.isHidden = true
        self.layer.masksToBounds = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let viewHit = super.hitTest(point, with: event)
        if let v = viewHit?.classForCoder {
            let cls = NSStringFromClass(v)
            if cls == "UIView" {
                return nil
            }
        }
        return viewHit
    }
}
