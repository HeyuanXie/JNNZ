//
//  AddressViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/9/28.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//
import UIKit
//管理收货地址
class DSAddressViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol {
    
    @IBOutlet weak var currentTableView: UITableView!
    var rightItem : UIBarButtonItem!
    
    var selectAddressFinished : ((address : String)->Void)?
    var isEdit = false
    var daiShouArray = NSMutableArray()
    var didChooseAddress = false
    var selectIndex = 0

    var finished : ((address:ZMDDSAddress)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.fetchData()
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
        return self.daiShouArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 40
        }
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 106
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerViewLabel = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), text: "   网点代收:", fontSize: 15, textColor: defaultTextColor, textAlignment: NSTextAlignment.Left)
            headerViewLabel.backgroundColor = tableViewdefaultBackgroundColor
            return headerViewLabel
        } else {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
            headView.backgroundColor = UIColor.clearColor()
            return headView
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "daishouCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! AdressTableViewDaiShouCell
        ZMDTool.configTableViewCellDefault(cell)
        
        let address = self.daiShouArray[indexPath.section] as! ZMDDSAddress
        AdressTableViewDaiShouCell.configCell(cell, address: address)
        cell.selectedBtn.selected = indexPath.section == self.selectIndex
        cell.selectedBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.selectIndex = indexPath.section
            self.currentTableView.reloadData()
            return RACSignal.empty()
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectIndex = indexPath.section
        self.currentTableView.reloadData()
    }
    
    //MARK: ---PrivateMethod
    func initUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        let rightItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        rightItem.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.navigationController?.popViewControllerAnimated(true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func fetchData() {
        //获取网店代收地址列表
        self.fetchDaiShouAddress()              
    }
    //MARK-fetchDaiShouAddress
    func fetchDaiShouAddress() {
        QNNetworkTool.fetchDaiShouAddress { (address, error, data) -> Void in
            self.daiShouArray.removeAllObjects()
            if error == nil {
                self.daiShouArray.addObjectsFromArray(address as! [AnyObject])
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: error)
            }
            self.currentTableView.reloadData()
        }
    }
    
    override func back() {
        if self.selectIndex < self.daiShouArray.count {
            let address = self.daiShouArray[self.selectIndex] as! ZMDDSAddress
            if self.finished != nil {
                self.finished!(address: address)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}
