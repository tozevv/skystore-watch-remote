//
//  Roku.swift
//  Watch Remote
//
//  Created by Vieira, Antonio (Technology) on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import Foundation
import UIKit

class RokuRemote
{
    var rokuBoxIp: String!
    
    init(ipAddress: String) {
        rokuBoxIp = ipAddress
    }

    func sendCommand(keypressed: String)
    {
        if let url: NSURL = NSURL(string: "http://\(rokuBoxIp):8060/keypress/\(keypressed)") {
            
            print(url)
            
            let urlSession = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            
            let dataTask = urlSession.dataTaskWithRequest(request, completionHandler: {
                (data,_,error) in print("done", data,error)
            } )
            dataTask.resume()
        }
    }
    
    static func Current() -> RokuRemote
    {
        return RokuRemote(ipAddress: boxIp);
    }
    
}