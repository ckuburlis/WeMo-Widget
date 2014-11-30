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
//        set the light status to the selected segment
//        segment 0 = off, 1 = on
        ww?.setStatus(LightState(rawValue: segmentOutlet.selectedSegmentIndex)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
//        initialise backend
        ww = WemoWidget(delegate: self)
        
//        deselect segment & disable user interaction
        segmentOutlet.selectedSegmentIndex = UISegmentedControlNoSegment
        segmentOutlet.userInteractionEnabled = false
        
//        if WeMo avaliable then enable user interaction
        if (ww!.avaliable) {
            segmentOutlet.userInteractionEnabled = true
        }
        
    }
    
    func newStatus(state: Bool?) {
        
        if let light = state {
//            if there's a valid light state,
//            false = off (segment 0), true = on (segment 1)
            segmentOutlet.selectedSegmentIndex = (light ? LightState.On.rawValue : LightState.Off.rawValue)
        } else {
//            deselect
            segmentOutlet.selectedSegmentIndex = UISegmentedControlNoSegment
        }
        
    }
    
//    needed so that the widget fills the whole super view area (doesn't have the weird offset & border)
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}
