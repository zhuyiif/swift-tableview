//
//  http.swift
//  TableViewTest
//
//  Created by yi zhu on 2/28/17.
//  Copyright © 2017 zackzhu. All rights reserved.
//

import Foundation

//use URLSesson get data
func httpGet(request: NSURLRequest!, callback: @escaping (Data, String?) -> Void) {
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest){
        (data, response, error) -> Void in
        if error != nil {
            callback(Data(), error?.localizedDescription)
        } else {
            
            callback(data!, nil)
        }
    }
    task.resume()
}

