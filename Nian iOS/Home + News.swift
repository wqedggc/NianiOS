//
//  Home+News.swift
//  Nian iOS
//
//  Created by Sa on 15/8/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

extension HomeViewController: NIAlertDelegate {
    func SANews() {
        Api.getNews() { json in
            delay(3, closure: {
                if json != nil {
                    let data = json!.objectForKey("news") as! NSDictionary
                    let title = data.stringAttributeForKey("title")
                    if title != "" {
                        let content = data.stringAttributeForKey("content")
                        let button = data.stringAttributeForKey("button")
                        let version = data.stringAttributeForKey("version")
                        let v: AnyObject? = Cookies.get("SANews.\(version)")
                        if v == nil {
                            self.ni = NIAlert()
                            self.ni!.delegate = self
                            self.ni!.dict = NSMutableDictionary(objects: [UIImage(named: "pet_egg2")!, title, content, [button]],
                                forKeys: ["img", "title", "content", "buttonArray"])
                            self.ni!.showWithAnimation(.flip)
                            Cookies.set("1", forKey: "SANews.\(version)")
                        }
                    }
                }
            })
        }
    }
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == ni {
            niAlert.dismissWithAnimation(.normal)
        }
    }
}