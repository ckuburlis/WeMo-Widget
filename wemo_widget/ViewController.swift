//
//  ViewController.swift
//  wemo_widget
//
//  Created by Chris Kuburlis on 28/09/2014.
//  Copyright (c) 2014 Chris Kuburlis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    NSUserDefaults share to store settings (shared with widget)
    let sharedDefaults = NSUserDefaults(suiteName: "group.k-dev.WemoWidgetSharingDefaults")
    
    @IBOutlet weak var IPAddressTextBox: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBAction func saveButton(sender: AnyObject) {

//        hides keyboard
        IPAddressTextBox.resignFirstResponder()

//        Puts string in NSUserDefaults and synchronises to save changes
        sharedDefaults?.setObject(IPAddressTextBox.text, forKey: "IPAddress")
        sharedDefaults?.synchronize()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        Fills textbox with previously set IP or an empty string
        IPAddressTextBox.text = sharedDefaults?.stringForKey("IPAddress") ?? ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

