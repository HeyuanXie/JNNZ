//
//  HomeBuyListViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/24.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MJRefresh
//商品列表
class HomeBuyListViewController: UIViewController ,ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{

    enum TypeSetting {
        case Horizontal
        case vertical
    }
    @IBOutlet weak var currentTableView: UITableView!
    var popView : UIView!
    var footer : MJRefreshAutoNormalFooter!
    var typeSetting = TypeSetting.Horizontal      // 横排
    var dataArray = NSMutableArray()
    var indexSkip = 1
    var IndexFilter = 0
    var isHasNext = true
    var orderby = 16                                // 排序
    var orderbyPriceUp = true                       // 价格升序
    var orderbySalesUp = true                       //销量升序
    var orderbyPopularUp = true                    //人气升序
    var orderBy : Int = 0
    
    //postData
    var titleForFilter = ""                        // 关键字 (请求本页面数据的url参数之一)
    var isLease = false             //租赁
    var isStore = false  //商店展示搜索
    var storeId:NSNumber = 0
    var hideSearch = false      //是否隐藏右上角searchBtn
    var isNew = false       //是否为新品推荐
    var Cid = ""                                    // 产品类别
    var As = "false"        //是否通过Cid搜索

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        // 底部刷新
        footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        self.currentTableView.mj_footer = footer
        
        self.setVCTitle()
        self.setupNewNavigation()
        self.updateData(self.orderby)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.setupNewNavigation()
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
        let tmp01 = self.dataArray.count/2
        let tmp02 = self.dataArray.count%2
        return self.typeSetting == .Horizontal ? (tmp01 + tmp02) : self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 52 + 10 : 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.typeSetting == .Horizontal ? 581/750 * kScreenWidth + 20 : 300/750 * kScreenWidth
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.createFilterMenu()
        } else {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
            headView.backgroundColor = UIColor.clearColor()
            return headView
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = self.typeSetting == .Horizontal ? "doubleGoodsCell" : "goodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsTableViewCell
        //doubleGoodsCell
        if self.typeSetting == .Horizontal {
            //点击leftBtn
            let productL = self.dataArray[indexPath.section*2] as! ZMDProduct
            cell.leftBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.pushDetailVc(productL)
                return RACSignal.empty()
            })

            //点击rightBtn
            if indexPath.section*2+1 <= self.dataArray.count-1 {
                let productR = self.dataArray[indexPath.section*2 + 1] as! ZMDProduct
                cell.rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.pushDetailVc(productR)
                    return RACSignal.empty()
                })
                DoubleGoodsTableViewCell.configCell(cell, product: productL, productR: productR)
            }else{
                DoubleGoodsTableViewCell.configCell(cell, product: productL, productR: nil)
            }
            
            //将收藏按钮放置前面
            //**在Storyboard中收藏按钮位于下方，不能触发
            cell.leftView.bringSubviewToFront(cell.isCollectionBtnLeft)
            cell.rightView.bringSubviewToFront(cell.isCollectionRight)
            
