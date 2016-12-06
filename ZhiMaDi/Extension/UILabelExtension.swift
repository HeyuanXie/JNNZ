//
//  UILabelExtension.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

extension UILabel {
    //在label竖直方向的中间添加横线
    func addCenterYLine(){
        let text = self.text ?? ""
        let font = self.font
        let size = text.sizeWithFont(font, maxWidth: 200)
        let line = ZMDTool.getLine(CGRectZero, backgroundColor: UIColor.darkGrayColor())
        self.addSubview(line)
        line.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(-2)
            make.width.equalTo(size.width+4)
            make.top.equalTo(self.frame.size.height/2)
            make.height.equalTo(1)
        }
    }
}
