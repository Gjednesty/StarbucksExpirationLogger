//
//  AddItemViewController.swift
//  StarbucksExpirationLogger
//
//  Created by Grant Jednesty on 9/25/20.
//
import RealmSwift
import UIKit

class AddItemViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var textField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    private let realm = try! Realm()
    public var completionHander: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        textField.delegate = self
        
        datePicker.setDate(Date(), animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton() {
        if let text = textField.text, !text.isEmpty {
            let date = datePicker.date
            realm.beginWrite()
            
            let newItem = InventoryItem()
            newItem.date = date
            newItem.item = text
            realm.add(newItem)
            try! realm.commitWrite()
            
            completionHander?()
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            
        }
    }
        
}
