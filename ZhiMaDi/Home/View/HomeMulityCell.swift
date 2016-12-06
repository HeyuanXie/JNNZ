//
//  HomeMulityCell.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.

import UIKit

class HomeMulityGoodTopCell: UITableViewCell {

    @IBOutlet weak var leftView : UIView!
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var bottomView : UIView!
    @IBOutlet weak var verticalLine : UILabel!
    @IBOutlet weak var horizontalLine : UILabel!
    
    var products : NSArray!
    var btnClickFinish : ((productId:Int)->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: CGRectGetWidth(self.bottomView.frame), height: 0.5), backgroundColor: defaultLineColor))
        self.topView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: 0.5, height: CGRectGetHeight(self.topView.frame)), backgroundColor: defaultLineColor))
        self.bottomView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: 0.5, height: CGRectGetHeight(self.bottomView.frame)), backgroundColor: defaultLineColor))
    }
    
    //MARK: IBAction
    
    @IBAction func leftBtnClick(sender: UIButton) {
        let product = self.products[0] as! ZMDProduct
        if self.btnClickFinish != nil {
            self.btnClickFinish(productId: product.Id.integerValue)
        }
    }
    
    @IBAction func topBtnClick(sender: UIButton) {
        let product = self.products[1] as! ZMDProduct
        if self.btnClickFinish != nil {
            self.btnClickFinish(productId: product.Id.integerValue)
        }
    }
    
    @IBAction func botBtnClick(sender: UIButton) {
        let product = self.products[2] as! ZMDProduct
        if self.btnClickFinish != nil {
            self.btnClickFinish(productId: product.Id.integerValue)
        }
    }
    
    func updateUI(data:NSArray) {
        let productLeft : ZMDProduct = data[0] as! ZMDProduct
        let productTop : ZMDProduct = data[1] as! ZMDProduct
        let productBot : ZMDProduct = data[2] as! ZMDProduct
//        if let data0 = data[0] as? ZMDProduct,data1 = data[1] as? ZMDProduct,data2 = data[2] as? ZMDProduct {
//            productLeft = data0
//        }
        let titleLblLeft = self.leftView.viewWithTag(10001) as! UILabel
        let detailLblLeft = self.leftView.viewWithTag(10002) as! UILabel
        let priceLblLeft = self.leftView.viewWithTag(10003) as! UILabel
        let imgViewLeft = self.leftView.viewWithTag(10004) as! UIImageView
        titleLblLeft.text = productLeft.Name
//        detailLblLeft.text = productLeft.ShortDescription
        detailLblLeft.text = productLeft.ProductPrice?.Price
//        priceLblLeft.text = productLeft.ProductPrice?.Price
        imgViewLeft.sd_setImageWithURL(NSURL(string: kImageAddressMain+(productLeft.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
        
        let titleLblTop = self.topView.viewWithTag(10001) as! UILabel
        let detailLblTop = self.topView.viewWithTag(10002) as! UILabel
        let priceLblTop = self.topView.viewWithTag(10003) as! UILabel
        let imgViewTop = self.topView.viewWithTag(10004) as! UIImageView
        titleLblTop.text = productTop.Name
        detailLblTop.text = productTop.ProductPrice?.Price
//        detailLblTop.text = productTop.ShortDescription
//        priceLblTop.text = productTop.ProductPrice?.Price
        //        imgViewLeft.image = UIImage(named: "home_banner02")
        imgViewTop.sd_setImageWithURL(NSURL(string: kImageAddressMain+(productTop.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)

        let titleLblBot = self.bottomView.viewWithTag(10001) as! UILabel
        let detailLblBot = self.bottomView.viewWithTag(10002) as! UILabel
        let priceLblBot = self.bottomView.viewWithTag(10003) as! UILabel
        let imgViewBot = self.bottomView.viewWithTag(10004) as! UIImageView
        titleLblBot.text = productBot.Name
        detailLblBot.text = productBot.ProductPrice?.Price
//        detailLblBot.text = productBot.ShortDescription
//        priceLblBot.text = productBot.ProductPrice?.Price
        //        imgViewLeft.image = UIImage(named: "home_banner02")
        imgViewBot.sd_setImageWithURL(NSURL(string: kImageAddressMain+(productBot.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class HomeMulityGoodBottomCell: UITableViewCell {
    @IBOutlet weak var leftView : UIView!
    @IBOutlet weak var rightView : UIView!
    
    var products : NSArray!
    var btnClickFinish : ((productId:Int)->Void)!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.leftView.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth/2-0.5, y: 0, width: 0.5, height: CGRectGetHeight(self.leftView.frame)), backgroundColor: defaultLineColor))
    }
    
    //MARK: IBAction
    @IBAction func leftBtnClick(sender: UIButton) {
        let product = self.products[3] as! ZMDProduct
        if self.btnClickFinish != nil {
            self.btnClickFinish(productId: product.Id.integerValue)
        }
    }
    
    @IBAction func rightBtnClick(sender: UIButton) {
        let product = self.products[4] as! ZMDProduct
        if self.btnClickFinish != nil {
            self.btnClickFinish(productId: product.Id.integerValue)
        }
    }
    
    func updateUI(data:NSArray) {
        let productLeft = data[3] as! ZMDProduct
        let productRight = data[4] as! ZMDProduct
        let titleLblLeft = self.leftView.viewWithTag(10001) as! UILabel
        let detailLblLeft = self.leftView.viewWithTag(10002) as! UILabel
        let priceLblLeft = self.leftView.viewWithTag(10003) as! UILabel
        let imgViewLeft = self.leftView.viewWithTag(10004) as! UIImageView
        titleLblLeft.text = productLeft.Name
        detailLblLeft.text = productLeft.ProductPrice?.Price
//        detailLblLeft.text = productLeft.ShortDescription
//        priceLblLeft.text = productLeft.ProductPrice?.Price
        //        imgViewLeft.image = UIImage(named: "home_banner02")
        imgViewLeft.sd_setImageWithURL(NSURL(string: kImageAddressMain+(productLeft.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
        
        let titleLblRight = self.rightView.viewWithTag(10001) as! UILabel
        let detailLblRight = self.rightView.viewWithTag(10002) as! UILabel
        let priceLblRight = self.rightView.viewWithTag(10003) as! UILabel
        let imgViewRight = self.rightView.viewWithTag(10004) as! UIImageView
        titleLblRight.text = productRight.Name
        detailLblRight.text = productRight.ProductPrice?.Price
//        detailLblRight.text = productRight.ShortDescription
//        priceLblRight.text = productRight.ProductPrice?.Price
        //        imgViewLeft.image = UIImage(named: "home_banner02")
        imgViewRight.sd_setImageWithURL(NSURL(string: kImageAddressMain+(productRight.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
