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
        movie1.Title = "Inglourious B*****ds"
        movie1.Id = "cbe99dbf-4438-4eb5-88f1-219e06e034ab"
        movie1.ImagePackshotUrl = "http://qs.int.skystore.com/api/img/asset/en/66D8BB8A-E4E8-4422-9242-603110084545_DF2BEBBD-D25D-463E-930B-002767E151B9_2015-10-17-T18-50-34.jpg?s=260x371"
        result.append(movie1)
        
        return result;
    }
}
