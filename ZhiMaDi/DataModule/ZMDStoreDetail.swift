//
//  ZMDStoreDetail.swift
//  ZhiMaDi
//
//  Created by admin on 16/9/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

class ZMDStoreDetail: NSObject {
    var Name: String!
    var Host: String!
    var Url:String!
    var PictureUrl:String!
    var Id:NSNumber!
    var LogoPictureId : NSNumber!
    var Products:[ZMDProduct]!
    var AvailableCategories: [ZMDStoreCategory]?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Products":ZMDProduct.classForCoder(),"AvailableCategories":ZMDStoreCategory.classForCoder()]
    }
}

class ZMDOrderTotal: NSObject {
    
    var SubTotal: String! //	小计不包含运费
    var Shipping: String!	//	运费
    var OrderTotalDiscount: String!     //	折扣优惠
    var OrderTotal: String!//实付，（含运费）
    
}

class ZMDSingleStoreTotal: NSObject {
    var SubTotal:String?                //店铺内商品小计(不包括运费)
    var Shipping:String?                //运费
    var OrderTotalDiscount:String?       //折扣优惠
    var OrderTotal:String?              //总计
}
