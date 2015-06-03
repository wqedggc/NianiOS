//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editDreamDelegate {
    func editDream(editPrivate:String, editTitle:String, editDes:String, editImage:String, editTag:String, editTags: Array<String>)
}

class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DreamTagDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var uploadWait: UIActivityIndicatorView?
    @IBOutlet weak var field1: UITextField!  //title text field
    @IBOutlet weak var field2: UITextView!
    @IBOutlet weak var tokenView: TITokenFieldView!
    @IBOutlet weak var setPrivate: UIImageView!
    @IBOutlet weak var imageDreamHead: UIImageView!
    @IBOutlet weak var seperatorView: UIView!
    
    var actionSheet: UIActionSheet?
    var setDreamActionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editDreamDelegate?
    var tagType: Int = 0
    var readyForTag: Int = 0     //当为1时自动跳转到Tag去
    
    var uploadUrl: String = ""
    
    var isEdit: Int = 0
    var editId: String = ""
    var editTitle: String = ""
    var editContent: String = ""
    var editImage: String = ""
    var editPrivate: String = ""
    var tagsArray: Array<String> = [String]()
    
    var caretPosition: CGFloat = 0.0   // 获得 caret(光标)的位置
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    var keyboardShown: Bool = false
    
    var isPrivate: Int = 0  // 0: 公开；1：私密
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    func uploadClick() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
        
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        
        self.actionSheet!.cancelButtonIndex = 2
        
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        } else if actionSheet == self.setDreamActionSheet {
            if buttonIndex == 0 {
                if self.isPrivate == 0 {
                    //设置为私密
                    self.isPrivate = 1
                    self.editPrivate = "0"
                    self.setPrivate.image = UIImage(named: "lock")
                } else if self.isPrivate == 1 {
                    //设置为公开
                    self.isPrivate = 0
                    self.editPrivate = "1"
                    self.setPrivate.image = UIImage(named: "unlock")
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.imageDreamHead.image = UIImage(named: "add_no_plus")
        self.uploadWait!.startAnimating()
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadUrl = data.objectForKey("url") as! String
            self.uploadUrl = SAReplace(self.uploadUrl, "/dream/", "") as String
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.image = img
            setCacheImage(url, img, 150)
            self.uploadWait!.stopAnimating()
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
        })
        uy.uploadImage(resizedImage(img, 260), savekey: getSaveKey("dream", "png") as String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        setupViews()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UITextViewTextDidChangeNotification, object: self.field2)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillChangeFrameNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleTextviewDidChangeNotification:", name: UITextViewTextDidChangeNotification, object: self.field2)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        var height = 76 + field2.frame.size.height + tokenView.tokenField.frame.size.height
        var tmpSize: CGSize = CGSizeMake(self.containerView.frame.size.width, max(height, UIScreen.mainScreen().bounds.size.height - 64))
        self.scrollView.contentSize = tmpSize
        
        self.view.layoutIfNeeded()
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.isEdit == 1 ? "编辑记本" : "新记本！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        self.view.addSubview(navView)
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard:")
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.Down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)

        self.setPrivate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "setDream"))
