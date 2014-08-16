//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    let identifier = "follow"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        self.tableView!.headerBeginRefreshing()
        SAReloadData()
        println(Id)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageViewTapped", object: nil)
    }
    
    
    
    func setupViews()
    {
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height - 64
        self.tableView = UITableView(frame:CGRectMake(0,0,width,height-49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"FollowCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320, 10))
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, 320, 20))
        self.view.addSubview(self.tableView)
        
    }
    
    
func loadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
        if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
        }
        var arr = data["items"] as NSArray
        for data : AnyObject  in arr{
                self.dataArray.addObject(data)
       }
            self.tableView!.reloadData()
            self.tableView!.footerEndRefreshing()
            self.page++
       })
}
    func SAReloadData(){
        self.page = 0
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.tableView!.reloadData()
            self.tableView!.headerEndRefreshing()
            self.page++
            })
    }
    
    
    func urlString()->String{
            return "http://nian.so/api/explore_fo.php?page=\(page)&uid=1"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        
        var cell = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? FollowCell
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        cell!.data = data
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        return  FollowCell.cellHeightByData(data)
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        var DreamVC = DreamViewController()
        DreamVC.Id = data.stringAttributeForKey("id")
        self.navigationController.pushViewController(DreamVC, animated: true)
    }
    
    func imageViewTapped(noti:NSNotification)
    {
//        var imageURL = noti.object as String
//        var imgVC = YRImageViewController(nibName: nil, bundle: nil)
//        imgVC.imageURL = imageURL
//        self.navigationController.pushViewController(imgVC, animated: true)
    }
    
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
            })
        self.tableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    
}
