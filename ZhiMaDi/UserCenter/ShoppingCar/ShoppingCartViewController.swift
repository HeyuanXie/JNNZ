//
//  ShoppingCartViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 购物车
class ShoppingCartViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var settlementBtn: UIButton!
    @IBOutlet weak var allSelectBtn: UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    var productAttrV : ZMDProductAttrView!
    var dataArray = NSMutableArray()
    var hideStore = false
    var attrSelects = NSMutableArray()         //所有的购物车内的数据
    var scis = NSMutableArray()             // 选中的购物单
    var countForBounght = 0                 // 购买数量
    var subTotal = ""
    
    var hiddenLbl : UILabel!        //是否登陆的label
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dataUpdate()
        if g_isLogin! && self.hiddenLbl != nil {
            self.hiddenLbl.removeFromSuperview()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count == 0 ? 0 : self.dataArray.count
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
//        if indexPath.row == 0 {
//            return 16
//        } else {
//            return indexPath.row == 1 ? 48 : 110
//        }
        return indexPath.row == 0 ? 0 : 110
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ZMDTool.getLine(CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
        return view
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "GoodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
        let line = ZMDTool.getLine(CGRect(x: 0, y: cell.bounds.height-1, width: kScreenWidth, height: 1))
        cell.contentView.addSubview(line)
        let item = self.dataArray[indexPath.row] as! ZMDShoppingItem
        cell.configCellInShoppingCar(item,scis:self.scis)
        cell.editFinish = { (productDetail,item) -> Void in
            self.attrSelects.removeAllObjects()
            for var i = 0;i<productDetail.ProductVariantAttributes!.count;i++ {
                self.attrSelects.addObject(";")
            }
            self.editViewShow(productDetail,item: item)
        }
        cell.selectFinish = { (Sci,isAdd) -> Void in
            if isAdd {
                self.scis.addObject(Sci)
            } else {
                self.scis.removeObject(Sci)
            }
            self.allSelectBtn.selected = self.scis.count == self.dataArray.count ? true : false
            self.updateTotal()
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let store : ZMDStoreDetail = (self.dataArray[0] as! ZMDShoppingItem).Store
            let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
            vc.storeId = store.Id
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let item = self.dataArray[indexPath.row] as! ZMDShoppingItem
        let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.productId = item.ProductId.integerValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -Action
    //全选
    @IBAction func selectAllBtnCli(sender: UIButton) {
        self.allSelectBtn.selected = !self.allSelectBtn.selected
        if self.allSelectBtn.selected {
            self.scis.removeAllObjects()
            for item in self.dataArray {
                self.scis.addObject(item)
            }
        } else {
            self.scis.removeAllObjects()
        }
        self.updateTotal()
        
        self.currentTableView.reloadData()
    }
    // MARK: - 结算
    @IBAction func settlementBtnCli(sender: UIButton) {
        if self.scis.count == 0 {
            return 
        }
        ZMDTool.showActivityView(nil)
        //点击结算，下订单
        QNNetworkTool.selectCart(self.getSciids(),completion: { (succeed, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if succeed! {
                let vc = ConfirmOrderViewController.CreateFromMainStoryboard() as! ConfirmOrderViewController
                vc.hidesBottomBarWhenPushed = true
                vc.scis = self.scis
                vc.total = self.subTotal
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
            }
        })
    }
    //MARK: -  PrivateMethod
    //购买数量View（- qulatiy +）
    func editViewShow(productDetail:ZMDProductDetail,item:ZMDShoppingItem) {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.whiteColor()
        // top
        let countLbl = UILabel(frame: CGRect(x: 12, y: 0, width: 200, height: 60))
        countLbl.textColor = defaultDetailTextColor
        countLbl.text = "购买数量"
        countLbl.font = defaultSysFontWithSize(16)
        view.addSubview(countLbl)
        
        let countView = CountView(frame: CGRect(x: kScreenWidth - 12 - 120, y: 10, width: 120, height: 40))
        countView.finished = {(count)->Void in
            self.countForBounght = count
        }
        countView.countForBounght = item.Quantity.integerValue
        self.countForBounght = countView.countForBounght
        countView.updateUI()
        view.addSubview(countView)
       
        productAttrV = ZMDProductAttrView(frame: CGRect.zero, productDetail: productDetail)
        productAttrV.SciId = item.Id.integerValue
        productAttrV.frame = CGRectMake(0, 60,kScreenWidth, productAttrV.getHeight())
        view.addSubview(productAttrV)
        // bottom
        let okBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 14 - 110, y:CGRectGetMaxY(productAttrV.frame)+12, width: 110, height: 36), textForNormal: "确定", fontSize: 17,textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0)) { (sender) -> Void in
            self.editCart()
            self.dismissPopupView(view)
        }
        ZMDTool.configViewLayerWithSize(okBtn, size: 18)
        view.addSubview(okBtn)
        let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 14 - 110 - 8 - 80, y: CGRectGetMaxY(productAttrV.frame)+12, width: 80, height: 36), textForNormal: "取消", fontSize: 17, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            self.dismissPopupView(view)
        }
        view.addSubview(cancelBtn)
        var i = 0
        for _ in ["","","",""] {
            i++
            let line = ZMDTool.getLine(CGRect(x: 0, y: 60*CGFloat(i), width: kScreenWidth, height: 0.5))
            view.addSubview(line)
        }
        self.viewShowWithBg(view,showAnimation: .SlideInFromBottom,dismissAnimation: .SlideOutToBottom)
        view.frame = CGRect(x: 0, y: self.view.bounds.height - (CGRectGetMaxY(productAttrV.frame) + 60), width: kScreenWidth, height: CGRectGetMaxY(productAttrV.frame) + 60)
    }
    
    //MARK:updateUI,设置tabbarItem的badgeValue
    func updateUI() {
        
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        ZMDTool.configViewLayerWithSize(settlementBtn,size: 16)
        let rightBtn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 65, height: 44), textForNormal: "删除", fontSize: 16,backgroundColor: UIColor.clearColor(), blockForCom: nil)
        rightBtn.setImage(UIImage(named: "common_delete"), forState: .Normal)
        //        rightBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        //        rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            if self.scis.count != 0 {
                self.deleteCartItem()
                self.allSelectBtn.selected = false
            }
            return RACSignal.empty()
        })
        let item = UIBarButtonItem(customView: rightBtn)
        item.customView?.tintColor = defaultDetailTextColor
        self.navigationItem.rightBarButtonItem = item

        self.currentTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 16))
        
        self.hiddenLbl = ZMDTool.getLabel(CGRect(x: 0, y: kScreenHeight/3-20, width: kScreenWidth, height: 20), text: "您还没有登陆额!", fontSize: 16, textColor: defaultTextColor, textAlignment: NSTextAlignment.Center)
        self.view.addSubview(self.hiddenLbl)
        
        if g_isLogin! {
            self.hiddenLbl.removeFromSuperview()
        }
    }
    
    //请求购物车页面数据
    func dataUpdate() {
        if g_isLogin! {
            ZMDTool.showActivityView(nil)
        }
        QNNetworkTool.fetchShoppingCart(1) { (shoppingItems, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if shoppingItems != nil {
                self.dataArray = NSMutableArray(array: shoppingItems!)
                //默认全选
                if self.dataArray.count != 0 {
                    self.scis.removeAllObjects()
                    self.scis.addObjectsFromArray(self.dataArray as [AnyObject])
                    self.allSelectBtn.selected = true
                }
                //通过updateTotal计算选中物品总金额
                self.updateTotal()
                
                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
            }
        }
    }
    
    //编辑购物车item
    func editCart() {
        let dic = self.productAttrV.getPostData(self.countForBounght)
        if dic == nil {
            return
        }
        if g_isLogin! {
            QNNetworkTool.editCartItemAttribute(dic!, completion: { (succeed, dictionary, error) -> Void in
                if succeed! {
                    self.dataUpdate()
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "修改失败")
                }
            })
        }
    }
    
    //MARK: 计算总金额updateTotal->setTotal
    func setTotal(subTotal:Double) {
        self.subTotal = "\(subTotal)"
        self.totalLbl.text = String(format: "合计:%.2f", subTotal)
    }
    func updateTotal() {
        var scisNes = NSMutableArray()
        //总金额
        var tmp = Double(0)
        var index = -1
        for item in self.scis {
            index++
            for tmp in self.dataArray {
                if (item as! ZMDShoppingItem).Id == (tmp as! ZMDShoppingItem).Id {
                    self.scis.replaceObjectAtIndex(index, withObject: tmp)
                    scisNes.addObject(tmp)
                }
            }
        }
        //计算选中物品总金额
        self.scis = scisNes
        for item in self.scis {
            let subTotal = (item as! ZMDShoppingItem).SubTotal.stringByReplacingOccurrencesOfString("¥", withString: "").stringByReplacingOccurrencesOfString(",", withString: "")
            tmp = tmp + Double(subTotal)!
        }
        //把计算的总金额更新到UI
        self.setTotal(tmp)
    }
    
    //MARK:删除购物车item：getSciids(作为参数)->deleteCarItem
    func deleteCartItem() {
        //得到选中items.id 拼接成的字符串，作为删除请求的参数
        let items = self.getSciids()
        if g_isLogin! {
            QNNetworkTool.deleteCartItem(items,carttype: 1,completion: { (succeed, dictionary, error) -> Void in
                if succeed! {
                    //删除成功，清空选中的购物单，然后在刷新UI
                    self.scis.removeAllObjects()
                    //****这里可以注释，因为在dataUpdate中含有updateTotal方法
//                    self.updateTotal()
                    self.dataUpdate()
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "删除失败")
                }
            })
        }
    }
    //将选中的item的id用;拼接成字符串
    func getSciids()  -> String {
        let items = NSMutableString()
        var index = -1
        for tmp in self.scis {
            index++
            let sciId = (tmp as! ZMDShoppingItem).Id
            let scid = index == self.scis.count - 1 ? "\(sciId)" : "\(sciId),"
            items.appendString(scid)
        }
        return items as String
    }

}