//        self.imageTag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick"))
        self.imageDreamHead.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.imageDreamHead.layer.borderWidth = 0.5
        self.imageDreamHead.layer.cornerRadius = 4.0
        self.imageDreamHead.layer.masksToBounds = true
        
        self.scrollView.setWidth(globalWidth)
        self.scrollView.setHeight(globalHeight - 64)
        self.containerView.setWidth(globalWidth)
        self.containerView.setHeight(self.scrollView.frame.height - 1)
        self.field1.setWidth(globalWidth - 124)
        self.setPrivate.setX(globalWidth - 44)
        self.field2.setWidth(globalWidth)
        UIScreen.mainScreen().bounds.height > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tokenView.setY(CGRectGetMaxY(self.field2.frame))
        self.tokenView.setWidth(globalWidth)
        self.seperatorView.setWidth(globalWidth)
        
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.view.backgroundColor = UIColor.whiteColor()
        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0x99/255.0, green: 0x99/255.0, blue: 0x99/255.0, alpha: 1)])
        
        self.field2.placeholder = "记本简介（可选）"
        self.field2.delegate = self
        
        self.scrollView.delegate = self
        
        delay(0.5, { () -> () in
            if self.readyForTag == 1 {
                self.onTagClick()
                return
            }
        })
        
        if UIScreen.mainScreen().bounds.height > 480 {
            self.field2.frame.size.height = 120
        } else {
            self.field2.frame.size.height = 96
        }
        
        //设置 tag view ---- 引用了第三方库
        tokenView.delegate = self
        tokenView.tokenField.delegate = self
        tokenView.shouldSearchInBackground = false
        tokenView.tokenField.tokenizingCharacters = NSCharacterSet(charactersInString: "#")
        tokenView.tokenField.setPromptText("     ")
        tokenView.tokenField.tokenLimit = 20;
        tokenView.tokenField.placeholder = "按空格输入多个标签"
        tokenView.canCancelContentTouches = false
        tokenView.delaysContentTouches = false
        tokenView.scrollEnabled = false

        if self.isEdit == 1 {
            self.field1!.text = SADecode(self.editTitle)
            self.field2.text = SADecode(self.editContent)
            
            if count(tagsArray) > 0 {
                for i in 0...(count(tagsArray) - 1) {
                    if count(tagsArray) == 1 && tagsArray[0] == "" {
                    } else {
                        tokenView.tokenField.addTokenWithTitle(tagsArray[i])
                        tokenView.tokenField.layoutTokensAnimated(false)
                    }
                }
            }
            
            self.uploadUrl = self.editImage
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.setImage(url, placeHolder: UIColor(red:0.9, green:0.89, blue:0.89, alpha:1))
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        } else {
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        self.uploadWait!.hidden = true

    }
    
    func onTagClick(){
        var storyboard = UIStoryboard(name: "DreamTagViewController", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("DreamTagViewController") as! DreamTagViewController
        viewController.dreamTagDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setDream(){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if self.isPrivate == 0 {
            self.setDreamActionSheet!.addButtonWithTitle("设为私密")
        } else if self.isPrivate == 1 {
            self.setDreamActionSheet!.addButtonWithTitle("设为公开")
        }
        
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 1
        self.setDreamActionSheet!.showInView(self.view)
    }
    
    func dismissKeyboard(sender: UISwipeGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.tokenField.resignFirstResponder()
        
//        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func addDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokenTitles
        var tagsString = ""

        if count(tags!) > 0 {
            for i in 0...(count(tags!) - 1){
                var tmpString = tags![i] as! String
                tmpString.removeAtIndex(advance(tmpString.startIndex, 0))
                
                if i == (count(tags!) - 1) {
                    tagsString = tagsString + "tags[]=\(SAEncode(SAHtml(tmpString)))"
                } else {
                    tagsString = tagsString + "tags[]=\(SAEncode(SAHtml(tmpString)))&&"
                }
            }
        }

        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: self.isPrivate, tagType: self.tagType, tags: tagsString) {
                    result in
                    if result == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            globalWillNianReload = 1
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                }
            })
        }else{
            self.field1!.becomeFirstResponder()
        }

    }
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokenTitles
        var tagsString: String = ""
        var tagsArray: Array<String> = [String]()
        
        if count(tags!) > 0 {
            for i in 0...(count(tags!) - 1){
                var tmpString = tags[i] as! String
                tmpString.removeAtIndex(advance(tmpString.startIndex, 0))
                tagsArray.append(tmpString)
                
                if i == (count(tags!) - 1) {
                    tagsString = tagsString + "tags[]=\(SAEncode(SAHtml(tmpString)))"
                } else {
                    tagsString = tagsString + "tags[]=\(SAEncode(SAHtml(tmpString)))&&"
                }
            }
        }
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postEditDream(self.editId, title: title!, content: content!, uploadUrl: self.uploadUrl, editPrivate: self.isPrivate, tagType: self.tagType, tags:tagsString){
                    result in
                    if result == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            globalWillNianReload = 1
                            self.navigationController?.popViewControllerAnimated(true)
                            self.delegate?.editDream(self.editPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTag: "\(self.tagType)", editTags:tagsArray)
                        })
                    }
                }
            })
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
    }
    
    // MARK: DreamTagDelegate
    
    func onTagSelected(tag: String, tagType: Int) {
//        self.labelTag?.text = tag
//        self.tagType = tagType + 1
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.height   // abs(keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y)
        keyboardHeight = originDelta
        
        println("kbd begin frame = \(keyboardViewBeginFrame), kbd end frame = \(keyboardViewEndFrame), originDelta = \(originDelta)")
        
        if self.tokenView.tokenField.isFirstResponder() {
            tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: UIScreen.mainScreen().bounds.height - keyboardHeight - 64)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 76 + field2.frame.height + tokenView.frame.height)
            self.containerView.setHeight(self.scrollView.contentSize.height - 1)
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                if self.scrollView.contentOffset.y != floor(self.field2.frame.height + 76) {
                    self.scrollView.setContentOffset(CGPointMake(0, floor(self.field2.frame.height + 76)), animated: false)
                }
                }, completion: nil)
        }
    }

    func handleKeyboardWillHideNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 76 + field2.frame.height + CGRectGetMaxY(tokenView.tokenField.frame))
        self.containerView.setHeight(self.scrollView.contentSize.height - 1)
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
            }, completion: nil)
    }
    
    func handleKeyboardWillChangeFrameNotification(notification: NSNotification) {
    }
    
    func handleTextviewDidChangeNotification(notification: NSNotification) {
//       println("noti----------------> \(notification)")
    }

    // text view delegate 
    /* 在编辑 “记本简介” 时，根据选择的内容来实现滚动 */
    func textViewDidChangeSelection(textView: UITextView) {
        if textView.tag == 16555 {
            /**/
            
            var tmpField2Height = textView.text.stringHeightWith(14.0, width: textView.contentSize.width - textView.contentInset.left * 2) + textView.contentInset.top * 2
            self.field2.frame.size.height = self.field2.frame.height > tmpField2Height ? self.field2.frame.height : tmpField2Height
            self.tokenView.frame.origin.y = CGRectGetMaxY(self.field2.frame)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 76 + field2.frame.height + tokenView.frame.height)
//            self.view.layoutIfNeeded()
            println("self.field2.frame.size = \(self.field2.frame.size)")
            
            var _rect = textView.caretRectForPosition(textView.selectedTextRange?.end)
            
            if field2.isFirstResponder() {
                if ((_rect.origin.y + 78 + keyboardHeight) > (UIScreen.mainScreen().bounds.height - 64)) {
                    var extraHeight = _rect.origin.y + 78 - self.scrollView.contentOffset.y + keyboardHeight
                    var heightExcludeNavbar = UIScreen.mainScreen().bounds.height - 64
                    var extraScrollOffset = extraHeight - heightExcludeNavbar
                    
                    self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentOffset.y + extraScrollOffset), animated: true)
                    println("self.scrollView.contentOffset = \(self.scrollView.contentOffset)")
                }
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view .isKindOfClass(UITableView) || touch.view .isKindOfClass(UITableViewCell) {
            return false
        }
        
        return true
    }
    
}

