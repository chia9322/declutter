//
//  DeclutterTableViewController.swift
//  Declutter
//
//  Created by Chia on 2022/01/12.
//

import UIKit


class DeclutterTableViewController: UITableViewController {
    
    var items: [Item] = [] {
        // 當items值改變時自動儲存資料
        didSet {
            Item.saveItems(items)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        // 讀取資料
        if let items = Item.loadItems() {
            self.items = items
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        
        cell.nameLabel?.text = item.name
        cell.dateLabel?.text = item.date
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentDirectory.appendingPathComponent("\(item.imageName).jpg")
        cell.itemImageView?.image = UIImage(contentsOfFile: imageUrl.path)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 刪除圖片
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentDirectory.appendingPathComponent("\(items[indexPath.row].imageName).jpg")
        do {
            try FileManager.default.removeItem(at:imageUrl)
        } catch {
        }
        
        // 刪除資料
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func unwindToDeclutterTableView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? AddItemTableViewController,
           let item = sourceViewController.item {
            // 從Edit頁面回到TableView，更新原有的cell資訊
            if let indexPath = tableView.indexPathForSelectedRow {
                items[indexPath.row] = item
                tableView.reloadRows(at: [indexPath], with: .automatic)
            // 從Add頁面回到TableView，新增cell
            } else {
                items.insert(item, at: 0)
                let newIndexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    // 點選cell可以編輯內容，傳資料到編輯頁面中
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddItemTableViewController,
           let row = tableView.indexPathForSelectedRow?.row {
            controller.item = items[row]
        } else {
            print("No row selected")
        }
    }
    
    
    
}



