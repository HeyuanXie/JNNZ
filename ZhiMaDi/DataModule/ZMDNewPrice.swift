//
//  ZMDNewPrice.swift
//  ZhiMaDi
//
//  Created by admin on 16/10/28.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

//多属性选择后新价格
class ZMDNewPrice: NSObject {
    var Old : ZMDPrice!
    var WithoutDiscount : ZMDPrice!
    var WithDiscount : ZMDPrice!
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Old":ZMDPrice.classForCoder(),"WithoutDiscount":ZMDPrice.classForCoder(),"WithDiscount":ZMDPrice.classForCoder()]
    }
}

class ZMDPrice:NSObject {
    var Value : String!
    var Text : String!
}
