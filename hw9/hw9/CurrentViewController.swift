//
//  CurrentViewController.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/25/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Alamofire_Synchronous
class CurrentViewController: UIViewController, UITableViewDataSource {
    var json: JSON?
    var symbol: String = ""
    @IBOutlet weak var table: UITableView!
        
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIButton!
    

    
    let fields = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD", "High Price", "Low Price", "Opening Price"]
    var content = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let response = Alamofire.request(.GET, "http:www-scf.usc.edu/~zonghanc/index.php", parameters: ["symbol": symbol]).responseJSON()
        if let jsonObj = response.result.value {
            json = JSON(jsonObj)
        }
        
        
        if let json = json{
            self.title = json["Symbol"].stringValue
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        scroll.contentSize = CGSizeMake(scroll.frame.size.width, 1000)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        fillTable()
        setChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "historical" {
            let historical: HistoricalViewController = segue.destinationViewController as! HistoricalViewController
            historical.symbol = symbol
        }
        
        if segue.identifier == "news" {
            let news: NewsViewController = segue.destinationViewController as! NewsViewController
            news.symbol = symbol
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as! DetailCellTableViewCell
        
        cell.field?.text = fields[indexPath.row]
        cell.field.font = UIFont.boldSystemFontOfSize(12)
        cell.content?.text = content[indexPath.row]
    
        cell.content.font = UIFont.systemFontOfSize(12)
        if indexPath.row == 3 {
            if json!["ChangePercent"].doubleValue < 0{
                
                cell.arrow.image = UIImage(contentsOfFile: "/Users/zonghanchang/Documents/doc/course/csci571/hw9/hw9/Down.png")
            }
            else{
                cell.arrow.image = UIImage(contentsOfFile: "/Users/zonghanchang/Documents/doc/course/csci571/hw9/hw9/Up.png")
            }
        }
        if indexPath.row == 7 {
            if (Double(json!["LastPrice"].stringValue)! - json!["ChangeYTD"].doubleValue) < 0{
                cell.arrow.image = UIImage(contentsOfFile: "/Users/zonghanchang/Documents/doc/course/csci571/hw9/hw9/Down.png")
            }
            else{
                cell.arrow.image = UIImage(contentsOfFile: "/Users/zonghanchang/Documents/doc/course/csci571/hw9/hw9/Up.png")
            } 
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func fillTable(){
        if let json = json{
            if json["Status"].stringValue == "SUCCESS" {
            content.append(json["Name"].stringValue)
            content.append(json["Symbol"].stringValue)
            content.append("$ " + json["LastPrice"].stringValue)
            content.append(String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
            
            let dateStr = json["Timestamp"].stringValue
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZZZZZ yyyy"
            let defaultTimeZoneStr = formatter.dateFromString(dateStr)
            formatter.timeZone = NSTimeZone(abbreviation: "UTC-04:00")
            formatter.dateFormat = "MMM dd yyyy HH:mm:ss"
            let utcTimeZoneStr = formatter.stringFromDate(defaultTimeZoneStr!)
            content.append(utcTimeZoneStr)
            
            let marketcap = json["MarketCap"].doubleValue
            if marketcap / 1000000000 >= 0.005 {
                content.append(String(format: "%.2f", marketcap / 1000000000) + " Billion")
            }
            else if marketcap / 1000000 >= 0.05{
                content.append(String(format: "%.2f", marketcap / 1000000) + " Million")
            }
            else{
                content.append(String(marketcap))
            }
            
            content.append(json["Volume"].stringValue)
            content.append(String(format: "%.2f", Double(json["LastPrice"].stringValue)! - json["ChangeYTD"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercentYTD"].doubleValue) + "%)")
            content.append("$ " + String(json["High"].doubleValue))
            content.append("$ " + String(json["Low"].doubleValue))
            content.append("$ " + String(json["Open"].doubleValue))
            }
        }
        
    }
    
    
    func setChart(){
        if let checkedUrl = NSURL(string: "http://chart.finance.yahoo.com/t?s=AAPL&lang=en-US&width=550&height=300") {
            imageView.contentMode = .ScaleAspectFit
            downloadImage(checkedUrl)
        }
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                
                self.imageView.image = UIImage(data: data)
            }
        }
    }

    
    @IBAction func shareFB(sender: AnyObject) {
        
    }
    
    @IBAction func favorite(sender: AnyObject) {
        
    }
    
    
    
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}