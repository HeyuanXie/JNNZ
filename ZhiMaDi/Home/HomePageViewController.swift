
//
//  HomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/19.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//首页
class HomePageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,CycleScrollViewDelegate,ZMDInterceptorProtocol,UITextFieldDelegate {
    //首页section的枚举
    enum UserCenterCellType{
        case HomeContentTypeHead                     /* 头部选项 */
        case HomeContentTypeAd                      /* 广告显示页 */
        case HomeContentTypeMenu                    /* 菜单选择栏目 */
        case HomeContentTypeGoods                   /* 商品栏目 */
        case HomeContentTypeRecommendationHead      /* 推荐商品 Head*/
        case HomeContentTypeRecommendation          /* 推荐商品 */
        case HomeContentTypeTheme                   /* 特卖 主题展示 */
        
        case HomeContentTypeMulity
        
        case HomeContentTypeNongYongWuZi            //农用物资
        case HomeContentTypeShengHuoYingPing        //生活用品
        case HomeContentTypeDaJiaDian               //大家电
        
        init(){
            self = HomeContentTypeHead
        }
        
        var heightForHeadOfSection : CGFloat {
            switch  self {
            case .HomeContentTypeHead :
                return 0
            case .HomeContentTypeAd :
                return 0
            case .HomeContentTypeMenu :
                return 4
            case .HomeContentTypeGoods :
                return 2
            case .HomeContentTypeRecommendationHead:
                return 12
            case .HomeContentTypeRecommendation :
                return 0
            case .HomeContentTypeTheme :
//                return 16
                return 30
            case HomeContentTypeMulity :
                return 12
            case HomeContentTypeNongYongWuZi :
                return 12
            case HomeContentTypeShengHuoYingPing :
                return 12
            case HomeContentTypeDaJiaDian :
                return 12
            }
        }
        
        var height : CGFloat {
            switch  self {
            case .HomeContentTypeHead :
                return 44
            case .HomeContentTypeAd :
                return kScreenWidth * 280 / 750
            case .HomeContentTypeMenu :
                return 2*kScreenWidth * 210 / 750 / kScreenHeightZoom
            case .HomeContentTypeGoods :
                return kScreenWidth * 430 / 750
            case .HomeContentTypeRecommendationHead:
                return 40
            case .HomeContentTypeRecommendation :
                return 202
            case .HomeContentTypeTheme :
                return 9 + 21 + 6 + 10 + 13 + (kScreenWidth-12*2)*23/57 + 8
            default :
                return 0
            }
        }
    }
    
    //菜单选择类型枚举
    enum MenuType {
        case kKSNongTe
        case kDaZongJiaoYi
        case kTuanGou
        case kLingQuan
        case kGongQiu
        case kJiaDianXiaXiang
        case kKSGongYi
        case kNongCunJinRong
        case kBianMinFuWu
        case kFuWuZhan
        
        init(){
            self = kKSNongTe
        }
        
        //菜单选择名称枚举
        var title : String{
            switch self{
                
            case kKSNongTe:
                return "喀什农特"
            case kDaZongJiaoYi:
                return "大宗交易"
            case kTuanGou:
                return "团购"
            case kLingQuan:
                return "领券"
            case .kGongQiu:
                return "供求"
            case .kJiaDianXiaXiang:
                return "家电下乡"
            case .kKSGongYi:
                return "喀什公益"
            case .kNongCunJinRong:
                return "农村金融"
            case .kBianMinFuWu:
                return "便民服务"
            case .kFuWuZhan:
                return "服务站"
            }
        }
        
        //菜单选择图片枚举
        var image : UIImage?{
            switch self{
                
            case kKSNongTe:
                return UIImage(named: "01")
            case kDaZongJiaoYi:
                return UIImage(named: "02")
            case kTuanGou:
                return UIImage(named: "03")
            case kLingQuan:
                return UIImage(named: "04")
            case .kGongQiu:
                return UIImage(named: "05")
            case .kJiaDianXiaXiang:
                return UIImage(named: "06")
            case .kKSGongYi:
                return UIImage(named: "07")
            case .kNongCunJinRong:
                return UIImage(named: "08")
            case .kBianMinFuWu:
                return UIImage(named: "09")
            case .kFuWuZhan:
                return UIImage(named: "10")
            }
        }
        