extension AddDreamController: TITokenFieldDelegate {
    func tokenField(field: TITokenField!, shouldUseCustomSearchForSearchString searchString: String!) -> Bool {
        return true
    }
    
    func tokenField(field: TITokenField!, performCustomSearchForSearchString searchString: String!, withCompletionHandler completionHandler: (([AnyObject]!) -> Void)!) {
        var data: Array<String> = []
        
        if count(searchString) > 0 {
            var _string = SAEncode(SAHtml(searchString))
            Api.getAutoComplete(_string, callback: {
                json in
                if json != nil {
                    data = json as! Array
                    
                    if count(data) > 0 {
                        for i in 0...(count(data) - 1) {
                            data[i] = SADecode(SADecode(data[i]))
                        }
                    }
                }
                completionHandler(data)
            })
        }
    }
    
    func tokenField(tokenField: TITokenField!, didAddToken token: TIToken!) {
        var _string: String = token.title
        
        _string.removeAtIndex(advance(token.title.startIndex, 0))
        if contains(self.tagsArray, _string) {
            return
        }
        
        Api.getTags(SAEncode(SAHtml(_string)), callback: {
            json in
            if json != nil {
                var status = json!["status"] as! NSNumber
            }
        })
    }
    
    func tokenField(tokenField: TITokenField!, didChangeFrame frame: CGRect) {
    }
    
}

extension AddDreamController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.field1.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
    }
}





















