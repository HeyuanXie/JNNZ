//
//  AlertViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/10/24.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class AlertViewController: UIAlertController {

    var destructiveAction: UIAlertAction!
    var cancelAction: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    func commonAlert(title:String,message:String,style:UIAlertControllerStyle) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(self.destructiveAction)
        alert.addAction(self.cancelAction)
        return alert
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
