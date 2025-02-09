//
//  ListViewController.swift
//  RssReader
//
//  Created by 福田翔大 on 2016/10/03.
//  Copyright © 2016年 banana. All rights reserved.
//

import UIKit
import Ji
import SDWebImage

class ListViewController: UITableViewController {
    
    var xml: LivtViewXmlParser?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        xml = LivtViewXmlParser()
        xml?.parse(url: Setting.RssUrl, completionHandler: { () -> () in
            self.tableView.reloadData()
    })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xml?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell", for:  indexPath) as? ListViewCell else {
            fatalError("Invalid cell")
    }
        
        guard let x = xml else {
            return cell
        }
        
        cell.item = x.items[indexPath.row]
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let x = xml else {
            return
        }
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                controller.item = x.items[indexPath.row]
        }
    }
}
class ListViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var item: Item? {
        didSet {
            titleLabel.text = item?.title
            descriptionLabel.text = item?.detail
            thumbnail.sd_setImage(with: item?.imgUrl)
        }
    }
}
class LivtViewXmlParser: NSObject,XMLParserDelegate {
    
    var item: Item?
    var items = [Item]()
    var currentString = ""
    var completionHandler: (() -> ())?
    
    func parse(url: String, completionHandler: @escaping () -> ()) {
        guard let url = URL(string: url) else {
            return
        }
        guard let xml_parser = XMLParser(contentsOf: url) else {
            return
        }
        
        items = []
        self.completionHandler = completionHandler
        xml_parser.delegate = self
        xml_parser.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentString = ""
        if elementName == "item" {
            item = Item()
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentString += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        guard let i = item else {
        return
        }
        
        switch elementName {
        case "title": i.title = currentString
        case "description": i.detail = currentString
        case "link": i.link = currentString
        case "content:encoded":
            i.jiDoc = Ji(htmlString: currentString)
        case "item": items.append(i)
        default: break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?()
    }
}
