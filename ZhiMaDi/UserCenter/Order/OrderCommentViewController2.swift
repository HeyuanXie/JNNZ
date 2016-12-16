//
//  OrderCommentViewController2.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/6.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class OrderCommentViewController2: UIViewController,ZMDInterceptorProtocol,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {

    var isCommented = false    //区分返回按钮 调到那个页面
    
    var currentTableView : UITableView!
    var goodsScoreRigthLbl : UILabel!
    var serverScoreRightLbl : UILabel!
    var logisticsScoreRigthLbl : UILabel!
    var checkBtn : UIButton!
    var submitBtn : UIButton!
    var canSubmit = false
    var IsAnonymous = false     //匿名评价
    
    var descriptionPoint : Int! //描述相符
    var servicePoint : Int!     //服务态度
    var logisticsPoint : Int!   //物流态度
    
    //MARK:--
    var orderId : NSNumber!         //当前订单id
    var reviews = NSMutableArray()  //OrderItemModel数组
    var comments = NSMutableArray() //ReviewText数组
    
    //记录currentTableVIew的cell的高度
    var textImageCellHeights = NSMutableArray()
    var photoCellHeights = NSMutableArray()
    
    //用来判断faceBtn的选中状态
    var rates = NSMutableArray()
    var rateBtns = NSMutableArray()
    
    let picker: UIImagePickerController = UIImagePickerController()
    var tmp : UIButton!
    
    //MARK:--TZImagePicker相关属性
    var maxImagesCount = 5
    var isSelectOriginalPhoto = true
    
    //记录选中的图片
    var photos = NSMutableArray()       //二维数组
    var selectedAssets = NSMutableArray()   //二维
    
    //用来判断是点击哪个section进入MWPhotoBrowser
    var photoIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
        self.updateData()
        // Do any additional setup after loading the view.
    }

    //MARK: - UITableViewDelegate,UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.reviews.count == 0 ? 0 : self.reviews.count + 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == self.reviews.count {
            return 1
        }
        return 3
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == self.reviews.count {
            return 158
        }
        switch indexPath.row {
        case 0:
            return self.textImageCellHeights[indexPath.section] as! CGFloat    //190
        case 1:
            return self.photoCellHeights[indexPath.section] as! CGFloat         //90
        default:
            return 50
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == self.reviews.count {
            return self.cellForStoreComment(tableView, indexPath: indexPath)
        }
        if indexPath.row == 0 {
            return self.cellForTextAndImage(tableView, indexPath: indexPath)
        }else if indexPath.row == 1 {
            return self.cellForPhotos(tableView, indexPath: indexPath)
        }else{
            return self.cellForFaceView(tableView, indexPath: indexPath)
        }
    }
    
    //MARK: - ***********TableViewCell***************
    //MARK: - TableViewCell
    //MARK: --HeaderViewBg更新UI
    func updateHeaderViewBg(headerViewBg:UIView,review:ZMDProductComment) {
        let imgView = headerViewBg.viewWithTag(10001) as! UIImageView
        if let urlStr = review.OrderItemModel.PictureUrl,url = NSURL(string: kImageAddressMain + urlStr) {
            imgView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "product_default"))
        }
    }
    
    //MARK: --文字评论cell
    func cellForTextAndImage(tableView:UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TextAndImageCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
            
            let bgView = self.configTextImageBgView(indexPath.section)
            cell?.contentView.addSubview(bgView)
            bgView.tag = 10000
            bgView.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.top.equalTo(0)
                make.bottom.equalTo(10)
            })
        }
        let review = self.reviews[indexPath.section] as! ZMDProductComment
        let bgView = cell?.contentView.viewWithTag(10000)
        self.updateHeaderViewBg(bgView!,review:review)
        return cell!
    }
    //MARK: --图片cell
    func cellForPhotos(tableView:UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TextAndImageCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
            
        }
        return cell!
    }
    //MARK: --商品faceViewCell
    func cellForFaceView(tableView:UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "ProductComment"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
        }
        return cell!
    }
    //MARK: --店铺评分Cell
    func cellForStoreComment(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        
        let cellId = "StoreComment"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
            
            let storeCommentView = self.configStoreComment()
            storeCommentView.tag = 10000
            cell?.contentView.addSubview(storeCommentView)
        }
        return cell!
    }
    
    //MARK: - **********PrivateMethod*************
    func subViewInit() {
        self.view.backgroundColor = defaultBackgroundGrayColor
        let rect = self.view.bounds
        let navigationBarH = self.navigationController?.navigationBar.frame.height
        let statusBarH = UIApplication.sharedApplication().statusBarFrame.height
        self.currentTableView = UITableView(frame:CGRect(x: 0, y: 0, width: rect.width, height: rect.height-100-navigationBarH!-statusBarH), style: .Plain)
        self.currentTableView.delegate = self
        self.currentTableView.dataSource = self
        self.currentTableView.separatorStyle = .None
        self.currentTableView.bounces = false
        self.currentTableView.backgroundColor = RGB(246,246,246,1.0)
        self.view.addSubview(self.currentTableView)
        
        let botView = self.configFootView()
        self.view.addSubview(botView)
        botView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(100)
        }
    }
    
    //MARK:数据请求
    func updateData() {
        QNNetworkTool.fetchCommentsList(self.orderId.integerValue) { (success, error, reviews) -> Void in
            if success == true {
                self.reviews.removeAllObjects()
                self.reviews.addObjectsFromArray(reviews as![AnyObject])
                for _ in self.reviews {
                    self.rates.addObject(100)
                    self.textImageCellHeights.addObject(190)     //用于记录textImageCell的height,默认为190
                    self.photoCellHeights.addObject(90)                //用于记录photoCell的height,默认为90
                    self.photos.addObject(NSMutableArray())
                    self.selectedAssets.addObject(NSMutableArray())
                    self.rateBtns.addObject(NSMutableArray())
                    self.comments.addObject("")
                }
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: error)
            }
        }
    }
    
    //MARK:数据判断
    func checkData() {
        var count = 0
        for i in 0..<self.reviews.count {
            let rate = self.rates[i] as! Int
            let comment = self.comments[i] as! String
            if rate != 5 && comment == "" {
                break
            }
            count = count + 1
        }
        if count == self.reviews.count {
            self.canSubmit = true
            self.submitBtn.backgroundColor = defaultSelectColor
        }else{
            self.canSubmit = false
            self.submitBtn.backgroundColor = grayButtonBackgroundColor
        }
    }
    //MARK: --configTextImageBgView()
    func configTextImageBgView(section:Int) -> UIView {
//        let cellHeight = 190
        let bgView = UIView(frame: CGRectZero)
        bgView.tag = 10000
        bgView.backgroundColor = UIColor.whiteColor()
        ZMDTool.configViewLayer(bgView)
        ZMDTool.configViewLayerFrame(bgView)
        let imgView = UIImageView(frame: CGRect.zero)
        imgView.tag = 10001
        bgView.addSubview(imgView)
        imgView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(12)
            make.left.equalTo(12)
            make.size.equalTo(CGSizeMake(75, 75))
        }
        
        let textView = ZMDTool.getTextView(CGRect.zero, placeholder: "感谢您的宝贵评价~", fontSize: 15)
        textView.delegate = self
        textView.scrollEnabled = false
        textView.tag = 1000+section
        bgView.addSubview(textView)
        textView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(imgView.snp_right).offset(10)
            make.right.equalTo(-12)
            make.top.equalTo(12)
            make.bottom.equalTo(-12)
        }
        return bgView
    }
    
    //MARK: --configureFootView
    func configFootView() -> UIView {
        
        let botView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        botView.backgroundColor = RGB(246,246,246,1.0)
        let font = UIFont.systemFontOfSize(15)
        let width = "匿名评价".sizeWithFont(font, maxWidth: 120).width+22
        self.checkBtn = UIButton(frame: CGRect(x: kScreenWidth-15-width, y: 10, width: width, height: 20))
        checkBtn.setImage(UIImage(named: "cb_glossy_off"), forState: .Normal)
        checkBtn.setImage(UIImage(named: "cb_glossy_on"), forState: .Selected)
        checkBtn.setTitle("匿名评价", forState: .Normal)
        checkBtn.setTitleColor(defaultTextColor, forState: .Normal)
        checkBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        checkBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        checkBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            self.IsAnonymous = (sender as! UIButton).selected
            return RACSignal.empty()
        })
        botView.addSubview(checkBtn)
        
        self.submitBtn = ZMDTool.getButton(CGRect(x: 12, y: /*kScreenHeight - 64 - 50 - 10*/CGRectGetMaxY(checkBtn.frame)+10, width: kScreenWidth-24, height: 50), textForNormal: "提交", fontSize: 17, backgroundColor: grayButtonBackgroundColor) { (sender) -> Void in
            if self.canSubmit == false {
                ZMDTool.showPromptView("请完善商品评价信息")
                return
            }
            self.submitComments()
        }
        botView.addSubview(submitBtn)
        ZMDTool.configViewLayerWithSize(submitBtn, size: 25)
        
        return botView
    }
    
    //MARK: --configureStoreComment
    func configStoreComment() -> UIView {
        let storeCommentView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 158)) //146 = (26+17)*3+17+15+9)
        
        // 商品评分
        let scoreLbl = ZMDTool.getLabel(CGRectMake(12, 12, 120, 17), text: "店铺评分 :", fontSize: 18)
        scoreLbl.textAlignment = .Left
        storeCommentView.addSubview(scoreLbl)
        
        // 描述相符
        let goodsScoreTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "描述相符 :", fontSize: 17)
        storeCommentView.addSubview(goodsScoreTitleLbl)
        let goodsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(scoreLbl.frame)+12, width: 32*5, height: 26)) { (str, point) -> Void in
            self.goodsScoreRigthLbl.text = str as String
            self.descriptionPoint = 2*(point+1)
        }
        storeCommentView.addSubview(goodsScoreView)
        self.goodsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(goodsScoreRigthLbl)
        
        // 服务态度
        let serverScoreLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "服务态度 :", fontSize: 17)
        storeCommentView.addSubview(serverScoreLbl)
        let serverScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+17, width: 32*5, height: 26)){(str, point) ->Void in
            self.serverScoreRightLbl.text = str as String
            self.servicePoint = 2*(point+1)
        }
        storeCommentView.addSubview(serverScoreView)
        self.serverScoreRightLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(serverScoreRightLbl)
        
        // 物流态度
        let logisticsitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "物流态度 :", fontSize: 17)
        storeCommentView.addSubview(logisticsitleLbl)
        let logisticsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(serverScoreLbl.frame)+17, width: 32*5, height: 26)){(str, point) ->Void in
            self.logisticsScoreRigthLbl.text = str as String
            self.logisticsPoint = 2*(point+1)
        }
        storeCommentView.addSubview(logisticsScoreView)
        self.logisticsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(logisticsScoreRigthLbl)
        
        return storeCommentView
    }
    
    
    //MARK: 提交评论
    func submitComments() {
        let arr = NSMutableArray()
        for i in 0..<self.reviews.count {
            let review = self.reviews[i] as! ZMDProductComment
            let orderItemModel = review.OrderItemModel
            let reviewText = self.comments[i] as! String
            let rate = self.rates[i] as! Int
            let dic : NSDictionary = ["CustomerId":g_customerId!,"ReviewText":reviewText,"Rating":rate,"OrderItemId": orderItemModel.Id.integerValue,"ProductId": orderItemModel.ProductId.integerValue,"OrderId": self.orderId.integerValue,"IsAnonymous": self.IsAnonymous]
            arr.addObject(dic)
        }
        let params = ["customerId":g_customerId!,"reviews":arr]
        
        //1.文字、rate评价 -> 晒图
        QNNetworkTool.addComments(params as NSDictionary) { (success, error, productReviews) -> Void in
            if success! {
                if let productReviews = productReviews {
                    for i in 0..<productReviews.count {
                        let productReview = productReviews[i] as! ZMDCommentItem
                        let params : NSDictionary = ["productReviewId":productReview.Id.integerValue,"displayOrder":0]
                        let datas = self.photos[i] as! NSArray
                        let group = dispatch_group_create()
                        for i in 0..<datas.count {
                            //在group中开启异步任务上传图片
                            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                                let image = datas[i] as! UIImage
                                let size = CGSizeMake(image.size.width, image.size.height)
                                let file = UIImageJPEGRepresentation(self.imageWithImageSimple(image, scaledSize: size), 0.125) //压缩
                                let fileName = QNFormatTool.dateString(NSDate()) + "\(i).png"
                                
                                QNNetworkTool.uploadCommentPicture(file!, fileName: fileName, params: params, completion: { (succeed, error) -> Void in
                                    if succeed == true {
                                        
                                    }else{
                                        //                                        ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "上传图片失败")
                                    }
                                })
                            })
                        }
                        //监听group完成后 UI提示
                        dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                            self.commonAlertShow(false, title: "评价成功", message: "您的评价已提交成功!", preferredStyle: .Alert)
                            self.isCommented = true
                        })
                    }
                }
            }else{
                self.commonAlertShow(false, title: "评价失败", message: "评论失败,请稍后再试!", preferredStyle: .Alert)
            }
        }
        
        
        //2.店铺评分
        /*QNNetworkTool.addStoreComments(self.descriptionPoint, service: self.servicePoint, logistics: self.logisticsPoint, orderId: self.orderId.integerValue, customerId: g_customerId!) { (success, error) -> Void in
        if success! {
        
        }else{
        ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: error)
        }
        }*/
    }
    
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    //MARK: - ****************Delegate******************
    //MARK:UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let mulStr = NSMutableString(string: textView.text!)
        mulStr.replaceCharactersInRange(range, withString: text)
        submitBtn.backgroundColor = mulStr.length == 0 ? grayButtonBackgroundColor : defaultSelectColor
        submitBtn.userInteractionEnabled = mulStr.length == 0 ? false : true
        
        let section = textView.tag-1000
        let size = (mulStr as String).sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: kScreenWidth-2*12-2*10)
        if size.height < 190-12*2 {
            self.textImageCellHeights[section] = 190
        }else{
            self.textImageCellHeights[section] = 190+size.height-(190-12*2)
        }
        return true
    }

    func textViewDidChange(textView: UITextView) {
        let label = textView.viewWithTag(10000) as! UILabel
        label.hidden = textView.text != ""
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let section = textView.tag-1000
        self.comments.replaceObjectAtIndex(section, withObject: textView.text)
        self.checkData()
        self.currentTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
