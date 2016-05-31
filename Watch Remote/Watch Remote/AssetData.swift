//
//  AssetData.swift
//  Watch Remote
//
//  Created by Rodrigues, Nuno on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import Foundation

class AssetData {
    private var _id : String = ""
    var Id : String {
        set { _id = newValue }
        get { return _id }
    }
    
    private var _title : String = ""
    var Title : String {
        set { _title = newValue }
        get { return _title }
    }
    
    private var _imagePackshotUrl : String = ""
    var ImagePackshotUrl : String {
        set { _imagePackshotUrl = newValue }
        get { return _imagePackshotUrl }
    }
    
    private var _remotePlaybackUrl : String = ""
    var RemotePlaybackUrl : String {
        set { _remotePlaybackUrl = newValue }
        get { return _remotePlaybackUrl }
    }
}