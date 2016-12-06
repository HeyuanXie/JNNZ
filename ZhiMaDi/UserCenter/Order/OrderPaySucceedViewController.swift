//
//  OrderPaySucceedViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/31.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 支付成功
class OrderPaySucceedViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var tableView : UITableView!
    var total = ""
    var orderId : Int!
    var finished : (()->Void)!
    var dic : NSDictionary!
    var isPayed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.fetchData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 175
        } else if indexPath.row == 1 {
            return 102
        }
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.contentView.backgroundColor = RGB(255,145,89,1.0)
            
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth/2 - 57, y: 32, width: 94, height: 65))
            imgV.image = UIImage(named: "pay_express")
            cell?.contentView.addSubview(imgV)
            let topLbl = ZMDTool.getLabel(CGRect(x: 0, y: 32 + 65 + 23 , width: kScreenWidth, height: 18), text: "订单提交成功,等待卖家发货!", fontSize: 18)
            if self.isPayed == true {
                topLbl.text = "嘿嘿~你已付款成功！"
            }
            topLbl.textAlignment = .Center
            let botLbl = ZMDTool.getLabel(CGRect(x: 0, y: 32 + 65 + 23 + 18+8 , width: kScreenWidth, height: 16), text: "请等待卖家发货", fontSize: 16)
            botLbl.textAlignment = .Center
            cell?.contentView.addSubview(topLbl)
            cell?.contentView.addSubview(botLbl)
            return cell!
        }else if indexPath.row == 1 {
            let cellId = "msgCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 101.5, width: kScreenWidth, height: 0.5)))
                
                var tag = 10001
                let userLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                userLbl.tag = tag++
                cell?.contentView.addSubview(userLbl)
                let phoneLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 120, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                phoneLbl.tag = tag++
                cell?.contentView.addSubview(phoneLbl)
                let addressStr = ""
                let addressSize = addressStr.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
                let addressLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height), text: addressStr, fontSize: 17)
                addressLbl.numberOfLines = 2
                addressLbl.tag = tag++
                cell?.contentView.addSubview(addressLbl)
            }
            
            var tag = 10001
            let userLbl = cell?.viewWithTag(tag++) as! UILabel
            let phoneLbl = cell?.viewWithTag(tag++) as! UILabel
            let addressLbl = cell?.viewWithTag(tag++) as! UILabel
            
            //根据是否为送货上门设置UI
            if let dicForAddress = self.dic?["ShippingAddress"] as? NSDictionary,address = ZMDAddress.mj_objectWithKeyValues(dicForAddress) {
                userLbl.text = "收货人 ：\(address.FirstName)"
                phoneLbl.text = "\(address.PhoneNumber)"
                addressLbl.text = "收货地址:\(address.Address1!)\(address.Address2!)"
                let addressStr = addressLbl.text
                let addressSize = addressStr!.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
                addressLbl.frame = CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height)
            }
            return cell!
        } else if indexPath.row == 2 {
            let cellId = "totalCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                
                let botLbl = ZMDTool.getLabel(CGRect(x: 12, y: 0 , width: kScreenWidth, height: 55.5), text: "实付：0.0 获得0积分", fontSize: 16)
                botLbl.tag = 10001
                cell?.contentView.addSubview(botLbl)
                cell?.addLine()
            }
            let botLbl = cell?.viewWithTag(10001) as! UILabel
            if let total = self.dic?["OrderTotal"] as? String {
                botLbl.text = "实付：\(total)"
            }
            return cell!
        }else{
            let cellId = "botCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let width = (kScreenWidth-2*12-20)/2,height = CGFloat(40)
                var index = CGFloat(0)
                for title in ["查看订单","继续购物"] {
                    let btn = ZMDTool.getButton(CGRect(x: 12+(width+20)*index, y: 8, width: width, height: height), textForNormal: title, fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                        
                    })
                    ZMDTool.configViewLayer(btn)
                    ZMDTool.configViewLayerFrame(btn)
                    cell?.contentView.addSubview(btn)
                    btn.tag = 10000 + Int(index)
                    btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                        if (sender as! UIButton).tag == 10000 {
                            let vc = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
                            vc.orderStatuId = 1
                            vc.orderStatusIndex = 1
                            self.pushToVC(vc, animated: true, hideBottom: true)
                        }else{
                            ZMDTool.enterHomePageViewController()
                        }
                        return RACSignal.empty()
                    })
                    index++
                }
            }
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)*/
        
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.set("h",value: self.view.bounds.height-56)
        tableView.backgroundColor = tableViewdefaultBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
        
//        self.updateFoot()
    }
    
    func updateFoot() {
        let view = self.botView()
        self.view.addSubview(view)
        view.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
        }
        let width = kScreenWidth/2
        let height = view.frame.height
        let titles = ["查看订单","继续购物"]
        for i in 0..<2 {
            let btn = UIButton(frame: CGRect(x: CGFloat(i)*width, y: 0, width: width, height: height))
            btn.tag = 1000 + i
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.backgroundColor = UIColor.clearColor()
            view.addSubview(btn)
            if i == 0 {
                btn.addSubview(ZMDTool.getLine(CGRect(x: width-1, y: 0, width: 0.5, height: height)))
            }
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                if (sender as! UIButton).tag == 1000 {
//                    let vc = OrderCommentViewController()
//                    vc.orderId = self.orderId
                    let vc = MyOrderViewController.CreateFromStoreStoryboard() as! MyOrderViewController
                    vc.orderStatuId = 1
                    vc.orderStatusIndex = 1
                    self.pushToVC(vc)
                }else{
                    ZMDTool.enterHomePageViewController()
                }
                return RACSignal.empty()
            })
            
        }
    }
    override func back() {
        if self.finished != nil {
            self.finished()
        } else {
            super.back()
        }
    }
    func fetchData() {
        QNNetworkTool.orderDetail(self.orderId) { (succeed, dictionary, error) -> Void in
            if succeed!  {
                self.dic = dictionary
                self.tableView.reloadData()
            }
        }
    }
}
