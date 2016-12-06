//
//  ConfirmOrderViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 确认订单
class ConfirmOrderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    
    enum UserCenterCellType{
        case AddressSelect
        case DSAddressSelect    //网点选择
        case AddressSelectDid
        
        case Store
        case Goods
        case Discount
        case freight
        case Mark
        case GoodsCount
        
        case Invoice
        case InvoiceType
        case InvoiceDetail
        case InvoiceFor
        
        case UseDiscount
        init(){
            self = AddressSelect
        }
        
        var title : String{
            switch self{
            case Discount:
                return "店铺优惠:"
            case freight:
                return "运费:"
            case Mark:
                return "备注:"
            case GoodsCount:
                return "共一件商品"

            case Invoice:
                return "是否开具发票"
            case InvoiceType:
                return "发票类型:"
            case InvoiceDetail:
                return "发票明细:"
            case InvoiceFor:
                return "发票抬头:"
                
            case UseDiscount:
                return "使用优惠券"
            default :
                return ""
            }
        }
        //
        //        var pushViewController :UIViewController{
        //            let viewController: UIViewController
        //            switch self{
        //            case UserMyOrder:
        //                viewController = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
        //            case UserMyOrderMenu:
        //                viewController = UIViewController()
        //            case UserWallet:
        //                viewController = UIViewController()
        //            case UserBankCard:
        //                viewController = UIViewController()
        //            case UserCardVolume:
        //                viewController = UIViewController()
        //            case UserMyCrowdFunding:
        //                viewController = UIViewController()
        //
        //            case UserMyStore:
        //                viewController = UIViewController()
        //            case UserVipClub:
        //                viewController = UIViewController()
        //            case UserCommission:
        //                viewController = UIViewController()
        //            case UserInvitation:
        //                viewController = UIViewController()
        //
        //            case UserHelp:
        //                viewController = UIViewController()
        //            default :
        //                viewController = UIViewController()
        //            }
        //            viewController.hidesBottomBarWhenPushed = true
        //            return viewController
        //        }
        //
        //        func didSelect(navViewController:UINavigationController){
        //            navViewController.pushViewController(pushViewController, animated: true)
        //        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var markTF : UITextField!
    var payLbl : UILabel!          //实付label
    var shippingLbl : UILabel!      //运费label
    var totalLbl : UILabel!
    var userCenterData: [[UserCenterCellType]]!
    var tableCellType:[UserCenterCellType]!
    var scis : NSArray!
    var publicInfo : NSDictionary?
    var total = ""
    var orderTotal:ZMDOrderTotal!
    var shipping = 0.00    //运费
    
    var isToHome = true
    var didChoseAddress = false     //记录是否选择收货地址
        override func viewDidLoad() {
        super.viewDidLoad()
        self.setDefaultAddress()
        self.dataInit()
        self.getTotal()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellType = self.userCenterData[section][0]
        if cellType == .Goods {
            return self.scis.count
        }
        return self.userCenterData[section].count
//        if section == 0 {
//            return 1
//        }else{
//            return 7
//        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
//        return self.scis.count + 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.userCenterData[indexPath.section][0] == .Goods {
            return 110
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .AddressSelect :
            return 80
        case .DSAddressSelect :
            return 40
        case .Store:
            return 48
        default :
            return 56
        }
//        if indexPath.section != 0 && indexPath.row == 1 {
//            return 110
//        }else{
//            return 56
//        }
    }
    
    /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "AddressSelectCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = .DisclosureIndicator
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.imageView?.image = UIImage(named: "pay_select_adress")
                let numLbl = ZMDTool.getLabel(CGRect(x: 44, y: 0, width: 300, height: 55), text: "选择收货地址", fontSize: 17)
                numLbl.tag = 1000
                cell?.contentView.addSubview(numLbl)
            }
            return cell!
        } else {
            if indexPath.row == 0 {
                //店家
                let cellId = "StoreCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
                return cell!
            }else if indexPath.row == 1 {//后面应该为0 < indexPath.row < self.某个goodsArr.count
                //商品cell
                let cellId = "GoodsCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
                let item = self.scis[indexPath.row] as! ZMDShoppingItem
                cell.configCellForConfig(item)
                return cell
            }else if indexPath.row == 2 {
                //使用优惠券
                let cellId = "UseDiscountCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
        
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 32 - 150, y: 0, width: 150, height: 55.5), text: "可使用优惠券：0张", fontSize: 17,textColor: defaultDetailTextColor)
                    cell?.contentView.addSubview(label)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                }
                cell!.textLabel?.text = "使用优惠券"
                return cell!
            }else if indexPath.row == 3 {
                //运费
                let cellId = "freightCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    cell?.textLabel?.text = "运费:"
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth-60, y: 0, width: 50, height: 55.5), text: "¥30.0", fontSize: 17)
                    label.textAlignment = .Right
                    label.textColor = defaultDetailTextColor
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    cell?.contentView.addSubview(label)
                }
                return cell!
            }else if indexPath.row == 4 {
                //是否开发票
                let cellId = "InvoiceCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    
                    cell!.textLabel?.text = "是否开发票"
                    let label = ZMDTool.getLabel(CGRect(x:kScreenWidth - 32 - 20 - 150, y: 0, width: 150 + 20, height: 56), text: "未选择", fontSize: 15)
                    label.tag = 1000
                    label.textAlignment = .Right
                    cell?.contentView.addSubview(label)

                    label.textColor = defaultDetailTextColor
                }                
                return cell!
            }else if indexPath.row == 5 {
                //备注
                let cellId = "MarkCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let textField = UITextField(frame: CGRect(x: 64, y: 0, width: kScreenWidth - 64 - 12, height: 55))
                    textField.textColor = defaultDetailTextColor
                    textField.font = defaultSysFontWithSize(17)
                    textField.tag = 10001
                    textField.placeholder = "给商家留言"
                    cell?.contentView.addSubview(textField)
                    
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    cell!.textLabel?.text = "备注"
                }
                return cell!
            }else if indexPath.row == 6 {
                //合计
                let cellId = "GoodsCountCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "", fontSize: 17)
                    label.attributedText = "合计 : ￥\(self.total)".AttributedText("￥\(self.total)", color: RGB(235,61,61,1.0))
                    label.textAlignment = .Right
                    cell?.contentView.addSubview(label)
                    self.totalLbl = label
                }
                cell!.textLabel?.text = "共\(self.scis.count)件商品"
                // ******* cell?.textLabel?.text = "共\(self.某个分区goodsArr.count)件商品"
                return cell!
            }
        }
        return UITableViewCell(style: .Default, reuseIdentifier: "cell")
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.userCenterData[indexPath.section][0] == .Goods {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            let item = self.scis[indexPath.row] as! ZMDShoppingItem
            cell.configCellForConfig(item)
            return cell
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .AddressSelect:
            let cellId = "AddressSelectCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.imageView?.image = UIImage(named: "pay_select_adress")
                let numLbl = ZMDTool.getLabel(CGRect(x: 44, y: 0, width: 300, height: 80), text: "选择收货地址", fontSize: 17)
                numLbl.tag = 1000
                cell?.contentView.addSubview(numLbl)
                
                let numLbl2 = ZMDTool.getLabel(CGRect(x: 44, y: 10, width: 300, height: 20), text: "", fontSize: 18)
                numLbl2.tag = 1001
                numLbl2.alpha = 0
                cell?.contentView.addSubview(numLbl2)
                
                let addressLbl = ZMDTool.getLabel(CGRect(x: 44, y: 30, width: kScreenWidth-44-30, height: 50), text: "", fontSize: 17)
                addressLbl.numberOfLines = 0
                addressLbl.tag = 1002
                addressLbl.alpha = 0
                cell?.contentView.addSubview(addressLbl)
            }
            return cell!
        case .DSAddressSelect:
            let cellId = "DSAddressSelectCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = .DisclosureIndicator
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: kScreenWidth, height: 1), backgroundColor: defaultLineColor))
            }
            cell?.textLabel?.text = "网点代收"
            return cell!
        case .Store :
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            return cell!
        case .Discount :
            let cellId = "DiscountCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell!.textLabel?.text = cellType.title
            let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "无", fontSize: 17)
            label.textAlignment = .Right
            cell?.contentView.addSubview(label)
            return cell!
        case .Mark :
            let cellId = "MarkCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                
            }
            cell!.textLabel?.text = cellType.title
            if self.markTF == nil {
                let textField = UITextField(frame: CGRect(x: 64, y: 0, width: kScreenWidth - 64 - 12, height: 55))
                textField.textColor = defaultDetailTextColor
                textField.font = defaultSysFontWithSize(17)
                textField.tag = 10001
                textField.placeholder = "给商家留言"
                cell?.contentView.addSubview(textField)
                self.markTF = textField
            }
            return cell!
        case .freight :
            let cellId = "freightCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.textLabel?.text = "运费:"
                let lbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-12-80, y: 12, width: 80, height: 32), text: "", fontSize: 17)
                lbl.textColor = defaultTextColor
                lbl.text = ""
                lbl.textAlignment = .Right
                lbl.tag = 1000
                cell?.contentView.addSubview(lbl)
            }
            
            //getToal有运费数据时更新
            if let shipping = self.orderTotal?.Shipping {
                (cell?.contentView.viewWithTag(1000) as!UILabel).text = shipping
            }
            return cell!
        case .GoodsCount :
            let cellId = "GoodsCountCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "合计 : ¥0.0", fontSize: 17)
                label.tag = 10000
                label.attributedText = "合计 : ￥0.0".AttributedText("￥0.0", color: RGB(235,61,61,1.0))
                label.textAlignment = .Right
                cell?.contentView.addSubview(label)
            }
            //计算商品件数
            var count : Int = 0,money = 0.00
            for item in self.scis {
                count += (item as! ZMDShoppingItem).Quantity.integerValue
                let str = (item as! ZMDShoppingItem).UnitPrice.componentsSeparatedByString("¥").last
                let price = (str!.stringByReplacingOccurrencesOfString(",", withString: "") as NSString).doubleValue
                money += price * (item as! ZMDShoppingItem).Quantity.doubleValue
            }
            cell!.textLabel?.text = "共\(count)件商品"
            (cell?.contentView.viewWithTag(10000) as! UILabel).attributedText = "合计 : \(money)".AttributedText("\(money)", color: RGB(235,61,61,1.0))

            return cell!
        case .Invoice :
            let cellId = "InvoiceCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell!.textLabel?.text = cellType.title
            return cell!
       
        case .InvoiceType :
            let cellId = "InvoiceTypeCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
        
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "", fontSize: 17,textColor: defaultDetailTextColor)
                label.text = "不开发票"
                label.textAlignment = .Right
                label.tag = 10000 + indexPath.section*10 + indexPath.row
                cell?.contentView.addSubview(label)
            }
            cell!.textLabel?.text = cellType.title
            if let category = self.publicInfo?["Category"] as? String {
                let lbl = cell?.viewWithTag(10000 + indexPath.section*10 + indexPath.row) as! UILabel
                lbl.text = category
            }
            return cell!
        case .InvoiceDetail :
            let cellId = "InvoiceDetailCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "", fontSize: 17,textColor: defaultDetailTextColor)
                label.text = "不开发票"
                label.textAlignment = .Right
                label.tag = 10000 + indexPath.section*10 + indexPath.row
                cell?.contentView.addSubview(label)
            }
            cell!.textLabel?.text = cellType.title
            if let body = self.publicInfo?["Body"] as? String {
                let lbl = cell?.viewWithTag(10000 + indexPath.section*10 + indexPath.row) as! UILabel
                lbl.text = body
            }
            return cell!
        case .InvoiceFor :
            let cellId = "InvoiceForCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "", fontSize: 17,textColor: defaultDetailTextColor)
                label.textAlignment = .Right
                label.tag = 10000 + indexPath.section*10 + indexPath.row
                cell?.contentView.addSubview(label)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell!.textLabel?.text = cellType.title
            if let body = self.publicInfo?["HeadTitle"] as? String {
                let lbl = cell?.viewWithTag(10000 + indexPath.section*10 + indexPath.row) as! UILabel
                lbl.text = body
            }
            return cell!
        case .UseDiscount :
            let cellId = "UseDiscountCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 32 - 150, y: 0, width: 150, height: 55.5), text: "可使用优惠券：0张", fontSize: 17,textColor: defaultDetailTextColor)
                cell?.contentView.addSubview(label)
                
                let line = ZMDTool.getLine(CGRect(x: 0, y: 55, width: kScreenWidth, height: 1))
                cell?.contentView.addSubview(line)
            }
            cell!.textLabel?.text = cellType.title
            return cell!
        case .AddressSelectDid:
            let cellId = "AddressDidCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.imageView?.image = UIImage(named: "pay_select_adress")
                cell?.textLabel?.text = "选择收货地址"
                cell?.detailTextLabel?.text = ""
            }
            return cell!
        default :
            let cellId = "OtherCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell!.textLabel?.text = cellType.title
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = indexPath.section == 1 ? .Goods : self.userCenterData[indexPath.section][indexPath.row]
        switch cellType{
        case .Goods:
            let homeBuyGoodsDetailViewController = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            let item = self.scis[indexPath.row] as! ZMDShoppingItem
            homeBuyGoodsDetailViewController.productId = item.ProductId.integerValue
            self.navigationController?.pushViewController(homeBuyGoodsDetailViewController, animated: true)
            break
        case .Invoice://发票
            let vc = InvoiceTypeViewController()
            if self.publicInfo != nil {
                vc.invoiceFinish = self.publicInfo
            }
            vc.finished = {(dic)->Void in
                self.publicInfo = dic
                self.currentTableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None)
            }
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .AddressSelect :
            //选择上门地址
            let vc = AddressViewController2.CreateFromMainStoryboard() as! AddressViewController2
            vc.finished = { (address:ZMDAddress) -> Void in
                ZMDTool.showActivityView(nil)
                //选择上门地址
                QNNetworkTool.selectShoppingAddress((address.Id?.integerValue)!, completion: { (succeed, dictionary, error) -> Void in
                    ZMDTool.hiddenActivityView()
                    if succeed! {
                        ZMDTool.showPromptView("选择送货上门地址成功")
                        //选择地址成功后，回来时将选择的地址显示出来
                        let titles = ["","收件人: " + "\(address.FirstName)" + "  " + "\(address.PhoneNumber)","收货地址:\(address.Address1!)"+address.Address2!]
                        var tag = 1000
                        for title in titles {
                            let label = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(tag++) as!UILabel
                            label.text = title
                            label.alpha = title == "" ? 0 : 1
                        }
                        self.didChoseAddress = true
                        self.getTotal()
                        self.currentTableView.reloadData()
                    }else{
                        if let message = dictionary?["message"] as? String {
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: message)
                        }else{
                            ZMDTool.showPromptView("选择送货上门地址失败")
                        }
                        let titles = ["选择收货地址","",""]
                        var tag = 1000
                        for title in titles {
                            let label = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(tag++) as! UILabel
                            label.text = title
                            label.alpha = title == "" ? 0 : 1
                        }
                        self.didChoseAddress = false
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .DSAddressSelect:
            //MARK:选择网点地址
            if !self.didChoseAddress {
                ZMDTool.showPromptView("请先选择收货地址")
                return
            }
            let vc = DSAddressViewController.CreateFromMainStoryboard() as! DSAddressViewController
            vc.finished = {(address:ZMDDSAddress)->Void in
                ZMDTool.showActivityView(nil)
                //选择代收地址
                QNNetworkTool.selectDaiShouAddress(address.Id.integerValue, completion: { (success, error, dictionary) -> Void in
                    ZMDTool.hiddenActivityView()
                    if success! {
                        ZMDTool.showPromptView("选择网点代收地址成功")
                        //选择地址成功后，回来时将选择的地址显示出来
                        let titles = ["","代收人: " + "\(address.Name)" + "  " + "\(address.Phone)","网点地址: \(address.Address1!)"]
                        var tag = 1000
                        for title in titles {
                            let label = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(tag++) as!UILabel
                            label.text = title
                            label.alpha = title == "" ? 0 : 1
                        }
                        self.isToHome = false
                        self.didChoseAddress = true
                        self.currentTableView.reloadData()
                    }else{
                        ZMDTool.showPromptView("选择网点代收地址失败")
                        let titles = ["选择收货地址","",""]
                        var tag = 1000
                        for title in titles {
                            let label = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(tag++) as! UILabel
                            label.text = title
                            label.alpha = title == "" ? 0 : 1
                        }
                        self.isToHome = false
                    }
                })
            }
            pushToVC(vc, animated: true, hideBottom: true)
            break
        case .UseDiscount:
            let vc = DiscountCardViewController()
            vc.finished = {(couponcode)->Void in
                QNNetworkTool.useDiscountCoupo(couponcode, completion: { (succeed, dictionary, error) -> Void in
                    if !succeed! {
                       ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
                    } else {
                        self.getTotal()
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .AddressSelectDid:
            break
        default:
            break
        }
    }
    
    
    
    
    //MARK:Private Method
    
    private func setDefaultAddress() {
        QNNetworkTool.fetchAddresses { (addresses, error, dictionary) in
            if let addresses = addresses {
                var index = 0
                for ;index<addresses.count;index++ {
                    let address = addresses[index] as! ZMDAddress
                    if address.IsDefault == true {
                        self.choseDefaultAddress(address)
                        break
                    }
                }
            }
        }
    }
    
    func choseDefaultAddress(address:ZMDAddress) -> Void {
        let id = address.Id.integerValue
        QNNetworkTool.selectShoppingAddress(id) { (succeed, dictionary, error) in
            if succeed == true {
                //选择默认地址成功，设置addressCell
                let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                let titles = ["","收件人: " + "\(address.FirstName)" + "  " + "\(address.PhoneNumber)","收货地址:\(address.Address1!)"]
                var tag = 1000
                for title in titles {
                    let label = cell?.viewWithTag(tag++) as!UILabel
                    label.text = title
                    label.alpha = title == "" ? 0 : 1
                }
                self.didChoseAddress = true
                //                self.userCenterData = [[.AddressSelect],[.Goods],[.GoodsCount,.freight,.Mark],[.Invoice,.InvoiceType,.InvoiceDetail,.InvoiceFor],[.UseDiscount]]
                self.getTotal()
            }
        }
    }
    
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 64 - 58, width: kScreenWidth, height: 58))
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        
        view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5), backgroundColor: defaultLineColor))
        let size = "提价订单".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 200)
        let confirmBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - size.width - 20, y: 12, width: size.width+20, height: 34), textForNormal: "提交订单", fontSize: 15,textColorForNormal:UIColor.whiteColor(), backgroundColor:RGB(235,61,61,1.0)) { (sender) -> Void in
            self.view.endEditing(true)
            if self.didChoseAddress == true {
                //获取支付方式
                self.fetchPayMethods()
            }else{
                ZMDTool.showPromptView("请选择收货地址")
            }
        }
        
        ZMDTool.configViewLayerWithSize(confirmBtn, size: 15)
        view.addSubview(confirmBtn)
        
        self.payLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12, width: 200, height: 15), text: "实付:¥\(self.total)", fontSize: 16,textColor: defaultTextColor)
        self.payLbl.attributedText = self.payLbl.text?.AttributedText("¥\(self.total)", color: defaultSelectColor)
        view.addSubview(payLbl)
        
        self.shippingLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12 + 15 + 7, width: 200, height: 12), text: "", fontSize: 15,textColor: defaultTextColor)
        view.addSubview(self.shippingLbl)

        
        /*let jifengLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12 + 15 + 7, width: 200, height: 12), text: "可获得20积分", fontSize: 12,textColor: defaultDetailTextColor)
        jifengLbl.text = "积分功能暂未开放"
        view.addSubview(jifengLbl)*/
    }
    
    private func dataInit(){
        self.userCenterData = [[.AddressSelect,.DSAddressSelect],[.Goods],[.GoodsCount,.Mark], [.Invoice,.InvoiceType,.InvoiceDetail,.InvoiceFor],[.UseDiscount]]
    }
    //获取本订单的各种金额(商品金额、运费)
    func getTotal() {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.getOrderTotals { (total, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if total != nil {
                self.orderTotal = total
                if let _ = self.orderTotal.OrderTotal,_ = self.orderTotal.Shipping {
                    self.payLbl.text = "实付:" + self.orderTotal.OrderTotal ?? "¥\(self.total)"
                    self.payLbl.attributedText = self.payLbl.text?.AttributedText(self.orderTotal.OrderTotal ?? "¥\(self.total)", color: defaultSelectColor)
                    
                    self.shippingLbl.text = "含运费: " + self.orderTotal.Shipping ?? "¥0.00"
                    self.shippingLbl.attributedText = self.shippingLbl.text?.AttributedText(self.orderTotal.Shipping ?? "¥0.00", color: defaultSelectColor)
                }
                /*self.payLbl.text = "实付:" + (self.orderTotal.OrderTotal ?? "¥\(self.total)") + shipText
                self.payLbl.attributedText = self.payLbl.text?.AttributeText([self.orderTotal.OrderTotal ?? "¥\(self.total)",shipText], colors: [defaultSelectColor,defaultTextColor], textSizes: [16,15])*/
                
                if self.didChoseAddress == true {
                    //如果选择了地址，则可以计算运费，更改tableView类型
                    self.userCenterData = [[.AddressSelect,.DSAddressSelect],[.Goods],[.freight,.GoodsCount,.Mark], [.Invoice,.InvoiceType,.InvoiceDetail,.InvoiceFor],[.UseDiscount]]
                }
                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
            }
        }
    }
    
    func fetchPayMethods() {
        ZMDTool.showActivityView(nil)
            QNNetworkTool.fetchPaymentMethod { (paymentMethods, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if paymentMethods != nil {
                var mark = ""
                if self.markTF != nil {
                    mark = self.markTF!.text!
                }
                let vc = CashierViewController()
                vc.mark = mark
                vc.total = self.total
                vc.payMethods = NSMutableArray(array: paymentMethods)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

