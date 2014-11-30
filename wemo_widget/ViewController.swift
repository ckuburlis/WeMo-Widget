//
//  ViewController.swift
//  wemo_widget
//
//  Created by Chris Kuburlis on 28/09/2014.
//  Copyright (c) 2014 Chris Kuburlis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var IPAddressTextBox: UITextField!
    @IBOutlet weak var portTextBox: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBAction func saveButton(sender: AnyObject) {

        IPAddressTextBox.resignFirstResponder()
        portTextBox.resignFirstResponder()
        
        
        let sharedDefaults = NSUserDefaults(suiteName: "group.k-dev.WemoWidgetSharingDefaults")

        sharedDefaults?.setObject(IPAddressTextBox.text, forKey: "IPAddress")
        
        sharedDefaults?.synchronize()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let sharedDefaults = NSUserDefaults(suiteName: "group.k-dev.WemoWidgetSharingDefaults")
        
        IPAddressTextBox.text = sharedDefaults?.objectForKey("IPAddress") as String!
//        portTextBox.text = sharedDefaults?.objectForKey("port") as String!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

