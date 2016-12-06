//
//  SortViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class SortViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol{
    
    var collectView : UICollectionView!
    var titles = ["床上用品","儿童家具","购物卡","热销","热门","儿童床"]
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestData()
        self.updateUI()
        self.setupNavigation()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.title = "分类"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UICollectionViewDataSource UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellId = "Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()

        let imgView = UIImageView(frame: cell.bounds)
        let leftLine = ZMDTool.getLine(CGRect(x: 0, y: 0, width: 0.25, height: cell.bounds.height),backgroundColor: UIColor.grayColor())
        let rightLine = ZMDTool.getLine(CGRect(x: cell.bounds.width-0.25, y: 0, width: 1, height: cell.bounds.height), backgroundColor: UIColor.grayColor())
        let bottomLine = ZMDTool.getLine(CGRect(x: 0, y: cell.bounds.height-0.5, width: cell.bounds.width, height: 0.5), backgroundColor: UIColor.grayColor())
        
        cell.contentView.addSubview(imgView)
        cell.contentView.addSubview(bottomLine)
        if indexPath.row % 2 == 0 {
            cell.contentView.addSubview(rightLine)
        }else{
            cell.contentView.addSubview(leftLine)
        }
        
        imgView.image = UIImage(named: "home_banner0\(indexPath.row % 3 + 3)")
        if self.dataArray.count != 0 {
            let category = self.dataArray[indexPath.row%self.dataArray.count] as! ZMDXHYCategory
            if let urlString = category.PictureModel.ImageUrl,url = NSURL(string: "http://www.hulubao.com" + urlString){
                imgView.sd_setImageWithURL(url, placeholderImage: nil)
            }
        }
        
        return cell
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = self.view.bounds.height
        return CGSizeMake(kScreenWidth/2, height/4)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        vc.titleForFilter = self.titles[indexPath.row % 3 + 3]
        if self.dataArray.count != 0 {
            vc.titleForFilter = (self.dataArray[indexPath.row % self.dataArray.count] as! ZMDXHYCategory).Name
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: -  PrivateMethod
    func requestData() {
        
        QNNetworkTool.sortCategories { (category, error, dicitonary) -> Void in
            if let array = category {
                self.dataArray.removeAllObjects()
                self.dataArray.addObjectsFromArray(array as [AnyObject])
                self.collectView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(dicitonary, error: error)
            }
        }
    }
    
    func updateUI() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0.0
        self.collectView = UICollectionView(frame: CGRectMake(0, 10, kScreenWidth, self.view.bounds.height - 20), collectionViewLayout: flowLayout)
        self.collectView.backgroundColor = UIColor.clearColor()
        self.collectView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectView.delegate = self
        self.collectView.dataSource = self
        self.view.addSubview(collectView)
        
    }
    
    func setupNavigation() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        btn.setImage(UIImage(named: "home_search_gray"), forState: .Normal)
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = HomeBuyGoodsSearchViewController.CreateFromMainStoryboard() as! HomeBuyGoodsSearchViewController
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController( vc, animated: true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
}
