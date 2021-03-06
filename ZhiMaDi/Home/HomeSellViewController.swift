//
//  HomeSellViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/3.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我要卖
let TextColorPlaceholder = UIColor(red: 113/255, green: 113/255, blue: 113/255, alpha: 1.0)
class HomeSellViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMsnProtocol {
    enum UserCenterCellType{
        case Name
        case Specs
        case Location
        case Detail
        case Time
        case Area
        case Output
        case CanSell
        case Photo
        case Save
        init(){
            self = Name
        }
        
        var title : String{
            switch self{
            case Name:
                return "产品名称 ："
            case Specs:
                return "产品规格 ："
            case Location :
                return "货物所在地 ："
            case Detail:
                return "详细地址 ："
            case Time:
                return "预计发货时间 ："
            case Area:
                return "种植面积 ："
            case Output:
                return "预计总产量 ："
            case CanSell:
                return "可售卖量 ："
            case .Photo:
                return "上传照片"
            case .Save:
                return "保存并申请发布"
            }
        }
        
//        
//        var pushViewController :UIViewController{
//            let viewController: UIViewController
//            switch self{
//            case Name:
//                viewController = UIViewController()
//            case Specs:
//                viewController = SignPSSetViewController.CreateFromMainStoryboard() as! SignPSSetViewController
//            case Location :
//                viewController = PhoneSetViewController.CreateFromMainStoryboard() as! PhoneSetViewController
//            case Detail:
//                viewController = UIViewController()
//            case Time:
//                viewController = UIViewController()
//            case Area:
//                viewController = RealAuthenticationViewController.CreateFromMainStoryboard() as! RealAuthenticationViewController
//            case Output:
//                viewController = RealAuthenticationViewController.CreateFromMainStoryboard() as! RealAuthenticationViewController
//            case CanSell:
//                viewController = RealAuthenticationViewController.CreateFromMainStoryboard() as! RealAuthenticationViewController
//            }
//            viewController.hidesBottomBarWhenPushed = true
//            return viewController
//        }
//        
        func didSelect(navViewController:UINavigationController){
//           navViewController.pushViewController(self.pushViewController, animated: true)
        }
    }

    let getTextField = { (enable : Bool!,placeholder : String!) -> UITextField in
        let width = enable! ? kScreenWidth - 152 : kScreenWidth - 170
        let textField = UITextField(frame: CGRectMake(140, 0, width, 50))
        textField.textColor = UIColor.blackColor()
        textField.font = UIFont.systemFontOfSize(15)
        textField.textAlignment = .Left
        textField.enabled = enable
        textField.placeholder = placeholder
        return textField
    }
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var sellBtn: UIButton!
    @IBOutlet weak var releasebtn: UIButton!
    @IBOutlet weak var btnView: UIView!
    
    var nameTextField : UITextField!
    var specsTextField : UITextField!
    var locationTextField : UITextField!
    var detailTextField : UITextField!
    var timeTextField : UITextField!
    var areaTextField : UITextField!
    var outputTextField : UITextField!
    var canSellTextField : UITextField!

    var userCenterData : [[UserCenterCellType]]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sellBtn.selected {
            return 4
        } else {
            return userCenterData[section].count
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sellBtn.selected ?    1 : userCenterData.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !self.sellBtn.selected {
            let type = self.userCenterData[indexPath.section][indexPath.row]
            if type == .Photo {
                return 150
            } else if type == .Save {
                return 80
            }
            return 50
        } else {
            return 198
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.sellBtn.selected {
            let cellId = "goodsCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            return cell!
        } else {
            //照片 跟 保存 单独成一个cell  --结构不一样
            let type = self.userCenterData[indexPath.section][indexPath.row]
            if type == .Photo {
                let cellId = "photoCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                return cell!
            } else if type == .Save {
                let cellId = "saveCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                let btn = cell?.viewWithTag(10001) as! UIButton
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    let vc = ReleaseGoodsViewController.CreateFromMainStoryboard() as! ReleaseGoodsViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                return cell!
            }
            let cellId = "cell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = type.title
            switch type {
            case .Name :
                self.nameTextField = getTextField(false,"请选择产品")
                cell?.addSubview(self.nameTextField)
            case .Specs :
                self.specsTextField = getTextField(false,"请选择规格")
                cell?.addSubview(self.specsTextField)
            case .Location :
                self.locationTextField = getTextField(false,"请选择省、市、县")
                cell?.addSubview(self.locationTextField)
            case .Detail :
                cell?.accessoryType = .None
                self.detailTextField = getTextField(true,"请填写详细地址（非必填）")
                cell?.addSubview(self.detailTextField)
            case .Time :
                self.timeTextField = getTextField(false,"请选择时间")
                cell?.addSubview(self.timeTextField)
            case .Area :
                cell?.accessoryType = .None
                self.detailTextField = getTextField(true,"请填写种植面积，如：“50亩”")
                cell?.addSubview(self.detailTextField)
            case .Output :
                cell?.accessoryType = .None
                self.outputTextField = getTextField(true,"请填写预计总产值，如：“26吨”")
                cell?.addSubview(self.outputTextField)
            case .CanSell :
                cell?.accessoryType = .None
                self.canSellTextField = getTextField(true,"请填写可售卖量，如：“25吨”")
                cell?.addSubview(self.canSellTextField)
            default :
                break
            }
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
    }
    //MARK: - Actions
    @IBAction func sellBtnCli(sender: UIButton) {
        self.sellBtn.selected = !self.sellBtn.selected
        self.releasebtn.selected = !self.releasebtn.selected
        self.currentTableView.reloadData()
    }
    @IBAction func releaseBtnCli(sender: UIButton) {
        self.releasebtn.selected = !self.releasebtn.selected
        self.sellBtn.selected = !self.sellBtn.selected
        self.currentTableView.reloadData()
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        let color = UIColor(red: 237/255, green: 191/255, blue: 28/255, alpha: 1.0)
        self.sellBtn.setBackgroundImage(UIImage.colorImage(color, size: self.releasebtn.bounds.size), forState: .Selected)
        self.releasebtn.setBackgroundImage(UIImage.colorImage(color, size: self.releasebtn.bounds.size), forState: .Selected)
        self.sellBtn.selected = true
        self.btnView.layer.borderWidth = 0.5
        self.btnView.layer.borderColor = color.CGColor
        ZMDTool.configViewLayer(self.btnView)
    }
    private func dataInit(){
        self.userCenterData = [[UserCenterCellType.Name,UserCenterCellType.Specs,UserCenterCellType.Location, UserCenterCellType.Detail, UserCenterCellType.Time], [UserCenterCellType.Area,UserCenterCellType.Output,UserCenterCellType.CanSell,UserCenterCellType.Photo],[UserCenterCellType.Save]]
    }
}
