//
//  WemoWidget.swift
//  wemo_widget
//
//  Created by Chris Kuburlis on 11/11/2014.
//  Copyright (c) 2014 Chris Kuburlis. All rights reserved.
//

import Foundation

protocol WemoWidgetDelegate {
    func updateStatus(state: Bool?)
}

enum LightState : Int {
    case Off = 0
    case On = 1
}

class WemoWidget: NSObject, NSURLConnectionDataDelegate {

    var delegate :WemoWidgetDelegate?
    
    private let Ports :[NSNumber] = [49152,49153,49154,49155] //possible wemo ports
    
    private let sharedDefaults = NSUserDefaults(suiteName: "group.k-dev.WemoWidgetSharingDefaults")
    
    var avaliable : Bool = false
    var lightOn : Bool?
    
    private var ip : String?
    
    init(delegate: WemoWidgetDelegate?) {
        super.init()
        
        self.delegate = delegate
        
        ip = sharedDefaults?.stringForKey("IPAddress") ?? "192.168.1.196"
        
        if (wifiConnected()) { //wifi is connected
                avaliable = true;
                self.getStatus()
            //check current status
            //if user action before check completes, use user action to check
        }
        
    }
    
    private func wifiConnected() -> Bool {
        return (Reachability.isConnectedToNetworkOfType() == .WiFi)
    }
    
    func setStatus(lightStatus: LightState) {
       request(lightStatus)
    }
    
    private func getStatus() {
        request(nil)
    }
    
    private func request(state: LightState?) {
        for port in Ports {
            var baseURL :NSURL = NSURL(string: "http://\(ip!):\(port)/upnp/control/basicevent1")!
            
            var request = NSMutableURLRequest(URL: baseURL)
            
            request.HTTPMethod = "POST"
            request.timeoutInterval = 2
            // Headers
            request.addValue("", forHTTPHeaderField: "Accept")
            request.addValue("text/xmlcharset=\"utf-8\"", forHTTPHeaderField:"Content-Type")
            
            var data :String
            
            if let newLightState = state {
                //change light status
                request.addValue("\"urn:Belkin:service:basicevent:1#SetBinaryState\"", forHTTPHeaderField: "SOAPACTION")
                
                data = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:SetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\"><BinaryState>\(newLightState.rawValue)</BinaryState></u:SetBinaryState></s:Body></s:Envelope>"
                
            } else {
                //check light status
                request.addValue("\"urn:Belkin:service:basicevent:#GetBinaryState\"", forHTTPHeaderField: "SOAPACTION")
                
                data = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:GetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>"
                
            }
            
            //body
            request.HTTPBody = NSData(bytes: data, length: countElements(data))
            
            
            // Connection
            let connection = NSURLConnection(request: request, delegate: self)
            connection?.start()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        let input = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        let on  = input?.rangeOfString("<BinaryState>1</BinaryState>").length
        let off = input?.rangeOfString("<BinaryState>0</BinaryState>").length
        
        if (on > 0) {
            lightOn = true
        } else if (off > 0) {
            lightOn = false
        } else {
            lightOn = nil
        }
       
        delegate?.updateStatus(lightOn)
        
    }
    
}