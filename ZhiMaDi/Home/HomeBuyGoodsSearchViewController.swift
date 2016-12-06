//
//  HomeBuyGoodsSearchUIViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/26.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import FMDB
// 商品搜索
class HomeBuyGoodsSearchViewController: UIViewController, ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var currentTableView: UITableView!
    let goodses  = ["酒","核桃","服饰","水果"]
    var goodsHistory = NSMutableArray()
    let goodsData = ["",""]
    var reccomdArray :NSMutableArray = NSMutableArray()
    
    enum TableViewType {
        case WithNoGoods
        case WithGoods
    }
    var tableViewType = TableViewType.WithNoGoods      //tableView的section结构
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.dataInit()
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.setupNewNavigation()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //搜索跳转到另一个页面返回时，将搜索历史更新
        self.dataInit()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableViewType == .WithNoGoods ? 2 : 4
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.goodsHistory.count + 1
        } else if section == 3 {
            //为你推荐
            return goodsData.count
        }
        return  1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 :
            return 0
        case 1 :
            return 10
        case 2 :
            return 0
        case 3 :
            return 0
        default :
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
            var x = 14 + size.width
            var y = 50
            let space = CGFloat(12)
            for goods in goodses {
                let sizeTmp = goods.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                let xTmp = x + space + sizeTmp.width + 20 + 12
                if xTmp > kScreenWidth {
                    y += 38
                    x = 14 + sizeTmp.width + 20
                } else {
                    x = x + space + sizeTmp.width + 20
                }
            }
            return  CGFloat(y)
        } else if indexPath.section == 1 {
            return  55
        } else if indexPath.section == 2 {
            return  80
        } else if indexPath.section == 3 {
            return  (kScreenWidth/2-12*2)*2 + 20
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 ://热搜
            let cellId = "goodsHotCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            //热搜sectioncell：一个“热搜”label 和 其他 气泡button
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let label = UILabel(frame: CGRectMake(14, 18,100, 15))
                label.text = "热搜 ："
                label.textColor = UIColor.blackColor()
                label.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(label)
                
                let size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
                let getBtn = { (text : String,index : Int) -> UIButton in
                    let btn = UIButton(frame: CGRect.zero)
                    btn.setTitle(text, forState: .Normal)
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.titleLabel?.font = UIFont.systemFontOfSize(17)
                    btn.layer.borderColor = UIColor.grayColor().CGColor;
                    btn.layer.borderWidth = 0.5
                    btn.layer.cornerRadius = 10
                    btn.layer.masksToBounds = true
                    btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                        //得到btn上的标题，通过标题进入对应的HomeBuyListViewController更新UI
                        let goods = self.goodses[index]
                        // save
                        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                        homeBuyListViewController.titleForFilter = goods
                        homeBuyListViewController.hideSearch = true
                        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
                    })
                    return btn
                }
                var x = 14 + size.width
                var y = 12
                let space = CGFloat(12)
                var index = 0
                for goods in goodses {
                    let sizeTmp = goods.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                    let xTmp = x + space + sizeTmp.width + 20  + 12
                    let btn = getBtn(goods,index)
                    btn.tag = index++
                    if xTmp < kScreenWidth {
                        btn.frame = CGRectMake(x + space , CGFloat(y),sizeTmp.width + 20, 26)
                        cell?.contentView.addSubview(btn)
                        x = x + space + sizeTmp.width + 20
                    } else {
                        y += 38
                        x = 14 + sizeTmp.width + 20
                        btn.frame = CGRectMake(14, CGFloat(y),sizeTmp.width + 20, 26)
                        cell?.contentView.addSubview(btn)
                    }
                }
            }
            
            return cell!
        case 1 :
            //搜索历史
            //indexPath.row == self.goodsHistory.count,即为最后一个cell：cleanCell
            if indexPath.row == self.goodsHistory.count {
                let cellId = "cleanCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    let title = "清除搜索记录"
                    let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth)
                    let label = UILabel(frame: CGRectMake(kScreenWidth/2-size.width/2,0,size.width, 55))
                    label.text = title
                    label.textAlignment = .Center
                    
                    label.textColor = defaultDetailTextColor
                    label.font = UIFont.systemFontOfSize(14)
                    cell?.contentView.addSubview(label)
                    
                    let imgV = UIImageView(frame: CGRect(x: label.frame.origin.x - 29, y: 18, width: 19, height: 19))
                    imgV.image = UIImage(named: "GoodsSearch_Trash")
                    cell?.contentView.addSubview(imgV)
                }
                return cell!
            }
            //其他的都是搜索历史Cell：historyCell
            let cellId = "historyCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                
                let btn = UIButton(frame: CGRectMake(kScreenWidth-26, 20, 14, 14))
                btn.backgroundColor = UIColor.clearColor()
                btn.setImage(UIImage(named: "GoodsSearch_close"), forState: .Normal)
                btn.tag = indexPath.row
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    //点击btn删除当前条搜索历史在dataBase中对应的数据
                    self.deleteValueFromDB(self.createOrOpenDB(),text:(self.goodsHistory[(sender as! UIButton).tag] as! String))
                    //删除数据后，更新搜索历史
                    self.dataInit()
                })
                
                //                let label = UILabel(frame: CGRectMake(14, 20,100, 16))
                //                label.text = self.goodsHistory[indexPath.row] as? String
                //                label.textColor = defaultDetailTextColor
                //                label.font = UIFont.systemFontOfSize(16)
                //
                cell?.contentView.addSubview(btn)
                //                cell?.contentView.addSubview(label)
                
                let line = UIImageView(frame: CGRect(x: 0, y: 54, width: kScreenWidth, height: 0.5))
                line.backgroundColor = defaultLineColor
                cell?.contentView.addSubview(line)
            }
            cell?.textLabel?.text = self.goodsHistory[indexPath.row] as? String
            cell?.textLabel?.textColor = defaultDetailTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(16)
            return cell!
        case 2 :
            //为你推荐
            let cellId = "doubleHeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            return cell!
        case 3 :
            //
            let cellId = "doubleGoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsTableViewCell
            cell.selectionStyle = .None
            
            if self.reccomdArray.count != 0 {
                let productL = self.reccomdArray[indexPath.row*2] as! ZMDProduct
                let productR = self.reccomdArray[indexPath.row*2+1] as! ZMDProduct
                cell.leftBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                    vc.productId = productL.Id.integerValue
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    return RACSignal.empty()
                })
                cell.rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                    vc.productId = productR.Id.integerValue
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    return RACSignal.empty()
                })
                DoubleGoodsTableViewCell.configCell(cell, product: productL , productR: productR)
            }
            return cell
            
        default :
            return UITableViewCell()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 : //热搜
            return  //无操作
        case 1 :
            //点击"清除搜索记录"cell，删除所有记录
            if indexPath.row == self.goodsHistory.count {
                let dataBase = self.createOrOpenDB()
                dataBase.executeUpdate("DELETE FROM GoodsHistory", withArgumentsInArray: nil)
                self.dataInit()
            }else{
                //点击其他cell，将cell.label.text返回给searchBar.text
                let text = self.goodsHistory[indexPath.row] as! String
                let searchView = self.navigationItem.titleView
                let searchBar = searchView?.subviews.first as! UISearchBar
                searchBar.text = text
                let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                homeBuyListViewController.hideSearch = true
                homeBuyListViewController.titleForFilter = text
                self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
            }
            return
        case 2 :
            return  //无操作
        case 3 :
            //进入商品详情页
            return
        default:
            break
        }
        
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let bgBtn = UIButton(frame: self.view.bounds)
        bgBtn.tag = 100
        self.presentPopupView(bgBtn, config: .None)
        bgBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            bgBtn.removeFromSuperview()
            (self.navigationItem.titleView?.viewWithTag(10000) as! UISearchBar).resignFirstResponder()
            return RACSignal.empty()
        })
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar)  {
        self.view.endEditing(true)
        self.view.viewWithTag(100)?.removeFromSuperview()
        insertValueToDB(createOrOpenDB(),text: searchBar.text!)
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        homeBuyListViewController.titleForFilter = searchBar.text ?? ""
        homeBuyListViewController.hideSearch = true
        self.navigationController?.pushViewController(homeBuyListViewController, animated: false)
    }
    //MARK: -  PrivateMethod
    func setupNewNavigation() {
        let searchView = UIView(frame: CGRectMake(0, 0, kScreenWidth - 120, 44))
        let searchBar = UISearchBar(frame: CGRectMake(0, 4, kScreenWidth - 120, 36))
        searchBar.backgroundImage = UIImage.imageWithColor(UIColor.clearColor(), size: searchBar.bounds.size)
        searchBar.placeholder = "商品关键字"
        searchBar.layer.borderColor = UIColor.grayColor().CGColor
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.cornerRadius = 6
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
        searchBar.tag = 10000
        searchView.addSubview(searchBar)
        self.navigationItem.titleView = searchView
        
        let rightItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        rightItem.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            self.navigationController?.popViewControllerAnimated(true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    //获取 为你推荐 部分商品内容
    func fetchData() {
        QNNetworkTool.products("农产品", pagenumber: "\(3)", orderby: 0, Cid: "") { (products, error, dictionary) -> Void in
            if let productArr = products {
//                for var i=0;i<4;i++ {
//                    self.reccomdArray = NSMutableArray(array: productArr)
//                }
                self.reccomdArray = NSMutableArray(array: productArr)
            }
            self.tableViewType = self.reccomdArray.count == 0 ? TableViewType.WithNoGoods : .WithGoods
            self.currentTableView.reloadData()
        }
    }
    
    func dataInit() {
        self.queryValueToDB(self.createOrOpenDB())
    }
    func createOrOpenDB() -> FMDatabase {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("Zmd.sqlite")
        let database = FMDatabase(path: fileURL.path)
        if !database.open() {
            print("Unable to open database")
            return database
        }
        do {
            try database.executeUpdate("create table if not exists GoodsHistory(id integer PRIMARY KEY AUTOINCREMENT,goodsTitle text)", values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return database
    }
    func insertValueToDB(database:FMDatabase,text:String) {
        for tmp in self.goodsHistory {
            if tmp as? String == text {
                return
            }
        }
        do {
            try database.executeUpdate("insert into GoodsHistory (goodsTitle) values (?)", values: [text])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    func deleteValueFromDB(database:FMDatabase,text:String) {
        do {
            try database.executeUpdate("delete from GoodsHistory where (goodsTitle) = (?)",values: [text])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        //删除后刷新section和table都没用，因为这两个方法都不会从改变后的dataBase中更新UI，只有datainit()方法可以
        //        self.currentTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Bottom)
        //        self.currentTableView.reloadData()
    }
    
    //从dataBase中请求数据
    func queryValueToDB(database:FMDatabase) {
        do {
            let rs = try database.executeQuery("select goodsTitle from GoodsHistory", values: nil)
            self.goodsHistory.removeAllObjects()
            while rs.next() {
                let goodsTitle = rs.stringForColumn("goodsTitle")
                self.goodsHistory.addObject(goodsTitle)
            }
            self.currentTableView.reloadData()
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
}
