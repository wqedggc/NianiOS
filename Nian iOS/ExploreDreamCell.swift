//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class ExploreDreamCell: UITableViewCell {
    
    @IBOutlet var head1: UIImageView!
    @IBOutlet var head2: UIImageView!
    @IBOutlet var head3: UIImageView!
    @IBOutlet var title1: UILabel!
    @IBOutlet var title2: UILabel!
    @IBOutlet var title3: UILabel!
    @IBOutlet var View: UIView!
    var data1 :NSDictionary!
    var data2 :NSDictionary!
    var data3 :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var id1 = self.data1.stringAttributeForKey("id")
        var id2 = self.data2.stringAttributeForKey("id")
        var id3 = self.data3.stringAttributeForKey("id")
        var img1 = self.data1.stringAttributeForKey("img")
        var img2 = self.data2.stringAttributeForKey("img")
        var img3 = self.data3.stringAttributeForKey("img")
        var title1 = self.data1.stringAttributeForKey("title")
        var title2 = self.data2.stringAttributeForKey("title")
        var title3 = self.data3.stringAttributeForKey("title")
        
        self.title1!.textColor = BlueColor
        self.title2!.textColor = BlueColor
        self.title3!.textColor = BlueColor
        self.title1!.text = title1
        self.title2!.text = title2
        self.title3!.text = title3
        
        var imgholder = SAColorImg(IconColor)
        self.head1!.setImage("http://img.nian.so/dream/\(img1)!dream",placeHolder: imgholder)
        self.head2!.setImage("http://img.nian.so/dream/\(img2)!dream",placeHolder: imgholder)
        self.head3!.setImage("http://img.nian.so/dream/\(img3)!dream",placeHolder: imgholder)
        
        
        self.head1!.layer.cornerRadius = 40;
        self.head2!.layer.cornerRadius = 40;
        self.head3!.layer.cornerRadius = 40;
        
        self.head1!.layer.masksToBounds = true;
        self.head2!.layer.masksToBounds = true;
        self.head3!.layer.masksToBounds = true;
        
        self.View.backgroundColor = BGColor
        
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var height = content.stringHeightWith(17,width:225)
        return 130
    }
    
}