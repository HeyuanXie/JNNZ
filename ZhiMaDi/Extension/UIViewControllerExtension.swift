//
//  UIViewControllerExtension.swift
//  QooccShow
//
//  Created by LiuYu on 14/11/3.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

import UIKit

//MARK:- 为 UIViewController ... 扩展一个公有的从storyboard构建的方法
extension UIViewController {
    //MARK: 从 Main.storyboard 初始化一个当前类
    // 从 Main.storyboard 中创建一个使用了当前类作为 StoryboardID 的类
    public class func CreateFromMainStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Main")
    }
    public class func CreateFromLoginStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Login")
    }
    public class func CreateFromStoreStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Store")
    }

    //MARK: 从 storyboardName.storyboard 初始化一个当前类
    // 从 storyboardName.storyboard 中创建一个使用了当前类作为 StoryboardID 的类
    public class func CreateFromStoryboard(name: String) -> AnyObject! {
        let classFullName = NSStringFromClass(self.classForCoder())
        let className = classFullName.componentsSeparatedByString(".").last as String! 
        let mainStoryboard = UIStoryboard(name: name, bundle:nil)
        return mainStoryboard.instantiateViewControllerWithIdentifier(className)
    }
    
    
}

//MARK:- 为 UIViewController ... 扩展一个 返回功能
extension UIViewController {
    @IBAction func back() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
            navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    @IBAction func gotoMsg() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
                navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    @IBAction func gotoMore() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
            navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
}

//MARK:- 为 UIViewController ... 提供一个标准的导航栏返回按钮配置
extension UIViewController {
    public func configBackButton() {
        let item = UIBarButtonItem(image: UIImage(named: "Navigation_Back")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.leftBarButtonItem = item
    }
    public func configMsgButton() {
        let item = UIBarButtonItem(image: UIImage(named: "Navi_Msg")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
    public func configMoreButton() {
        let item = UIBarButtonItem(image: UIImage(named: "common_more")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("gotoMore"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
}

//MARK: -为UIViewController 提供一个alertView弹出
//如果haveCancleBtn==false,则只需要用确定作为cancleBtn，并且不做任何操作a
extension UIViewController {
    public func commonAlertShow(haveCancleBtn:Bool,btnTitle1:String = "确定", btnTitle2:String = "取消", title: String, message: String, preferredStyle: UIAlertControllerStyle){
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if haveCancleBtn {
            let action1 = UIAlertAction(title: btnTitle1, style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                self.alertDestructiveAction()
            })
            let action2 = UIAlertAction(title: btnTitle2, style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
        }else{
            let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                self.alertSingleAction()
            })
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //点击commonAlert确定按钮执行的方法
    public func alertDestructiveAction() {
        print("alert确定")
    }
    public func alertSingleAction() {
        print("alert取消")
    }
}


extension UIViewController {
    public func pushToVC(vc:UIViewController,animated:Bool = true,hideBottom:Bool = true) {
        vc.hidesBottomBarWhenPushed = hideBottom
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}

extension UIViewController {
    public func botView(height:CGFloat = 56,backgroundColor:UIColor = defaultBackgroundGrayColor) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: self.view.bounds.height-height, width: kScreenWidth, height: height))
        view.backgroundColor = backgroundColor
        return view
    }
}