        //点击菜单选择，跳转目标VC的枚举
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case .kKSNongTe:
                viewController = UIViewController()
            default :
                viewController = UIViewController()
            }
            return viewController
        } 
        
        //点击菜单选择，调用方法跳转
        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(self.pushViewController, animated: true)
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    
    var userCenterData: [UserCenterCellType]!
    var menuType: [MenuType]!
    var 下拉视窗 : UIView!
    var categories = NSMutableArray()
    var advertisementAll : ZMDAdvertisementAll!
    var dyadicProducts  = NSMutableArray()  //二维数组,存放分类对应的产品数组
    var widgetNames = NSMutableArray()      //广告名数组
    var miniAds = NSMutableArray()
    
    var requestDataNumber = 0       //记录fetchCategories的次数
    
    //MARK: - ****************LifeCircle******************
    override func viewDidLoad() {
        super.viewDidLoad()
        // 让导航栏支持右滑返回功能
        ZMDTool.addInteractive(self.navigationController)
        self.updateUI()
        self.dataInit()
        self.fetchData()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController!.tabBar.hidden = false
        self.setupNewNavigation()
        //检测版本更新
        if APP_HOMEPAGELAUNCHTIMES == 1 {
//            self.checkUpdate()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        APP_HOMEPAGELAUNCHTIMES++
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section > 1 {
            return 4
        }
        switch self.userCenterData[section] {
        case .HomeContentTypeMulity:
            return 4
        default :
            return 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.userCenterData.count
        return 2 + self.categories.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 1 {
            return 12
        }
        return self.userCenterData[section].heightForHeadOfSection
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        if section > 1 {
            return headView
        }
        //如果为特卖专题，自定义headerView
        let cellType = self.userCenterData[section]
        if cellType == .HomeContentTypeTheme{
            headView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 30)
            let redView = UIView(frame: CGRect(x: 12, y: 0, width: 8, height: 15))
            redView.backgroundColor = UIColor.redColor()
            redView.center.y = headView.center.y
            let titleLabel = ZMDTool.getLabel(CGRect(x: CGRectGetMaxX(redView.frame)+10, y: 0, width: 90, height: 15), text: "特卖专场", fontSize: 15)
            titleLabel.textAlignment = .Left
            titleLabel.center.y = headView.center.y
            titleLabel.textColor = RGB(79,79,79,1.0)
            let line = ZMDTool.getLine(CGRect(x: 12, y: headView.frame.height-1, width: kScreenWidth-2*12, height: 1), backgroundColor: defaultGrayColor)
            headView.addSubview(redView)
            headView.addSubview(titleLabel)
            headView.addSubview(line)
            headView.backgroundColor = UIColor.whiteColor()
        }
        
        return headView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section > 1 {
            switch indexPath.row {
            case 0 :
                return kScreenWidth*99/375
            case 1 :
                return kScreenWidth*44/375
            case 2 :
                return kScreenWidth*214/375
            default :
                return kScreenWidth*106/375
            }
        }
        return self.userCenterData[indexPath.section].height
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section > 1 {
            return self.cellForHomeMulity(tableView, indexPath: indexPath)
        }
        switch  self.userCenterData[indexPath.section] {
        case .HomeContentTypeHead :
            return self.cellForHomeHead(tableView, indexPath: indexPath)
        case .HomeContentTypeAd :
            return self.cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeMenu :
            return self.cellForHomeMenu(tableView, indexPath: indexPath)
        case .HomeContentTypeGoods :
            return self.cellForHomeGoods(tableView, indexPath: indexPath)
        case .HomeContentTypeRecommendationHead :
            return self.cellForHomeRecommendationHead(tableView, indexPath: indexPath)
        case .HomeContentTypeRecommendation :
            return self.cellForHomeRecommendation(tableView, indexPath: indexPath)
        case .HomeContentTypeTheme :
            return self.cellForHomeTheme(tableView, indexPath: indexPath)
        default :
            return self.cellForHomeMulity(tableView, indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == self.userCenterData.count-1 {
//            if let advertisementAll = self.advertisementAll,topic = advertisementAll.topic {
//                let advertisement = topic[indexPath.row]
//                self.advertisementClick(advertisement)
//            }
//        }
    }
    
    
    //MARK: - *****************TableViewCell******************
    //MARK: 头部菜单 cell
    func cellForHomeHead(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "HeadCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let menuTitles = self.categories
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let width = 80,height = 44
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth - 44, height: 44)) //66
            scrollView.tag = 10001
            scrollView.backgroundColor = UIColor.clearColor()
            scrollView.showsHorizontalScrollIndicator = false
            cell?.contentView.addSubview(scrollView)
            
            //下部弹窗
            let 下拉 = UIButton(frame: CGRect(x: kScreenWidth - 44, y: 8, width: 44, height: 28))
            下拉.backgroundColor = UIColor.whiteColor()
            下拉.setImage(UIImage(named: "home_down"), forState: .Normal)
            下拉.setImage(UIImage(named: "home_up"), forState: .Selected)
            下拉.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.updateViewForNextMenu()
                if CGRectGetMinY(self.下拉视窗.frame) < 0  {
                    self.下拉视窗.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44+150)
                    self.viewShowWithBg(self.下拉视窗,showAnimation: .SlideInFromTop,dismissAnimation: .SlideOutToTop)
                } else {
                    self.dismissPopupView(self.下拉视窗)
                }
            })
            cell?.contentView.addSubview(下拉)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth - 44, y: 8, width: 0.5, height: 28)))
        }
        
        let width = 80,height = 44
        let scrollView = cell?.viewWithTag(10001) as! UIScrollView
        //******cell != nil 时为scrollView设置contentSize
        scrollView.contentSize = CGSize(width: width * menuTitles.count, height: height)
        for subView in scrollView.subviews {
            subView.removeFromSuperview()
        }
        var i = 0
        for title in menuTitles {
            let x = i * width,y = 0
            let frame = CGRect(x: x, y: y, width: width, height: height)
            i++
            
            let headBtn = UIButton(frame: frame)
            headBtn.setTitle((title as! ZMDCategory).Name, forState: .Normal)
            headBtn.titleLabel?.font = defaultDetailTextSize
            headBtn.setTitleColor(defaultDetailTextColor, forState: .Normal)
            headBtn.setTitleColor(defaultSelectColor, forState: .Selected)
            headBtn.titleLabel?.textAlignment = .Center
            headBtn.tag = 1000+i
            headBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                //直接点击scrollView上的btn，进行页面跳转
                let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                let titleFilter = (sender as! UIButton).titleLabel?.text
                homeBuyListViewController.titleForFilter = titleFilter!
//                let category = menuTitles[(sender as!UIButton).tag-1-1000] as! ZMDCategory
//                homeBuyListViewController.Cid = category.Id.stringValue
                self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
            })
            scrollView.addSubview(headBtn)
        }
        return cell!
    }
    //MARK: 广告 cell(CycleScrollView)
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "AdCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        if let v = cell?.viewWithTag(10001) {
            v.removeFromSuperview()
        }
        let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth * 280 / 750))
        cycleScroll.tag = 10001
        cycleScroll.backgroundColor = UIColor.blueColor()
        cycleScroll.delegate = self
        cycleScroll.autoScroll = true
        cycleScroll.autoTime = 2.5
        let imgUrls = NSMutableArray()
        if self.advertisementAll != nil && self.advertisementAll.top != nil {
            for id in self.advertisementAll.top! {
                var url = kImageAddressMain + (id.ResourcesCDNPath ?? "")
                if id.ResourcesCDNPath!.hasPrefix("http") {
                    url = id.ResourcesCDNPath!
                }
                url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                imgUrls.addObject(NSURL(string: url)!)
            }
            if imgUrls.count != 0 {
                cycleScroll.urlArray = imgUrls as [AnyObject]
            }
        }
        cell?.addSubview(cycleScroll)
        return cell!
    }
    // 菜单
    func cellForHomeMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "MenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            for var i=0;i<10;i++ {
                _ = 0
                let btnHeight = kScreenWidth * 210 / 750 / kScreenHeightZoom
                let width = kScreenWidth/5
                let btn = UIButton(frame: CGRectMake(kScreenWidth/5*CGFloat(i%5), btnHeight*CGFloat(i/5) ,width, btnHeight))
                btn.tag = 10000 + i
                btn.backgroundColor = UIColor.whiteColor()
                
                let imgV = UIImageView(frame: CGRectMake(width/2-25, btnHeight/2 - 25 - 10, 50,50))
                imgV.tag = 10020 + i
                btn.addSubview(imgV)
                
                let label = UILabel(frame: CGRectMake(0, CGRectGetMaxY(imgV.frame)+5, width, 14))
                label.font = UIFont.systemFontOfSize(14)
                label.textColor = defaultTextColor
                label.textAlignment =  .Center
                label.tag = 10010 + i
                btn.addSubview(label)
            
                cell!.contentView.addSubview(btn)
            }
        }
        
        for var i=0;i<10;i++ {
            let menuType = self.menuType[i]
            let btn = cell?.contentView.viewWithTag(10000 + i) as! UIButton
            let label = cell?.contentView.viewWithTag(10010 + i) as! UILabel
            let imgV = cell?.contentView.viewWithTag(10020 + i) as! UIImageView
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                switch menuType {
                case .kKSNongTe:
                    if let url = NSURL(string: "appJNNT://") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                case .kDaZongJiaoYi:
                    if let url = NSURL(string: "appDZJY://") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                case .kGongQiu:
                    if let url = NSURL(string: "appDZJY://") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                case .kKSGongYi:
                    let vc = MyWebViewController()
                    vc.webUrl = "http://www.ksnongte.com/t/gongyi"
                    self.pushToVC(vc, animated: true, hideBottom: true)
                default:
                    ZMDTool.showPromptView("功能开发中,敬请期待!")
                    break
                }
                return RACSignal.empty()
            })
            label.text = menuType.title
            imgV.image = menuType.image
            
            //当请求数据成功时,更新cellForHomeMenu上btn的图片和title
            /*if let advertisementAll = self.advertisementAll,icon = advertisementAll.icon {
                if icon.count != 0 {
                    let icon = i>=2 ? self.advertisementAll.icon![i+1] : self.advertisementAll.icon![i]
                    //icon的title暂时自定义为 类目i
                    label.text = icon.Title
                    var url = kImageAddressNew + (icon.ResourcesCDNPath ?? "")
                    if icon.ResourcesCDNPath!.hasPrefix("http") {
                        url = icon.ResourcesCDNPath!
                    }
                    //没图片，暂时不用
                    imgV.sd_setImageWithURL(NSURL(string: url), placeholderImage: nil)
                }
            }*/
        }
        return cell!
    }
    
    //MARK: - 商品 cell  offer（已抛弃）
    func cellForHomeGoods(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "goodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! AdvertisementOfferCell
        if  self.advertisementAll != nil {
            AdvertisementOfferCell.configCell(cell, advertisementAll: self.advertisementAll.offer)
        }
        return cell
    }
    //MARK: - 推荐Head cell(换一批)
    func cellForHomeRecommendationHead(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "RecommendationHeadCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.contentView.backgroundColor = defaultBackgroundColor
        cell?.selectionStyle = .None
        
        let refreshBtn = cell?.viewWithTag(1000) as!UIButton
        refreshBtn.userInteractionEnabled = false
        if let advertisementAll = self.advertisementAll,guess = advertisementAll.guess {
            refreshBtn.userInteractionEnabled = guess.count != 0 ? true : false
        }
        refreshBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section+1))
            let scrollView = cell?.contentView.viewWithTag(10001) as! UIScrollView
            scrollView.contentOffset = Int(scrollView.contentOffset.x+146*2) >= (self.advertisementAll.guess?.count)!*146 ? CGPoint(x: 0, y: 0) : CGPoint(x: scrollView.contentOffset.x+146*2, y: 0)
            return RACSignal.empty()
        })
        return cell!
    }
    //MARK: - 推荐 cell   猜你喜欢
    func cellForHomeRecommendation(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let kTagScrollView = 10001
        let cellId = "RecommendationCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = tableViewdefaultBackgroundColor
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 180)) //66
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.tag = kTagScrollView
            cell?.contentView.addSubview(scrollView)
        }
        let scrollView = cell?.viewWithTag(kTagScrollView) as! UIScrollView
        if let advertisements = self.advertisementAll,let guess = advertisements.guess {
            for subView in scrollView.subviews {
                subView.removeFromSuperview()
            }
            scrollView.contentSize = CGSize(width: (136 + 10) * CGFloat(guess.count), height: 180)
            for var i=0;i<guess.count;i++ {
                let advertisement = guess[i]
                let btnHeight = CGFloat(180)
                let width = CGFloat(136)
                let btn = UIButton(frame: CGRectMake(10*CGFloat(i + 1)+CGFloat(i) * width, 0,width, btnHeight))
                btn.tag = 10000 + i
                btn.backgroundColor = UIColor.whiteColor()
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                    vc.productId = (advertisement.Other2! as NSString ?? "").integerValue
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    return RACSignal.empty()
                })

                
                let titleLbl = UILabel(frame: CGRectMake(0, btnHeight-15-11 - 10 - 11, width, 11))
                titleLbl.font = UIFont.systemFontOfSize(11)
                titleLbl.textColor = defaultSelectColor
                titleLbl.textAlignment =  .Center
                titleLbl.tag = 10010 + i
                titleLbl.text = advertisement.Title
                btn.addSubview(titleLbl)
                
                let moneyLbl = UILabel(frame: CGRectMake(0, btnHeight-15-11, width, 11))
                moneyLbl.font = UIFont.systemFontOfSize(11)
                moneyLbl.textColor = defaultSelectColor
                moneyLbl.textAlignment =  .Center
                moneyLbl.tag = 10020 + i
                moneyLbl.text = advertisement.Other1
                btn.addSubview(moneyLbl)
                
                let imgV = UIImageView(frame: CGRectMake(width/2-48, 30, 96,96))
                var imageUrl = guess[i].ResourcesCDNPath ?? ""
                if imageUrl.rangeOfString("/Media") == nil {
                    imageUrl = "/Media"+imageUrl
                }
                imgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+imageUrl))
                btn.addSubview(imgV)
                cell!.contentView.addSubview(btn)
                scrollView.addSubview(btn)
            }
        }
        return cell!
    }
    // 特卖专题 cell
    func cellForHomeTheme(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ThemeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.selectionStyle = .None
        cell?.viewWithTag(100)?.backgroundColor = defaultBackgroundColor
        
        var tag = 10001
        let imgV = cell?.viewWithTag(tag++) as! UIImageView
        let titleLbl = cell?.viewWithTag(tag++) as! UILabel
        let timeLbl = cell?.viewWithTag(tag++) as! TimeLabel
        if let advertisements = self.advertisementAll,let topic = advertisements.topic {
            let id = topic[indexPath.row]
            let url = kImageAddressNew + (id.ResourcesCDNPath ?? "")
            imgV.sd_setImageWithURL(NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!))
            titleLbl.text = id.Title ?? ""
            
            let endTimeText = id.EndTime?.stringByReplacingOccurrencesOfString("T", withString: " ")
            timeLbl.setEndTime(endTimeText!)
            timeLbl.start()
        }
        return cell!
    }
    
    //乱七八糟cell
    func cellForHomeMulity(tableView:UITableView, indexPath:NSIndexPath)->UITableViewCell {
        let colors = [RGB(254,204,71,1),RGB(42,198,176,1),RGB(41,189,240,1)]
        switch indexPath.row {
        case 0 :
            let cellId = "MulityImageCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                let cellHeight = kScreenWidth * 250 / 925
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: cellHeight))
                imgView.tag = 10000
                cell?.contentView.addSubview(imgView)
            }
            ZMDTool.configTableViewCellDefault(cell!)
            let imgView = cell?.contentView.viewWithTag(10000) as! UIImageView
            imgView.image = UIImage(named: "banner0"+"\(indexPath.section-1)")
            if let advertisements = self.miniAds as? NSArray where advertisements.count != 0 {
//                if let advertisement =
            }
