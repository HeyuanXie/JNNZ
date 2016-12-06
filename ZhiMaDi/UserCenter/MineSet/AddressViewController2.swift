//
//  AddressViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/9/28.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//
/*
取到所有的地址数组，把快递放到kuaidiArray中,把代收放到daishouArray中,通过某个字段isToHome判断是否为快递送货上门
tableViewDataSource中，如果section > kuaidiArray.count 就configDaiShouCell
*/
import UIKit
//管理收货地址
class AddressViewController2: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol {
    
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var AddAddressBtn: UIButton!
    var rightItem : UIBarButtonItem!
    
    var selectAddressFinished : ((address : String)->Void)?
    var isEdit = false
    var addresses = NSMutableArray()
    var kuaiDiArray = NSMutableArray()  //快递上门地址数组
    
    var selectIndex = 0
    var finished : ((address: ZMDAddress)->Void)?
    var canSelect = true        //是否有选择地址按钮
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
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
//        return self.addresses.count
        return self.kuaiDiArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == self.kuaiDiArray.count || section == 0{
            return self.canSelect ? 40 : 0
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
        if section == 0 && self.canSelect {
            let headerViewLabel = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), text: "   送货上门:", fontSize: 15, textColor: defaultTextColor, textAlignment: NSTextAlignment.Left)
            headerViewLabel.backgroundColor = tableViewdefaultBackgroundColor
            return headerViewLabel
        } else {
            let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 16))
            headView.backgroundColor = UIColor.clearColor()
            return headView
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "kuaidiCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! AdressTableViewCell
        let address = self.kuaiDiArray[indexPath.section] as! ZMDAddress
        AdressTableViewCell.configCell(cell, address: address)
        cell.selectedBtn.selected = indexPath.section == self.selectIndex
    
        if !self.isEdit {
            cell.editBtn.hidden = true
            
            if !canSelect { //没有选择按钮
                cell.title.snp_updateConstraints(closure: { (make) -> Void in
                    make.right.equalTo(cell.contentView).offset(0)
                })
                cell.address.snp_updateConstraints(closure: { (make) -> Void in
                    make.right.equalTo(cell.contentView).offset(0)
                })
                cell.selectedBtn.hidden = true
            }

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                cell.editBtnWidthConstraint.constant = 12
                cell.selectedBtn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
                cell.selectedBtn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
                cell.layoutIfNeeded()
            })
            
            //select
            cell.selectedBtn.tag = 1000 + indexPath.section
            cell.selectedBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.selectIndex = sender.tag - 1000
                self.currentTableView.reloadData()
                return RACSignal.empty()
            })
        } else {
            // 编辑
            cell.editBtn.hidden = false
            cell.selectedBtn.hidden = false
            cell.title.snp_updateConstraints(closure: { (make) -> Void in
                make.right.equalTo(-52)
            })
            cell.address.snp_updateConstraints(closure: { (make) -> Void in
                make.right.equalTo(-52)
            })

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                cell.editBtnWidthConstraint.constant = 60
                cell.selectedBtn.setImage(UIImage(named: "btn_delete"), forState: .Normal)
                cell.selectedBtn.setImage(UIImage(named: "btn_delete"), forState: .Selected)
                cell.layoutIfNeeded()
            })
            cell.editBtn.tag = 1000 + indexPath.section
            cell.editBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let address = self.addresses[sender.tag - 1000] as! ZMDAddress
                let vc = AddressEditOrAddViewController2()
                vc.isAdd = false    //isAdd为true时是添加收货地址，为false时是编辑地址
                vc.address = address
                self.navigationController?.pushViewController(vc, animated: true)
                return RACSignal.empty()
            })
            //delete
            cell.selectedBtn.tag = 1000 + indexPath.section
            cell.selectedBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let address = self.addresses[sender.tag - 1000] as! ZMDAddress
                QNNetworkTool.deleteAddress(address.Id!.integerValue, customerId: g_customerId!, completion: { (succeed, dictionary,error) -> Void in
                    if error == nil {
                        self.fetchData()
                        ZMDTool.showPromptView("删除成功")
                    } else {
                        ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "")
                    }
                })
                return RACSignal.empty()
            })
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectIndex = indexPath.section
        self.currentTableView.reloadData()
    }
    //MARK: -  Action
    @IBAction func addAddressBtnCli(sender: UIButton) {
        let vc = AddressEditOrAddViewController2()
        vc.isAdd = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        if self.rightItem == nil {
            self.rightItem = UIBarButtonItem(title:"编辑", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
            rightItem.customView?.tintColor = defaultDetailTextColor
            rightItem.rac_command = RACCommand(signalBlock: { [weak self](sender) -> RACSignal! in
                if let StrongSelf = self {
                    StrongSelf.isEdit = !StrongSelf.isEdit
                    StrongSelf.currentTableView.reloadData()
                    StrongSelf.rightItem.title = StrongSelf.isEdit ? "取消" : "编辑"
                }
                return RACSignal.empty()
                })
            self.navigationItem.rightBarButtonItem = rightItem
        }
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
    }
    
    //MARK-fetchToHomeAddress
    func fetchData() {
        //获取送货上门地址列表
        self.fetchToHomeAddress()
    }
    //MARK-fetchToHomeAddress
    func fetchToHomeAddress() {
        QNNetworkTool.fetchAddresses { (addresses, error, dictionary) -> Void in
            if addresses != nil {
                self.addresses.removeAllObjects()
                self.addresses.addObjectsFromArray(addresses! as [AnyObject])
                var index = -1
                for address in self.addresses {
                    index++
                    if (address as! ZMDAddress).IsDefault.boolValue {
                        self.selectIndex = index
                    }
                }
                //每次请求后清空self.kuaiDiArray
                self.kuaiDiArray.removeAllObjects()
                self.kuaiDiArray.addObjectsFromArray(self.addresses as [AnyObject])
                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "")
            }
        }
    }
    
    override func back() {
        if self.selectIndex < self.kuaiDiArray.count {
            let address = self.kuaiDiArray[self.selectIndex] as! ZMDAddress
            if self.finished != nil {
                self.finished!(address:address)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}