//
//  MyLibraryController.swift
//  Watch Remote
//
//  Created by Rodrigues, Nuno on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import Foundation

import WatchKit
import Foundation
import WatchConnectivity

class MyLibraryController: WKInterfaceController {
    
    @IBOutlet var mainTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let apiHandler = ApiHandler();
        let list = apiHandler.myLibrary()
        
        mainTable.setNumberOfRows(list.count, withRowType: "AssetRow")
      
        for i in 0 ..< list.count {
            let row = mainTable.rowControllerAtIndex(i)
            if ((row as? AssetRow) != nil) {
                let row2 = row as? AssetRow;
                row2!.titleLabel.setText(list[i].Title)
            }
        }
    }
    
}