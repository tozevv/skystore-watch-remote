//
//  ApiHandler.swift
//  Watch Remote
//
//  Created by Rodrigues, Nuno on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import Foundation

class ApiHandler {
    func myLibrary() -> [AssetData]
    {
        var result = [AssetData]();
        
        let movie1 = AssetData();
        movie1.Title = "Movie #1"
        movie1.Id = "211ae9e1-8c10-4fcf-b260-eb6dadf3b1ad"
        movie1.ImagePackshotUrl = "http://qs.int.skystore.com/api/img/asset/en/66D8BB8A-E4E8-4422-9242-603110084545_C73B3A14-85C9-47E6-A329-DEB3E52329E2_2016-1-11-T15-10-58.jpg?s=260x371"
        result.append(movie1)
        
        return result;
    }
}
