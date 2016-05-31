//
//  AssetRow.swift
//  Watch Remote
//
//  Created by Rodrigues, Nuno on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import Foundation
import UIKit
import WatchKit

class AssetRow : NSObject
{
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var packshotImage: WKInterfaceImage!
    
    var asset: AssetData? {
        didSet {
            if let asset = asset {
                titleLabel.setText(asset.Title)
            }
        }
    }
}