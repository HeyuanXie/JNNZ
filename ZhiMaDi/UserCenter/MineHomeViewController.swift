//
//  MineViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/22.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我的  首页
class MineHomeViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate,ZMDInterceptorNavigationBarHiddenProtocol {
    enum UserCenterCellType{
        case NewProduct
        case Exchange
        case Goods
        case OfferCenter
        case Financia
        case Customer
        case Data
        case Order
        
        init(){
            self = NewProduct
        }
        
        var title : String{
            switch self{
            case NewProduct:
                return "新品发布"
            case Exchange:
                return "我要转卖"
            case Goods:
                return "采购管理"
            case Order:
                return "销售管理"
            case Financia:
                return "财富中心"
            case Data:
                return "数据中心"
            case OfferCenter:
                return "报价中心"
            case Customer:
                return "客户管理"
            }
        }
        
        var image : UIImage?{
            switch self{
            case NewProduct:
                return UIImage(named: "MineHome_NewProduct")
            case Exchange:
                return UIImage(named: "MineHome_Exchange")
            case Goods:
                return UIImage(named: "MineHome_GoodsManagement")
            case OfferCenter:
                return UIImage(named: "MineHome_OfferCenter")
            case Financia:
                return UIImage(named: "MineHome_FinancialManagement")
            case Customer:
                return UIImage(named: "MineHome_CustomerManagement")
            case Data:
                return UIImage(named: "MineHome_DataCenter")
            case Order:
                return UIImage(named: "MineHome_OrderManagement")
            }
        }
        
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case NewProduct:
                viewController = UIViewController()
            case Exchange:
                viewController = UIViewController()
            case Goods:
                viewController = UIViewController()
            case OfferCenter:
                viewController = UIViewController()
            case Financia:
                viewController = UIViewController()
            case Customer:
                viewController = UIViewController()
            case Data:
                viewController = UIViewController()
            case Order:
                viewController = UIViewController()
            }
            viewController.hidesBottomBarWhenPushed = true
            return viewController
        }
        
        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(self.pushViewController, animated: true)
        }
    }

    @IBOutlet weak var currentTableView: UITableView!
    var navView : UIView!
    var headerV : UIView!
    
    var cellWidth : CGFloat!
    var userCenterData: [UserCenterCellType]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.setupNewNavigation()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navView.removePop()
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
        return 3
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 200 : 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section > 0 ? 1 : 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.configHead()
        return self.headerV
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? kScreenWidth/3 * 2 : 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "topCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                for var i = 0 ; i < self.userCenterData.count ; i++ {
                    let userCenterCellType = self.userCenterData[i]
                    let x = kScreenWidth/3 * CGFloat(i % 3)
                    let y = CGFloat(i / 3) * kScreenWidth/3
                    let btn = ZMDTool.getBtn(CGRectMake(x, y, kScreenWidth/3, kScreenWidth/3))
                    btn.backgroundColor = UIColor.clearColor()
                    btn.setTitle(userCenterCellType.title, forState: .Normal)
                    btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    btn.setImage(userCenterCellType.image, forState:.Normal)
                    cell!.addSubview(btn)
                    ZMDTool.configViewLayerFrame(btn)
                }
            }
            return cell!
        } else {
            let cellId = "bottomCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = indexPath.section == 1 ? "我的关注" : "商品评价"
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
    }
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //uitableview处理section的headView不悬浮
        let sectionHeaderHeight : CGFloat = 200
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0{
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }else if scrollView.contentOffset.y >= sectionHeaderHeight{
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
    }

    //MARK:Private Method
    func setupNewNavigation() {
        let getBtn = { (frame:CGRect) -> UIButton in
            let btn = UIButton(frame: frame)
            btn.backgroundColor = UIColor.clearColor()
            btn.layer.opacity = 0.5
            ZMDTool.configViewLayerRound(btn)
            return btn
        }
        let navView = UIView(frame: CGRectMake(0 , 20, kScreenWidth, 44))
        navView.backgroundColor = UIColor.clearColor()
        let setBtn = getBtn(CGRectMake(12 , 8, 28, 28))
        let msnBtn = getBtn(CGRectMake(kScreenWidth - 40 , 8, 28, 28))
        
        setBtn.setImage(UIImage(named: "Mine_Set"), forState:.Normal)
        msnBtn.setImage(UIImage(named: "Navi_Msg"), forState:.Normal)

        navView.addSubview(setBtn)
        navView.addSubview(msnBtn)
        navView.showAsPop(setBgColor: false)
        self.navView = navView
        
        setBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            self.navigationController?.pushViewController(MineHomeSetViewController(), animated: true)
        }
        msnBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    func configHead() {
        let nibView = NSBundle.mainBundle().loadNibNamed("MineHomeHeadView", owner: nil, options: nil) as NSArray
        self.headerV = nibView.objectAtIndex(0) as? UIView
        self.headerV.frame.size = CGSizeMake(kScreenWidth, 200)
        
        if let personImgV = self.headerV.viewWithTag(10001) {
            personImgV.layer.cornerRadius = 43
            personImgV.layer.masksToBounds = true
        }
    }
    func updateUI() {
       
    }
    private func dataInit(){
        self.userCenterData = [UserCenterCellType.NewProduct,UserCenterCellType.Exchange,UserCenterCellType.Goods, UserCenterCellType.Order, UserCenterCellType.Financia, UserCenterCellType.Data]
    }
}