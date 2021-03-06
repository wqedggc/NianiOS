//
//  ModelViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/23/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


class PatternViewController: UIViewController {
    
    /// "模式"选中时的颜色
    let c5Color = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
    /// "模式"未选中时的颜色
    let c7Color = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
    
    /// 中间分割线的宽度
    @IBOutlet weak var widthLine: NSLayoutConstraint!
    /// 困难模式的图片
    @IBOutlet weak var toughImageView: UIImageView!
    /// 简单模式的图片
    @IBOutlet weak var simpleImageView: UIImageView!
    /// "困难" label
    @IBOutlet weak var toughLabel: UILabel!
    /// "简单" label
    @IBOutlet weak var simpleLabel: UILabel!
    /// "困难模式"描述 label
    @IBOutlet weak var toughIllustrate: UILabel!
    /// "简单模式"描述 label
    @IBOutlet weak var simpleIllustate: UILabel!
    ///
    @IBOutlet weak var toughView: UIView!
    ///
    @IBOutlet weak var simpleView: UIView!
    ///
    @IBOutlet weak var containerView: UIView!
    /// 中间的分割线
    @IBOutlet weak var viewLine: UIView!
    ///
    @IBOutlet weak var accompolishButton: CustomButton!
    
    /// 注册时应提供的信息
    var regInfo: RegInfo?
    /// 玩念的模式 -- 困难 or 简单
    var playMode: PlayMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playMode = .easy
        setPlayMode(PlayMode.easy)
    }

    /**
    设置玩念的模式
    */
    func setPlayMode(_ mode: PlayMode) {
        if mode == PlayMode.easy {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = c5Color
            self.simpleIllustate.textColor = c5Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = c7Color
            self.toughIllustrate.textColor = c7Color
            
            self.playMode = PlayMode.easy
        } else {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = c7Color
            self.simpleIllustate.textColor = c7Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = c5Color
            self.toughIllustrate.textColor = c5Color
            
            self.playMode = PlayMode.hard
        }
    }
    
    /**
    tap 手势 on tough mode view
    */
    @IBAction func touchOnLeftView(_ sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.hard)
    }
    
    /**
    tap 手势 on simple mode view
    */
    @IBAction func touchOnRightView(_ sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.easy)
    }
    
    /**
    点击“完成” Button, 完成注册
    */
    @IBAction func accompolishRegister(_ sender: UIButton) {
        self.accompolishButton.startAnimating()
        
        let _password = "n*A\(self.regInfo!.password!)"
        Api.register(self.regInfo!.email!, password: _password.md5, username: self.regInfo!.nickname!, daily: self.playMode!.rawValue) { json in
            if json != nil {
                self.accompolishButton.stopAnimating()
                self.accompolishButton.setTitle("完成", for: UIControlState())
                let error = SAValue(json, "error")
                if error == "2" {
                    self.showTipText("用户名被占用...")
                    self.dismiss(animated: true, completion: nil)
                } else if error == "0" {
                    if let j = json as? NSDictionary {
                        if let data = j.object(forKey: "data") as? NSDictionary {
                            let shell = data.stringAttributeForKey("shell")
                            let uid = data.stringAttributeForKey("uid")
                            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                            uidKey?.setObject(uid, forKey: kSecAttrAccount)
                            uidKey?.setObject(shell, forKey: kSecValueData)
                            Api.requestLoad()
                            /* 使用邮箱来注册 */
                            self.launch(0)
                            self.pushTomorrow()
                        }
                    }
                }
            }
        }
    }
}
