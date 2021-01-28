//
//  ViewController.swift
//  StarbucksExpirationLogger
//
//  Created by Grant Jednesty on 9/19/20.
//

import UIKit
import RealmSwift
import UserNotifications
class InventoryItem: Object{
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
    
}

class CustomeCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let notificationCenter = UNUserNotificationCenter.current()
    @IBOutlet weak var itemTableView: UITableView!
    
    private let realm = try! Realm()
    private var data: [InventoryItem] = []
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.notificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }

    func sendNotification(notificationType: String) {
        let content = UNMutableNotificationContent()
        content.title = notificationType
        content.body = "This is example how to create  + \(notificationType)"
        content.sound = UNNotificationSound.default
        content.badge = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestNotificationAuthorization()
        
        data = realm.objects(InventoryItem.self).map({ $0 })
        //itemTableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        itemTableView.delegate = self
        itemTableView.dataSource = self
        refreshView()
    }
// Mark: Table
    override func viewWillAppear(_ animated: Bool) {
        refreshView()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func refreshView()
    {
               data.sort {
                   $0.date < $1.date
               }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! CustomeCell
        let today = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 2
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)
        if data[indexPath.row].date <= today {
            let dateString = Self.dateFormatter.string(from: data[indexPath.row].date)
            cell.dateLabel.textColor = UIColor.red
            cell.dateLabel.text = dateString
        }
        else if data[indexPath.row].date < futureDate! {
            let dateString = Self.dateFormatter.string(from: data[indexPath.row].date)
            cell.dateLabel.textColor = UIColor.yellow
            cell.dateLabel.text = dateString
        }
        else {
            let dateString = Self.dateFormatter.string(from: data[indexPath.row].date)
            cell.dateLabel.textColor = UIColor.green
            cell.dateLabel.text = dateString
        }
        cell.itemLabel.text = data [indexPath.row].item
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "view") as? DetailViewController else {
            return
        }
        vc.item = item
        vc.deletionHandler = {[weak self] in
            self?.refresh()
            
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapAddButton(){
        guard let vc = storyboard?.instantiateViewController(identifier: "addItem") as? AddItemViewController else{
        return
        }
        vc.completionHander = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Item"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refresh() {
        data = realm.objects(InventoryItem.self).map({ $0 })
        itemTableView.reloadData()
    }
    

}

