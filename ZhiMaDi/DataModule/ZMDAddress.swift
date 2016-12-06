//
//  ZMDAddress.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/20.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 地址
class ZMDAddress: NSObject {
    var FirstName:String!        //John,
    var Email:String?            //null,
    var CountryId:NSNumber?        //23,
    var City:String?             //市辖区,
    var Address1:String?         //北京市市辖区东城区东华门街道,
    var Address2:String?         //北京街道,
    var PhoneNumber:String!      //13685685685,
    var IsDefault:NSNumber!        //false,
    var AreaCode:String?         //110101001,
    var Id:NSNumber!               //1
    var FaxNumber:String?
}

class ZMDDSAddress: NSObject {
    var Id:NSNumber!    //7
    var Name:String!    //"对方"
    var Phone:String!   //"广东省广州市"
    var Address1:String!
    var Address2:String!
    var AreaCode:String?
    var AreaName:String?
    var StoreId:NSNumber?
}
