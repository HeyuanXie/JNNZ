//
//  MyWebViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/9/20.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import WebKit

class MyWebViewController: UIViewController {
    
    var webUrl:NSURL!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
    }

    func initUI() {
        
        self.configBackButton()
        self.configMoreButton()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        ZMDTool.showActivityView(nil)
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        lbl.text = APP_NAME
        lbl.textColor = RGB(79/255,79/255,79/255,1)
        lbl.textAlignment = .Center
        lbl.font = UIFont.systemFontOfSize(17)
        self.navigationItem.titleView = lbl
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = RGB(79/255,79/255,79/255,1)
        
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        let wkContentVC = WKUserContentController()
        wkContentVC.addUserScript(wkScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkContentVC
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64), configuration: wkWebConfig)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(webView)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            webView.loadRequest(NSURLRequest(URL: self.webUrl))
            ZMDTool.hiddenActivityView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
