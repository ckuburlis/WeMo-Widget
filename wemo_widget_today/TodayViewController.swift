//
//  TodayViewController.swift
//  wemo_widget_today
//
//  Created by Chris Kuburlis on 28/09/2014.
//  Copyright (c) 2014 Chris Kuburlis. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, NSURLConnectionDataDelegate, WemoWidgetDelegate {
    
    var ww :WemoWidget?
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBAction func segmentAction(sender: AnyObject) {
        buttonPressed()
    }
    
    func buttonPressed() {
        println("Selected:\(segmentOutlet.titleForSegmentAtIndex(segmentOutlet.selectedSegmentIndex)!)")
        ww?.setStatus(LightState(rawValue: segmentOutlet.selectedSegmentIndex)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ww = WemoWidget(delegate: self)
        // Do any additional setup after loading the view from its nib.
        segmentOutlet.selectedSegmentIndex = UISegmentedControlNoSegment
        segmentOutlet.userInteractionEnabled = false
        
        if (ww?.avaliable ?? false) {
            segmentOutlet.userInteractionEnabled = true
        }
        
    }
    
    func updateStatus(state: Bool?) {
        
        if let light = state {
            segmentOutlet.selectedSegmentIndex = (light ? 1 : 0)
        } else {
            segmentOutlet.selectedSegmentIndex = UISegmentedControlNoSegment
        }
        
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}