//            if let advertisements = self.miniAds[indexPath.section-2] as? NSArray where advertisements.count != 0 {
//                let advertisement = advertisements[0] as? ZMDAdvertisement
//                imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+advertisement!.Resources!), placeholderImage: nil)
//            }
            return cell!
        case 1:
            let cellId = "MulityTitleCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            let color = colors[(indexPath.section-2)%3]
            
            let titleLbl = cell!.contentView.viewWithTag(10000) as! UILabel
            let line1 = cell!.contentView.viewWithTag(10001) as! UILabel
            let line2 = cell!.contentView.viewWithTag(10002) as! UILabel
            
            line1.backgroundColor = color
            line2.backgroundColor = color
            cell!.addLine()
            
            titleLbl.text = title
            titleLbl.textColor = color
            if let category = self.categories[indexPath.section-2] as? ZMDXHYCategory {
                titleLbl.text = category.Name
                
                let size = category.Name.sizeWithFont(UIFont.boldSystemFontOfSize(18), maxWidth: 200)
                titleLbl.snp_updateConstraints(closure: { (make) -> Void in
                    make.width.equalTo(size.width+CGFloat(8))
                })
            }
            return cell!
        case 2:
            let cellId = "MulityGoodTopCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeMulityGoodTopCell
            //点击btn
            if self.dyadicProducts.count != 0 {
                cell.products = self.dyadicProducts[indexPath.section-2] as! NSArray
            }
