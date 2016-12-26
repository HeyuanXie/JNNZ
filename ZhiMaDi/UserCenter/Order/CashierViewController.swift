//
//  CashierViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/31.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 收银台
class CashierViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    var tableView : UITableView!
    let datas = NSMutableArray()
    let images = ["pay_InHome","pay_alipay"]
    var indexTypeRow = 0
    var finished : ((indexType:Int,IndexDetail:Int)->Void)!
    var mark = ""
    var total = ""
    var payMethods = NSMutableArray()
    var selectPayMethod : ZMDPaymentMethod!
    var selectPayMethodName = ""
    var orderId : Int!
    
    var payString : String!
//    enum 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr = NSMutableArray()
        arr.addObjectsFromArray(self.payMethods as [AnyObject])
        for item in arr {
            let method = item as! ZMDPaymentMethod
            if method.Name == nil {
                self.payMethods.removeObject(item)
            }
        }
        if self.payMethods.count != 0 {
            self.selectPayMethod = self.payMethods[0] as! ZMDPaymentMethod
        }
        
//        let tmp = payMethods.filter(){
//            let tmp = $0 as! ZMDPaymentMethod
//            return tmp.Selected.boolValue
//        }
//        if tmp.count == 1 {
//            self.selectPayMethod = tmp[0] as! ZMDPaymentMethod
//            payMethods.removeObject(self.selectPayMethod)
//        }
        
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.payMethods.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 57
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 55 : 70
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 57))
            headView.backgroundColor = UIColor.clearColor()
            let label = ZMDTool.getLabel(CGRect(x: 12, y: 30, width: 150, height: 17), text: "选择其他支付方式", fontSize: 17)
            headView.addSubview(label)
            return headView
        }
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 12))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth - 12 - 20, y: 17, width: 20, height: 20))
            imgV.tag = 10001
            cell?.contentView.addSubview(imgV)
            cell?.addLine()
            let selectBtn = UIButton(frame: CGRect(x: kScreenWidth - 40, y: 8, width: 40, height: 40))
            selectBtn.selected = indexPath.section == self.indexTypeRow ? true : false
            selectBtn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
            selectBtn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
            selectBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                self.indexTypeRow = indexPath.section
                tableView.reloadData()
                return RACSignal.empty()
            })
            selectBtn.tag = 1000
            cell?.contentView.addSubview(selectBtn)
        }
        let method = self.payMethods[indexPath.section] as! ZMDPaymentMethod
        self.setPayImage(cell!, method: method)
        cell?.textLabel?.text = method.Name
        (cell?.contentView.viewWithTag(1000) as! UIButton).selected = indexPath.section == self.indexTypeRow
        return cell!
    }
    
    //点击选择支付方式cell时直接 生成订单并支付
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexTypeRow = indexPath.section
        self.tableView.reloadData()
}
    
    //MARK:设置支付方法图片
    func setPayImage(cell:UITableViewCell, method:ZMDPaymentMethod) {
        //url有效时打开
        /*if let urlStr = method.ImageUrl,url = NSURL(string: kImageAddressMain+urlStr) {
            cell.imageView?.sd_setImageWithURL(url, placeholderImage: nil)
            return
        }*/
        if method.Name == nil {
            return
        }
        switch method.Name {
        case "货到付款":
            cell.imageView?.image = UIImage(named: "pay_InHome")
            return
        case "支付宝付款":
            cell.imageView?.image = UIImage(named: "pay_alipay")
            return
        case "银联支付":
            cell.imageView?.image = UIImage(named: "pay_UnionPay")
            return
        case "微信支付":
            cell.imageView?.image = UIImage(named: "pay_wechat")
            return
        default :
            return
        }
    }
    
    //提交订单提交成功后直接完成支付
    /*dictionary[PayString]存在则为支付宝*/
    func respondForPostOrder(succeed : Bool!,dictionary:NSDictionary?,error: NSError?) {
        ZMDTool.hiddenActivityView()
        if succeed! {
            if let orderId = dictionary?["OrderId"] as? Int {
                self.orderId = orderId
                if let payString = dictionary?["PayString"] as? String {
                    self.submitAliOrder(payString, isPayed: true)
                }else{
                    self.submitAliOrder("", isPayed: false)
                }
            }else{
                let payModelDic = dictionary?["payModel"]
                if let orderId = payModelDic?["OrderId"] as? NSNumber {
                    self.orderId = orderId.integerValue
                    if let payString = payModelDic?["PayString"] as? String {
                        self.submitAliOrder("\(payString)", isPayed: true)
                    }else{
                        self.submitAliOrder("", isPayed: false)
                    }
                }
            }
        } else {
            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: dictionary!["error"] as? String)
        }
    }
    
    //MARK; - back
    override func back() {
        if self.orderId != nil {
            let vcs = self.navigationController!.viewControllers
            let vc = vcs[vcs.count - 1 - 2]
            self.navigationController?.popToViewController(vc, animated: true)
        } else {
            super.back()
        }
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "收银台"
        tableView = UITableView(frame: self.view.bounds)
        tableView.backgroundColor = tableViewdefaultBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
        
        self.addFootView()
    }
    
    func addFootView() {
//        let footV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36+50))
        let footV = UIView(frame: CGRectZero)
        self.view.addSubview(footV)
        footV.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(-12)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(36+50)
        }
        footV.backgroundColor = UIColor.clearColor()
        let btn = ZMDTool.getButton(CGRect(x: 12, y: 36, width: kScreenWidth - 24, height: 50), textForNormal: "确认支付", fontSize: 20, textColorForNormal:UIColor.whiteColor(),backgroundColor: defaultSelectColor) { (sender) -> Void in
            //确认支付
            self.selectPayMethod = self.payMethods[self.indexTypeRow] as! ZMDPaymentMethod
            if self.orderId != nil {
                ZMDTool.showActivityView(nil)
                QNNetworkTool.rePostPayment(self.orderId, Paymentmethod: self.selectPayMethod.PaymentMethodSystemName, completion: { (succeed, dictionary, error) -> Void in
                    ZMDTool.hiddenActivityView()
                    ZMDTool.hiddenActivityView()
                    self.respondForPostOrder(succeed, dictionary: dictionary, error: error)
                })
            } else {
                ZMDTool.showActivityView(nil)
                QNNetworkTool.confirmOrder(self.mark, Paymentmethod: self.selectPayMethod.PaymentMethodSystemName, completion: { (succeed, dictionary, error) -> Void in
                    ZMDTool.hiddenActivityView()
                    //利用confirmOrder的返回值作为参数，自定义一个方法
                    self.respondForPostOrder(succeed, dictionary: dictionary, error: error)
                })
            }
        }
        ZMDTool.configViewLayerWithSize(btn, size: 12)
        footV.addSubview(btn)
    }
    
    //支付宝支付
    private func submitAliOrder(orderString: String,isPayed: Bool){
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        let appScheme: String = "alisdkforJNNZ"
        let vc = OrderPaySucceedViewController()
        vc.isPayed = isPayed
        vc.orderId = self.orderId
        vc.finished = {() -> Void in
            let vcs = self.navigationController!.viewControllers
            let vc = vcs[vcs.count - 1 - 3]
            //返回到购物车页面
            self.navigationController?.popToViewController(vc, animated: true)
        }
        
        if isPayed {
            //支付堡支付
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) -> Void in
                if let Alipayjson = resultDic as? NSDictionary {
                    let resultStatus = Alipayjson.valueForKey("resultStatus") as! String
                    if resultStatus == "9000"{
                        //支付成功跳转到支付成功页面
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if resultStatus == "8000" {
                        ZMDTool.showPromptView( "正在处理中")
                    }else if resultStatus == "4000" {
                        ZMDTool.showPromptView( "订单支付失败")
                    }else if resultStatus == "6001" {
                        ZMDTool.showPromptView( "用户中途取消")
                    }else if resultStatus == "6002" {
                        ZMDTool.showPromptView( "网络连接出错")
                    }
                }
            })
        }else{
            //货到付款直接跳转OrderSuccess页面
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
