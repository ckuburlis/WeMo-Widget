//
//  WemoWidget.swift
//  wemo_widget
//
//  Created by Chris Kuburlis on 11/11/2014.
//  Copyright (c) 2014 Chris Kuburlis. All rights reserved.
//

import Foundation

protocol WemoWidgetDelegate {
    func newStatus(state: Bool?)
}

enum LightState : Int {
    case Off = 0
    case On = 1
}

class WemoWidget: NSObject, NSURLConnectionDataDelegate {

    var delegate :WemoWidgetDelegate?
    
    private let Ports :[NSNumber] = [49152,49153,49154,49155] //possible wemo ports
    private let sharedDefaults = NSUserDefaults(suiteName: "group.k-dev.WemoWidgetSharingDefaults") //settings
    
    var avaliable : Bool = false
    var lightOn : Bool?
    
    private var ip : String?
    
    init(delegate: WemoWidgetDelegate?) {
        super.init()
        
        self.delegate = delegate
        
//        try get the IP Address set in the app... if not set, loop back to self (esentially do nothing)
        ip = sharedDefaults?.stringForKey("IPAddress") ?? "127.0.0.1"
        
        if (wifiConnected()) {
                avaliable = true;
                self.getStatus()
            //check current status
            //if user action before check completes, use user action to check
        }
        
    }
    
    /**
    Check if device is connected to WiFi
    
    :returns: Bool of WiFi status
    */
    private func wifiConnected() -> Bool {
        return (Reachability.isConnectedToNetworkOfType() == .WiFi)
    }
    
    /**
    Sets the lights value (on/off)
    
    :param: lightStatus The state to change the light to
    */
    func setStatus(lightStatus: LightState) {
       request(lightStatus)
    }
    
    /**
    Gets the status of the light
    */
    private func getStatus() {
        request(nil)
    }
    
    /**
    Sends a request to the WeMo
    
    :param: state either on/off to change state, or nil to query state
    */
    private func request(state: LightState?) {

//       for every WeMo port
        for port in Ports {
            
//            Set up a HTTP POST request
            
            let baseURL :NSURL = NSURL(string: "http://\(ip!):\(port)/upnp/control/basicevent1")!
            let request = NSMutableURLRequest(URL: baseURL)
            
            request.HTTPMethod = "POST"
            request.timeoutInterval = 2
            
//            if state is nil, it's a get request, otherwise a set
            let action :String = (state == nil) ? "Get" : "Set"
            
//            Set Headers
            request.addValue("", forHTTPHeaderField: "Accept")
            request.addValue("text/xmlcharset=\"utf-8\"", forHTTPHeaderField:"Content-Type")
            request.addValue("\"urn:Belkin:service:basicevent:1#\(action)BinaryState\"", forHTTPHeaderField: "SOAPACTION")
            
//            long, not friendly XML to be sent in request
//            if state = nil, it's a get request, so value doesn't matter (but has to be something) so we default to 1
//            action is either "Set" or "Get"
            let data = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:\(action)BinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\"><BinaryState>\(state?.rawValue ?? 1)</BinaryState></u:\(action)BinaryState></s:Body></s:Envelope>"
            
            //Adds the data to the request body
            request.HTTPBody = NSData(bytes: data, length: countElements(data))
            
            // Creats new connection to WeMo and sends request
            let connection = NSURLConnection(request: request, delegate: self)
            connection?.start()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
//        the data recieved back (in XML form)
        let input = NSString(data: data, encoding: NSUTF8StringEncoding)
        
//        easier to search for simple string than parse XML
        let on  = input?.rangeOfString("<BinaryState>1</BinaryState>").length
        let off = input?.rangeOfString("<BinaryState>0</BinaryState>").length
        
//        if string length is greater than 0 then there's a match
        if (on > 0) {
            lightOn = true
        } else if (off > 0) {
            lightOn = false
        } else {
            lightOn = nil
        }
       
//        tell delegate the new status
        delegate?.newStatus(lightOn)
    }
    
}