//            if indexPath.section*2+1 <= self.dataArray.count - 1{
//                let productR = self.dataArray[indexPath.section*2+1] as! ZMDProduct
//                DoubleGoodsTableViewCell.configCell(cell, product: productL,productR:productR)
//            } else {
//                DoubleGoodsTableViewCell.configCell(cell, product: productL,productR:nil)
//            }
        } else {
            //singleCell的收藏
            cell.contentView.bringSubviewToFront(cell.isCollectionBtnLeft)
            cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_normal.png"), forState: UIControlState.Normal)
            cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_selected.png"), forState: UIControlState.Selected)
            let product = self.dataArray[indexPath.section] as! ZMDProduct
            cell.isCollectionBtnLeft.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                cell.isCollectionBtnLeft.selected = !cell.isCollectionBtnLeft.selected
                if cell.isCollectionBtnLeft.selected {
                    //从服务器添加收藏
//                    let product = self.dataArray[indexPath.row] as! ZMDProduct
                    let dic = NSMutableDictionary()
                    dic.setValue(g_customerId!, forKey: "CustomerId")
                    dic.setValue(1, forKey: "Quantity")
                    dic.setValue(product.Id, forKey: "Id")
                    dic.setValue(1, forKey: "carttype")
                    QNNetworkTool.addProductToCart(dic, completion: { (succeed, dictionary, error) -> Void in
                        if succeed! {
                            ZMDTool.showPromptView("收藏成功")
                        }else{
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "收藏失败")
                        }
                    })
                }else{
                    //从服务器删除收藏(删除时需要参数shoppItem.Id)
                    QNNetworkTool.fetchShoppingCart(2){(shoppingItems, dictionary, error) -> Void in
                        for shoppingItem in shoppingItems! {
                            if (shoppingItem as! ZMDShoppingItem).ProductName == product.Name{
                                QNNetworkTool.deleteCartItem((shoppingItem as! ZMDShoppingItem).Id.stringValue, carttype: 2, completion: { (succeed, dictionary, error) -> Void in
                                    if succeed != nil {
                                        ZMDTool.showPromptView("已取消收藏")
                                    }else{
                                        ZMDTool.showPromptView("取消收藏失败")
                                    }
                                })
                                break
                            }
                        }
                    }
                }
                return RACSignal.empty()
            })
            let productL = self.dataArray[indexPath.section] as! ZMDProduct
            DoubleGoodsTableViewCell.configCell(cell, product: productL,productR:nil)
        }
        return cell
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.typeSetting == .vertical {
            let product = self.dataArray[indexPath.section] as! ZMDProduct
            self.pushDetailVc(product)
        }
    }
    func pushDetailVc(product : ZMDProduct) {
        let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.productId = product.Id.integerValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar)  {
        self.view.endEditing(true)
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        homeBuyListViewController.titleForFilter = searchBar.text ?? ""
        homeBuyListViewController.hideSearch = true
        self.navigationController?.pushViewController(homeBuyListViewController, animated: false)
    }
    //MARK: -  PrivateMethod
    //创建目录视图，作为第0个section的headerView
    func createFilterMenu() -> UIView{
//        let filterTitles = self.isLease ? ["默认","人气","价格","筛选",""] : ["默认","销量","价格","最新",""]
        let filterTitles = ["默认","销量","人气","价格",""]
        let countForBtn = CGFloat(filterTitles.count) - 1//4
        //52+16，与tableView的delegate中设置的第0个section的heightForHeader一致
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 52 + 16))
        view.backgroundColor = UIColor.clearColor()
        for var i=0;i<filterTitles.count;i++ {
            let index = i%filterTitles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * (kScreenWidth-54)/countForBtn , 0, (kScreenWidth-54)/countForBtn, 52))
            btn.backgroundColor = UIColor.whiteColor()
            btn.selected = i == self.IndexFilter ? true : false
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
            //控制横排和竖排的按钮
            if filterTitles[i] == "" {
                btn.frame = CGRectMake(CGFloat(index) * (kScreenWidth-54)/countForBtn, 0, 54, 52)
                btn.setImage(UIImage(named: "list_shupai"), forState: .Normal)
                btn.setImage(UIImage(named: "list_hengpai"), forState: .Selected)
                btn.selected = self.typeSetting == .Horizontal ? false : true
            } else {
                btn.setTitle(filterTitles[i], forState: .Normal)
                btn.setTitle(filterTitles[i], forState: .Selected)
                switch(filterTitles[i]){
                case "默认" :
                    break
                default :
                    let width = (kScreenWidth-54)/countForBtn
                    btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2 + 40, bottom: 0, right: 0)
                    btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2+16)
                    
                    if self.IndexFilter == i {
                        let orderbyArray = [self.orderbySalesUp,self.orderbyPopularUp,self.orderbyPriceUp]
                        btn.selected = orderbyArray[i-1]
                        btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                        btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                        btn.setTitleColor(RGB(235,61,61,1.0), forState: .Normal)
                    } else {
                        btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                    }
                    break
                }

            }
            btn.titleLabel?.font = UIFont.systemFontOfSize(13)
            btn.tag = 1000 + i
            view.addSubview(btn)
            
            //btn间的分割线
            let line = ZMDTool.getLine(CGRect(x: btn.frame.size.width-1, y: 19, width: 1, height: 15))
            btn.addSubview(line)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                if (sender.tag - 1000) == filterTitles.count - 1 {
                    self.typeSetting = self.typeSetting == .Horizontal ? .vertical : .Horizontal
                    (sender as! UIButton).selected = !(sender as! UIButton).selected
                    self.currentTableView.reloadData()
                    return
                }
