//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editCircleDelegate {
    func editDream(editPrivate:String, editTitle:String, editDes:String, editImage:String, editTag:String)
}

class AddCircleController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, CircleTagDelegate, UITextViewDelegate {
    
    @IBOutlet var uploadButton: UIButton?
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextView!
    @IBOutlet var setButton: UIButton!
    @IBOutlet var labelTag: UILabel?
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var imageEyeClosed: UIImageView!
    @IBOutlet var imageDreamHead: UIImageView!
    @IBOutlet var imageTag: UIImageView!
    var actionSheet:UIActionSheet?
    var setDreamActionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var delegate:editDreamDelegate?
    var tagType:Int = 0
    var dreamType:Int = 0
    
    var uploadUrl:String = ""
    
    var isEdit:Int = 0
    var editId:String = ""
    var editTitle:String = ""
    var editContent:String = ""
    var editImage:String = ""
    var editPrivate:String = ""
    
    var isPrivate:Int = 0
    
    @IBAction func uploadClick(sender: AnyObject) {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            self.imagePicker = UIImagePickerController()
            self.imagePicker!.delegate = self
            self.imagePicker!.allowsEditing = true
            if buttonIndex == 0 {
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }else if buttonIndex == 1 {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        }else if actionSheet == self.setDreamActionSheet {
            if buttonIndex == 0 {
                self.isPrivate = 0
                self.editPrivate = "0"
                self.imageEyeClosed.hidden = true
                // 变为公开
            }else if buttonIndex == 1 {
                self.isPrivate = 1
                self.editPrivate = "1"
                self.imageEyeClosed.hidden = false
                // 变为私密
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.uploadWait!.startAnimating()
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadUrl = data.objectForKey("url") as String
            self.uploadUrl = SAReplace(self.uploadUrl, "/dream/", "") as String
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.setImage(url, placeHolder: UIColor(red:0.9, green:0.89, blue:0.89, alpha:1))
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
        })
        uy.uploadImage(resizedImage(img, 260), savekey: getSaveKey("dream", "png"))
    }
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        self.viewHolder.layer.borderColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1).CGColor
        self.viewHolder.layer.borderWidth = 1
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        if self.tagType >= 1 {
            self.labelTag?.text = V.Tags[self.tagType - 1]
        }
        
        if self.editPrivate == "1" {
            self.imageEyeClosed.hidden = false
        }else{
            self.imageEyeClosed.hidden = true
        }
        
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.field1!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field2.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        if self.isEdit == 1 {
            self.field1!.text = self.editTitle
            self.field2.text = self.editContent
            self.uploadUrl = self.editImage
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.setImage(url, placeHolder: UIColor(red:0.9, green:0.89, blue:0.89, alpha:1))
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }else{
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addCircleOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        self.uploadWait!.hidden = true
        
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        if self.isEdit == 1 {
            titleLabel.text = "编辑梦境"
        }else{
            titleLabel.text = "新梦境！"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        self.setButton.addTarget(self, action: "setDream", forControlEvents: UIControlEvents.TouchUpInside)
        self.labelTag!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
        self.imageTag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
        self.labelTag!.userInteractionEnabled = true
        self.imageTag.userInteractionEnabled = true
    }
    
    func onTagClick(){
        var storyboard = UIStoryboard(name: "CircleTag", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CircleTagViewController") as CircleTagViewController
        viewController.circleTagDelegate = self
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func setDream(){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.setDreamActionSheet!.addButtonWithTitle("任何人都可加入")
        self.setDreamActionSheet!.addButtonWithTitle("需要验证后加入")
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 2
        self.setDreamActionSheet!.showInView(self.view)
        
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
    }

    func addCircleOK(){
        var title = self.field1?.text
        var content = self.field2.text
        if content == "梦境简介（可选）" {
            content = ""
        }
        if title == "" {
            self.field1!.becomeFirstResponder()
            self.view.showTipText("你的梦境还没有名字...", delay: 2)
        }else if self.uploadUrl == "" {
            self.view.showTipText("你的梦境还没有封面...", delay: 2)
        }else if self.tagType == 0 {
            self.view.showTipText("你的梦境还没绑定梦想和标签...", delay: 2)
        }else{
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            Api.postCircleNew(title!, content: content, img: self.uploadUrl, privateType: self.isPrivate, tag: self.tagType, dream: self.dreamType) {
                json in
                if json != nil {
                    globalWillNianReload = 1
                    self.navigationController!.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)&&img=\(self.uploadUrl)&&private=\(self.editPrivate)&&id=\(self.editId)&&hashtag=\(self.tagType)", "http://nian.so/api/editdream.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController!.popViewControllerAnimated(true)
                        self.delegate?.editDream(self.editPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTag: "\(self.tagType)")
                    })
                }
            })
        }else{
            self.field1!.becomeFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "梦境简介（可选）" {
            textView.text = ""
        }
        textView.textColor = UIColor.blackColor()
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
    
    func onTagSelected(tag: String, tagType: Int, dreamType: Int) {
        self.labelTag?.text = tag
        self.tagType = tagType
        self.dreamType = dreamType
    }
}