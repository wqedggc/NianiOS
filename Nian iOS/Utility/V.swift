//
//  V.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

struct V {
    
    enum IMAGE_TAG: String {
        case iOS = "ios"
        case iOSFo = "iosfo"
        case Head = "head"
        case Dream = "dream"
        case Large = "large"
    }
    
    static let Tags = ["日常", "摄影", "恋爱", "创业", "阅读", "追剧", "绘画", "英语", "收集", "健身", "音乐", "写作", "旅行", "美食", "设计", "游戏", "工作", "习惯", "写字", "其他"]
    
    class CustomActivity: UIActivity {
        
        var title: String?
        var image: UIImage?
        var callback: (([AnyObject]) -> Void)?
        
        init(title: String, image: UIImage?,callback: ([AnyObject]) -> Void) {
            super.init()
            self.title = title
            self.image = image
            self.callback = callback
        }
        
        override func activityType() -> String? {
            return ""
        }
        
        override func activityTitle() -> String? {
            return title
        }
        
        override func activityImage() -> UIImage? {
            return image
        }
        
        override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
            return true
        }
        
        override func prepareWithActivityItems(activityItems: [AnyObject]) {
            self.callback!(activityItems)
        }
    }
    
    typealias StringCallback = String? -> Void
    typealias JsonCallback = AnyObject? -> Void
    
    static func httpGetForJson(requestURL: String, callback: JsonCallback) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(requestURL,
            parameters: nil,
            success: {(op: AFHTTPRequestOperation!, obj: AnyObject!) in
                callback(obj)
            },
            failure: {(op: AFHTTPRequestOperation!, error: NSError!) in
                logError("AFN get error: \(error.localizedDescription)")
        })
    }
    
    static func httpPostForJson_AFN(requestURL: String, content: AnyObject, callback: JsonCallback) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(requestURL,
            parameters: content,
            success: {(op: AFHTTPRequestOperation!, obj: AnyObject!) -> Void in
                callback(obj)
        },
            failure: {(op: AFHTTPRequestOperation!, error: NSError!) -> Void in
                logError("AFN post error: \(error.localizedDescription)")
        })
    }
    
    static func httpPutForJson_AFN(requestURL: String, content: AnyObject, callback: JsonCallback) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.PUT(requestURL,
            parameters: content,
            success: {(op: AFHTTPRequestOperation!, obj: AnyObject!) -> Void in
                callback(obj)
            },
            failure: {(op: AFHTTPRequestOperation!, error: NSError!) -> Void in
        })
    }
    
    static func httpDeleteForJson_AFN(requestURL: String, content: AnyObject, callback: JsonCallback) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.DELETE(requestURL,
            parameters: content,
            success: {(op: AFHTTPRequestOperation!, obj: AnyObject!) -> Void in
                callback(obj)
            },
            failure: {(op: AFHTTPRequestOperation!, error: NSError!) -> Void in
        })
    }
    
    
    static func httpGetForJsonSync(requestURL: String, callback: JsonCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: requestURL)
            let data = try? NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached)
            var json: AnyObject? = nil
            if data != nil {
                json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            }
            callback(json)
        })
    }
    
    static func httpGetForString(requestURL: String, callback: StringCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: requestURL)
            let data = try? NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached)
            var string: String?
            if data != nil {
                string = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(string)
            })
        })
    }
    
    static func httpPostForString(requestURL: String, content: String, callback: StringCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let request = NSMutableURLRequest()
            request.URL = NSURL(string: requestURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
            var response: NSURLResponse?
            var error: NSError?
            var data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse : &response)
            } catch let error1 as NSError {
                error = error1
                data = nil
            } catch {
                fatalError()
            }
            var string: String?
            if  error == nil {
                string = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(string)
            })
        })
        
    }
    
    static func httpPostForJson(requestURL: String, content: String, callback: JsonCallback) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let request = NSMutableURLRequest()
            request.URL = NSURL(string: requestURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
            var response: NSURLResponse?
            var data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse : &response)
            } catch _ as NSError {
                data = nil
            } catch {
                fatalError()
            }
            var json: AnyObject? = nil
            if data != nil {
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch _ as NSError {
                    json = nil
                } catch {
                    fatalError()
                }

            }
            
            dispatch_async(dispatch_get_main_queue(), {
                callback(json)
            })
        })
    }
    
    static func httpPostForJsonSync(requestURL: String, content: String, callback: JsonCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let request = NSMutableURLRequest()
            request.URL = NSURL(string: requestURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
            var response: NSURLResponse?
            var data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse : &response)
            } catch _ as NSError {
                data = nil
            } catch {
                fatalError()
            }
            var json: AnyObject? = nil
            if data != nil {
                json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            }
            // 为什么没有回到主线程 ?
            callback(json)
        })
    }
    
    static func enTime(timestamp: String) -> String {
        let time = (timestamp as NSString).doubleValue
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func enTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return "\(formatter.stringFromDate(NSDate()))"
    }
    
    static func now() -> String {
        return "\(Int(NSDate().timeIntervalSince1970))"
    }
    
    static func relativeTime(timestamp: String) -> String {
        let current = NSDate().timeIntervalSince1970
        let time = (timestamp as NSString).doubleValue
        let d = current - time
        let formatter = NSDateFormatter()
        let component = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second],
            fromDate: NSDate())
        component.timeZone = NSTimeZone.systemTimeZone()
        component.hour = 0
        component.minute = 0
        component.second = 0
        let today = NSCalendar.currentCalendar().dateFromComponents(component)!.timeIntervalSince1970
        if d < 10 {
            return "刚刚";
        } else if d < 60 {
            return "\(Int(d)) 秒前"
        } else if d < 3600 {
            return "\(NSNumber(double: floor(d / 60)).integerValue) 分前"
        }else if time >= today {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func relativeTime(time: NSTimeInterval, current: NSTimeInterval) -> String {
        let d = current - time
        let formatter = NSDateFormatter()
        if d < 10 {
            return "刚刚";
        } else if d < 60 {
            return "\(Int(d)) 秒前"
        } else if d < 3600 {
            return "\(NSNumber(double: floor(d / 60)).integerValue) 分前"
        } else if d < 86400 {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func absoluteTime(time: NSTimeInterval) -> String {
        let d = NSDate().timeIntervalSince1970 - time
        let formatter = NSDateFormatter()
        if d < 86400 {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func dataFromPath(path: String) -> NSData? {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return NSData(contentsOfFile: path)
        }
        return nil
    }
    
    static func urlShareDream(did: String) -> NSURL {
        return NSURL(string: "http://nian.so/m/dream/\(did)")!
    }
    
    static func urlDreamImage(img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/dream/\(img)!\(tag.rawValue)"
    }
    
    static func urlHeadImage(uid: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/head/\(uid).jpg!\(tag.rawValue)"
    }
    
    static func urlStepImage(img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/step/\(img)!\(tag.rawValue)"
    }
    
    static func urlCircleCoverImage(img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/step/\(img)!\(tag.rawValue)"
    }
    
    static func getDay(time: NSTimeInterval) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
}

extension UIView {
    
    func findRootViewController() -> UIViewController? {
        for var view: UIView? = self; view != nil; view = view!.superview {
            let responder = view?.nextResponder()
            if responder! is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
    
    func showTipText(text: String, delay: Double = 2.0) {
        let tipView = UIView()
        tipView.layer.masksToBounds = true
        tipView.layer.cornerRadius = 4
        tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        tipView.userInteractionEnabled = false
        let fontSize: CGFloat = 14
        let textWidth: CGFloat = 180
        var h: CGFloat = fontSize
        var w: CGFloat = text.stringWidthWith(fontSize, height: h)
        if w > textWidth {
            w = textWidth
            h = text.stringHeightWith(fontSize, width: textWidth)
        }
        let tipLabel = UILabel(frame: CGRectMake(15, 15, w, h))
        tipLabel.text = text
        tipLabel.font = UIFont.systemFontOfSize(fontSize)
        tipLabel.lineBreakMode = .ByWordWrapping
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = NSTextAlignment.Center
        tipLabel.textColor = UIColor.whiteColor()
        let size = CGSizeMake(w + 30, h + 30)
        tipView.frame.size = size
        tipView.frame.origin = CGPointMake((globalWidth - size.width) / 2, globalHeight * 0.5 - size.height / 2)
        tipView.addSubview(tipLabel)
        self.window?.addSubview(tipView)
        UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions(), animations: { tipView.alpha = 0 }, completion: {
            finished in
            tipView.removeFromSuperview()
        })
    }
    
}