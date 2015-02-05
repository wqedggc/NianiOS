//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class MeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var wordLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelConfirm: UILabel!
    @IBOutlet var activity: UIActivityIndicatorView!
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.View!.backgroundColor = BGColor
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("cuid")
        var user = self.data.stringAttributeForKey("cname")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var dreamtitle = self.data.stringAttributeForKey("dreamtitle")
        var content = self.data.stringAttributeForKey("content")
        var type = self.data.stringAttributeForKey("type")
        var isread = self.data.stringAttributeForKey("isread") as String
        var img = self.data.stringAttributeForKey("img") as String
        var dream = self.data.stringAttributeForKey("dream") as String
        var isConfirm = self.data.stringAttributeForKey("isConfirm") as String
        var word:String = ""
        
        switch type {
        case "0": word = "在「\(dreamtitle)」留言"
        case "1": word = "在「\(dreamtitle)」提到你"
        case "2": word = "赞了你的梦想「\(dreamtitle)」"
            content = "「\(dreamtitle)」"
        case "3": word = "关注了你"
            content = "去看看对方"
        case "4": word = "参与你的话题「\(dreamtitle)」"
        case "5": word = "在「\(dreamtitle)」提到你"
        case "6": word = "为你的梦想「\(dreamtitle)」更新了"
        case "7": word = "添加你为「\(dreamtitle)」的伙伴"
            content = "「\(dreamtitle)」"
        case "8": word = "赞了你的进展"
            content = dreamtitle
        case "9": word = "申请加入梦境「\(dreamtitle)」"
        case "10": word = "邀请你加入梦境"
        content = "「\(dreamtitle)」"
        default: word = "与你互动了"
        }
        
        self.activity.hidden = true
        self.nickLabel!.text = user
        self.wordLabel!.text = word
        self.lastdate!.text = lastdate
        if isread == "1" {
            self.nickLabel!.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }else{
            self.nickLabel!.textColor = SeaColor
        }
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!dream"
        self.avatarView!.setImage(userImageURL,placeHolder: IconColor)
        self.avatarView!.tag = uid.toInt()!
        var height = content.stringHeightWith(14,width:290)
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        if type == "9" {
            self.labelConfirm.setY(self.contentLabel!.bottom()+15)
            self.imageDream.hidden = false
            self.labelConfirm.hidden = false
            self.imageDream.tag = dream.toInt()!
            self.imageDream.setImage("http://img.niain.so/dream/\(img)!dream", placeHolder: IconColor)
            self.lastdate!.hidden = true
            self.viewLine.setY(self.labelConfirm!.bottom()+15)
            var tap = UITapGestureRecognizer(target: self, action: "onConfirmClick:")
            if isConfirm == "0" {
                self.labelConfirm.text = "接受"
                self.labelConfirm.backgroundColor = SeaColor
                self.labelConfirm.addGestureRecognizer(tap)
            }else{
                self.labelConfirm.text = "已接受"
                self.labelConfirm.backgroundColor = IconColor
                self.labelConfirm.removeGestureRecognizer(tap)
            }
        }else{
            self.imageDream.hidden = true
            self.labelConfirm.hidden = true
            self.lastdate!.hidden = false
            self.viewLine.setY(self.contentLabel!.bottom()+15)
        }
    }
    
    func onConfirmClick(sender:UIGestureRecognizer) {
        var view = sender.view! as UILabel
        view.text = ""
        self.activity.frame = CGRectMake(0, 0, 20, 20)
        self.activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self.activity.center = view.center
        self.activity.hidden = false
        self.activity.startAnimating()
        var id = self.data.stringAttributeForKey("id") as String
        Api.getCircleJoinConfirmOK(id) { json in
            if json != nil {
                var success = json!["success"] as String
                var reason = json!["reason"] as String
                var circle = json!["circle"] as String
                var cid = json!["cid"] as String
                if success == "1" {
                    self.activity.hidden = true
                    view.text = "已接受"
                    view.backgroundColor = IconColor
                    view.removeGestureRecognizer(sender)
                    on_gay(["\(circle)", "", "5", cid])
                }else{
                    self.activity.hidden = true
                    view.text = "接受"
                    if reason == "1" {
                        self.View?.showTipText("遇到了一个奇怪的错误...", delay: 2)
                    }else if reason == "2" {
                        self.View?.showTipText("你的权限不够...", delay: 2)
                    }else if reason == "3" {
                        self.View?.showTipText("梦境的人满了！", delay: 2)
                    }else{
                        self.View?.showTipText("遇到了一个奇怪的错误...", delay: 2)
                    }
                }
            }
        }
    }
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var dreamtitle = data.stringAttributeForKey("dreamtitle")
        var content = data.stringAttributeForKey("content")
        var type = data.stringAttributeForKey("type")
        if type == "8" {
            content = dreamtitle
        }
        var height = content.stringHeightWith(14,width:290)
        if type == "9" {
            return 151 + height
        }else{
            return 100 + height
        }
    }
    
}