//            if let products = self.dyadicProducts[indexPath.section-2] as? NSArray {
//                cell.products = products
//            }
            cell.btnClickFinish = {(productId:Int)->Void in
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = productId
                self.pushToVC(vc, animated: true, hideBottom: true)
            }
            ZMDTool.configTableViewCellDefault(cell)
            if let dyadicProducts = self.dyadicProducts as? NSArray where dyadicProducts.count != 0 {
                if let products = dyadicProducts[indexPath.section-2] as? NSArray where products.count != 0 {
                    cell.updateUI(products)
                }
            }
            return cell
        default :
            let cellId = "MulityGoodBotCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeMulityGoodBottomCell
            //点击btn
            if self.dyadicProducts.count != 0 {
                cell.products = self.dyadicProducts[indexPath.section-2] as! NSArray
            }
//            if let products = self.dyadicProducts[indexPath.section-2] as? NSArray {
//                cell.products = products
//            }
            cell.btnClickFinish = {(productId:Int)->Void in
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = productId
                self.pushToVC(vc, animated: true, hideBottom: true)
            }
        
            cell.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: cell.bounds.width, height: 0.5), backgroundColor: defaultLineColor))
            ZMDTool.configTableViewCellDefault(cell)

            if let dyadicProducts = self.dyadicProducts as? NSArray where dyadicProducts.count != 0 {
                if let products = dyadicProducts[indexPath.section-2] as? NSArray where products.count != 0 {
                    cell.updateUI(products)
                }
            }
            return cell
        }
    }
    
    
    //MARK: - ****************PrivateMethod*****************
    //MARK: dataInit
    private func dataInit(){
        self.userCenterData = [.HomeContentTypeAd,.HomeContentTypeMenu,.HomeContentTypeMulity,.HomeContentTypeMulity,.HomeContentTypeMulity]
        
        self.menuType = [MenuType.kKSNongTe,.kDaZongJiaoYi,.kTuanGou,.kLingQuan,.kGongQiu,.kJiaDianXiaXiang,.kKSGongYi,.kNongCunJinRong,.kBianMinFuWu,.kFuWuZhan]
    }
    
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
    }
    
    //MARK: checkUpdate
    func checkUpdate() {
        var version = "0.0.0"
        QNNetworkTool.checkUpdate { (error, dictionary) in
            if let dic = dictionary,arr = dic["results"] as? NSArray, resultCount = dic["resultCount"] as? Int where resultCount != 0 {
                if let dict = arr[0] as? NSDictionary {
                    if let appStoreVersion = dict["version"] as? String  {
                        version = appStoreVersion
                        saveObjectToUserDefaults("appStoreVersion", value: version)
                        self.compareTheVersion()
                    }
                }
            }
        }
    }
    
    func compareTheVersion() {
        let appStoreVersion = getObjectFromUserDefaults("appStoreVersion") as! String
        if appStoreVersion == "0.0.0" {
            return
        }
        let result = compareVersion(APP_VERSION, version2: appStoreVersion)
        if result == NSComparisonResult.OrderedAscending {
            self.commonAlertShow(true, btnTitle1: "确定", btnTitle2: "下一次", title: "版本更新", message: "检测到新版本\(appStoreVersion)可用\n是否立即更新?", preferredStyle: .Alert)
        }
    }
    
    //MARK:advertisementClick
    func advertisementClick(advertisement: ZMDAdvertisement){
        if let other1 = advertisement.Other1,let other2 = advertisement.Other2,let linkUrl = advertisement.LinkUrl{
            let other1 = other1 as String
            let other2 = other2 as String   //最终参数
            let linkUrl = linkUrl as String //用于获取临时参数
            switch other1{
            case "Product":
//                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
//                let arr = linkUrl.componentsSeparatedByString("/")
//                vc.hidesBottomBarWhenPushed = true
//                vc.productId = (arr[3] as NSString).integerValue
//                self.navigationController?.pushViewController(vc, animated: true)
                
                let vc = MyWebViewController()
                vc.webUrl = linkUrl
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case "Seckill":
                break
//            case "Topic":
//                break
            case "Coupon":
                break
            default:
                let vc = MyWebViewController()
                vc.webUrl = linkUrl
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                break
            }
        } else {
            let linkUrl = advertisement.LinkUrl ?? ""
            let id = (linkUrl.stringByReplacingOccurrencesOfString("http://www.ksnongte.com/", withString: "") as NSString).integerValue
            if id != 0 {
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = id
                self.pushToVC(vc, animated: true, hideBottom: true)
            }else if linkUrl != "" {
                let vc = MyWebViewController()
                vc.webUrl = linkUrl
                self.pushToVC(vc, animated: true, hideBottom: true)
            }
        }
    }
    // 下拉视窗
    class ViewForNextMenu: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    func updateViewForNextMenu()  {
        let menuTitles = self.categories
        if self.下拉视窗 != nil {
            for subV in self.下拉视窗.subviews {
                subV.removeFromSuperview()
            }
        }
        
        self.下拉视窗 = UIView(frame: CGRect(x: 0, y: -1, width: kScreenWidth, height: 44+150))
        self.下拉视窗.backgroundColor = UIColor.clearColor()
        let topV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        topV.backgroundColor = UIColor.whiteColor()
        self.下拉视窗.addSubview(topV)
        let titleLbl = ZMDTool.getLabel(CGRect(x: 16, y: 0, width: 100, height: 44), text: " 选择分类", fontSize: 17)
        topV.addSubview(titleLbl)
        let 上拉 = UIButton(frame: CGRect(x: kScreenWidth - 44, y: 8, width: 44, height: 28))
        上拉.backgroundColor = UIColor.whiteColor()
        上拉.setImage(UIImage(named: "home_up"), forState: .Normal)
        上拉.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.dismissPopupView(self.下拉视窗)
            return RACSignal.empty()
        })
        topV.addSubview(上拉)
        topV.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth - 44, y: 8, width: 0.5, height: 28)))
        
        var i = 0
        let btnBg = UIView(frame: CGRect(x: 0, y: 44, width: kScreenWidth, height: kScreenWidth * 280/750))
        btnBg.backgroundColor = UIColor(white: 1.0, alpha: 0.9)

        
        self.下拉视窗.addSubview(btnBg)
        for title in menuTitles {
            let width = kScreenWidth/CGFloat(3),height = CGFloat(50)
            let columnIndex  = i%3
            let rowIndex = i/3
            let x = CGFloat(columnIndex) * width ,y  = CGFloat(rowIndex)*50
            i++
            
            let menuBtn = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
            menuBtn.backgroundColor = UIColor.clearColor()
            menuBtn.setTitle((title as! ZMDCategory).Name, forState: .Normal)
            menuBtn.titleLabel?.font = defaultDetailTextSize
            menuBtn.setTitleColor(defaultTextColor, forState: .Normal)
            menuBtn.setTitleColor(defaultSelectColor, forState: .Selected)
            menuBtn.tag = 1000 + i
            menuBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                let category = menuTitles[sender.tag - 1001] as! ZMDCategory
                let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                homeBuyListViewController.Cid = category.Id.stringValue
                homeBuyListViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
            })
            btnBg.addSubview(menuBtn)
            ZMDTool.configViewLayerFrameWithColor(menuBtn, color: UIColor.whiteColor())
        }
    }
    
    func setupNewNavigation() {

        let imgViewL = UIImageView(frame: CGRect(x: 0, y: 0, width: 35*63/50, height: 35))
        imgViewL.image = UIImage(named: "kc")?.imageWithRenderingMode(.AlwaysOriginal)
        let leftItem = UIBarButtonItem(customView: imgViewL)
        leftItem.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = leftItem
        
        
        let textInput = UITextField(frame: CGRect(x: 0, y: 0, width: kScreenWidth - 135, height: 35))
        textInput.placeholder = "商品关键字"
        textInput.backgroundColor = RGB(235, 235, 235, 1)
        ZMDTool.configViewLayerWithSize(textInput, size: 15)
        textInput.delegate = self
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let leftImageView = UIImageView(frame: CGRect(x: 7.5, y: 6.5, width: 20, height: 22))
        leftView.addSubview(leftImageView)
        leftImageView.image = UIImage(named: "search")
        textInput.leftView = leftView
        textInput.leftViewMode = .Always
        self.navigationItem.titleView = textInput
        
        let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        rightBtn.setImage(UIImage(named: "message")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = MsgHomeViewController()
            self.pushToVC(vc, animated: true, hideBottom: true)
            return RACSignal.empty()
        })
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    
    //MARK: NetWork
    func fetchData() {
        ZMDTool.showActivityView(nil, inView: nil, 20)
        let queue = dispatch_get_global_queue(0, 0)
        dispatch_async(queue) { () -> Void in
            QNNetworkTool.fetchMainPageInto { (advertisementAll, error, dictionary) -> Void in
                if advertisementAll != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.advertisementAll = advertisementAll
                        self.currentTableView.reloadData()
                    })
                }
            }
        }
        self.fetchCategories()
    }
    
    func fetchCategories(){
        let queue1 = dispatch_queue_create("categoryQueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue1) { () -> Void in
            QNNetworkTool.fetchMainCategories { (categories, error) -> Void in
                if let categories = categories {
                    for _ in categories {
                        //                    self.dyadicProducts.addObject(NSMutableArray)
                        //                    self.widgetNames.addObject(NSMutableArray)
                    }
                    self.requestDataNumber++
                    self.categories.removeAllObjects()
                    self.categories.addObjectsFromArray(categories as [AnyObject])
                    self.currentTableView.reloadData()
                    if self.requestDataNumber == 1 {
                        self.fetchProducts(categories)
                    }
                }else{
                    ZMDTool.showErrorPromptView(nil, error: error)
                    
                }
            }
        }
    }
    
    func fetchProducts(categories:NSArray) {
        self.dyadicProducts.removeAllObjects()
        self.widgetNames.removeAllObjects()
        let group = dispatch_group_create()
        for category in categories {
            let category = category as! ZMDXHYCategory
            dispatch_group_enter(group)
            sleep(1)
            QNNetworkTool.fetchProductsInCategory(5, categoryId: category.Id.integerValue, completion: { (products, WidgetName, error) -> Void in
                if let products = products,widgetName = WidgetName {
                    self.dyadicProducts.addObject(products)
                    self.widgetNames.addObject(widgetName)
                    var num = 0
                    for name in self.widgetNames {
                        if name as! String == widgetName {
                            break
                        }
                        num++
                    }
                    if num == self.widgetNames.count-1 {
                        self.fetchMiniAd(widgetName,group:group)
                    }
                }
//                dispatch_group_leave(group)
            })
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            ZMDTool.hiddenActivityView()
            self.currentTableView.reloadData()
        }
    }
    
    func fetchMiniAd(widgetName:String,group:dispatch_group_t) {
        let queue = dispatch_queue_create("miniAdQueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue) { () -> Void in
            QNNetworkTool.fetchAdInCategory(widgetName) { (advertisements, error) -> Void in
                dispatch_group_leave(group)
                if let advertisements = advertisements {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.miniAds.addObjectsFromArray(advertisements as [AnyObject])
                        self.currentTableView.reloadData()
                    })
                }else{
                    //                ZMDTool.showErrorPromptView(nil, error: error)
                }
            }
        }
    }
    
    
    //MARK: - ***************Delegate***************
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text != "" {
            let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
            vc.titleForFilter = textField.text ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return true
    }
    //MARK: searchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        vc.titleForFilter = searchBar.text ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: 广告分区cycleScrollView delegate
    func clickImgAtIndex(index: Int) {
        //点击cycleScrollView中图片，响应事件
        if let advertisementAll = self.advertisementAll,top = advertisementAll.top {
            let advertisement = top[index]
            self.advertisementClick(advertisement)
        }
    }

    //MARK: - ***************Override***************
    //MARK: CommonAlert Action重写
    override func alertDestructiveAction() {
        if let url = NSURL(string: APP_URL_IN_ITUNES) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func alertSingleAction() {
        
    }
}