//                let orderbys = [(-1,-1),(17,18),(10,11),(15,16)]
                self.IndexFilter = sender.tag - 1000
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                let orderbys = [(-1,-1),(17,18),(15,16),(10,11)]
                let title = filterTitles[sender.tag - 1000]
                let orderby = orderbys[sender.tag - 1000]
                switch title {
                case "默认" :
                    self.orderBy = 0
                    break
                case "销量" :
                    self.orderbySalesUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbySalesUp ? orderby.0 : orderby.1
                    break
                case "价格" :
                    self.orderbyPriceUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbyPriceUp ? orderby.0 : orderby.1
                    break
                case "人气" :
                    self.orderbyPopularUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbyPopularUp ? orderby.0 : orderby.1
                    break
                default :
                    break
                }
                //点击上面的menu时让indexSkip归零，让后定义orderBy重新请求数据
                self.indexSkip = 1
                self.updateData(self.orderBy)
            })

        }
        return view
    }
    func setVCTitle() {
        if self.isNew {
            self.title = "新品推荐"
        }else{
            if self.titleForFilter == "" {
                self.title = "所有商品"
            }else{
                self.title = self.isStore ? "所有商品" : self.titleForFilter
            }
//            self.title = self.isStore ? "所有商品" : self.titleForFilter
        }
    }
    func setupNewNavigation() {
        if self.isStore {
            let searchView = UIView(frame: CGRectMake(0, 0, kScreenWidth - 120, 44))
            let searchBar = UISearchBar(frame: CGRectMake(0, 4, kScreenWidth - 120, 36))
            searchBar.backgroundImage = UIImage.imageWithColor(UIColor.clearColor(), size: searchBar.bounds.size)
            searchBar.placeholder = "搜索商品"
            searchBar.layer.borderColor = UIColor.grayColor().CGColor;
            searchBar.layer.borderWidth = 0.5
            searchBar.layer.cornerRadius = 6
            searchBar.layer.masksToBounds = true
            searchBar.delegate = self
            searchView.addSubview(searchBar)
            self.navigationItem.titleView = searchView
            
            let item = UIBarButtonItem(image: UIImage(named: "common_more")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("gotoMore"))
            item.customView?.tintColor = UIColor.blackColor()
            
            self.navigationItem.rightBarButtonItem = item
        } else {
            let rightItem = UIBarButtonItem(image: UIImage(named: "home_search")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: nil, action: nil)
            rightItem.tintColor = navigationTextColor
            rightItem.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                //********点击搜索按钮，进入搜索页面
                let homeBuyGoodsSearchViewController = HomeBuyGoodsSearchViewController.CreateFromMainStoryboard() as! HomeBuyGoodsSearchViewController
                self.navigationController?.pushViewController(homeBuyGoodsSearchViewController, animated: true)
                return RACSignal.empty()
            })
            rightItem.customView?.tintColor = UIColor.whiteColor()
            if !hideSearch {
                self.navigationItem.rightBarButtonItem = rightItem
            }
        }
    }
    
    //
    func popWindow () {
        self.popView = UIView(frame: CGRectMake(0 , 64+52, kScreenWidth,  self.view.bounds.height - 100))
        self.popView.backgroundColor = UIColor.blueColor()
        self.popView.showAsPopAndhideWhenClickGray()
    }
    
    /*func updateData(orderby:Int?) {
        if self.isStore || self.isNew {
            QNNetworkTool.isNewProduct(12, pageNumber: self.indexSkip, orderBy: self.orderBy, completion: { (products, error, dictionary) -> Void in
                if let products = products {
                    if self.indexSkip == 1 {
                        self.dataArray.removeAllObjects()
                    }
                    self.dataArray.addObjectsFromArray(products as [AnyObject])
                    self.isHasNext = products.count < 12 ? false : true
                    self.currentTableView.reloadData()
                    self.footer.endRefreshing()
                }else{
                    ZMDTool.showErrorPromptView(nil, error: error)
                }
            })
        }else{
            QNNetworkTool.products(self.titleForFilter,pagenumber: "\(self.indexSkip)",orderby:orderby,Cid: self.Cid) { (products, error, dictionary) -> Void in
                if let products = products {
                    if self.indexSkip == 1 {
                        self.dataArray.removeAllObjects()
                    }
                    self.dataArray.addObjectsFromArray(products as [AnyObject])
                    //请求一条数据有12个元素
                    self.isHasNext = products.count < 12 ? false : true
                    self.currentTableView.reloadData()
                    self.footer.endRefreshing()
                } else {
                    ZMDTool.showErrorPromptView(nil, error: error)
                }
            }
        }
    }*/
    func updateData(orderby:Int?) {
        let isNew = "false"
        let Q = self.As == "true" ? "" : self.titleForFilter
        QNNetworkTool.products(self.As, pageSize: 12, pageNumber: self.indexSkip, storeId: self.storeId.integerValue, Q: Q, orderBy: orderby!, isNew: isNew, Cid: (self.Cid as NSString).integerValue) { (products, error, dic) -> Void in
            if let productsArr = products {
                if self.indexSkip == 1 {
                    self.dataArray.removeAllObjects()
                }
                self.indexSkip += 1
                self.dataArray.addObjectsFromArray(productsArr as [AnyObject])
                self.currentTableView.reloadData()
                if productsArr.count < 12 {
                    self.isHasNext = false
                    self.footer.endRefreshingWithNoMoreData()
                }else{
                    self.isHasNext = true
                    self.footer.endRefreshing()
                }
            }else{
                ZMDTool.showErrorPromptView(dic, error: error)
            }
        }
    }

    // MARK:-底部刷新
    func footerRefresh(){
        //当上拉还有数据时，刷新
        if self.isHasNext {
            self.indexSkip += 1
            self.updateData(self.orderBy)
        }else{
            self.currentTableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }

}
