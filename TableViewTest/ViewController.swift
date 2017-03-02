//
//  ViewController.swift
//  TableViewTest
//
//  Created by yi zhu on 2/28/17.
//  Copyright © 2017 zackzhu. All rights reserved.
//

import UIKit
import Nuke

// MARK: global

let CellID = "Cell";
let AssetsUrl = "https://d3q6cnmfgq77qf.cloudfront.net/keyboards/ellen/v2/assets_ios.json"

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var tableView:UITableView = UITableView()
    
    var imageArray:[String] = [String]()
    
    // MARK: Data process
    
    func fetchData() {
        let request = NSMutableURLRequest(url: NSURL(string: AssetsUrl)! as URL)
        httpGet(request: request){
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                
                let result = NSString(data: data, encoding:
                    String.Encoding.ascii.rawValue)!
                print(result)
                self.parsejsonDataToImageArray(jsonData: data)
                self.reloadTable()
            }
        }
    }
    
    //parse Json, only get asset_url
    func parsejsonDataToImageArray(jsonData : Data) {
        
        do {
            let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: [])
            
            if let dictionary = jsonObj as? [String: Any] {
                if let assetsArray = dictionary["assets"] as? [Any] {
                    for assetItem  in assetsArray {
                        if let assetItemDic = assetItem as? Dictionary<String, AnyObject>{
                            let url : String = assetItemDic["asset_url"] as! String
                            print(url)
                            imageArray.append(url)
                        }
                    }
                }
            }
        }
    }
    
    func initTableView() {
        // Do any additional setup after loading the view, typically from a nib.
        tableView.frame = self.view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID);
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        fetchData()
    }

    func reloadTable() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as UITableViewCell
        let urlString = imageArray[indexPath.row]
        let url = URL(string: urlString)
        
        cell.imageView?.image = nil
        
        // !!!If cached before, don't need call reloadtable again, otherwise will infinite loop
        let request = Request(url: url!)
        let cellImageView = cell.imageView!
        if Cache.shared[request] == nil {
            Nuke.loadImage(with: url!, into: cellImageView) { [weak cellImageView, weak self] response, _ in
                cellImageView?.image = response.value
                self?.reloadTable()
            }
        }
        else {
            Nuke.loadImage(with: url!, into: cellImageView)
        }
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
}

