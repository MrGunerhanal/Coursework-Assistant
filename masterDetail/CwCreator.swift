//
//  TaskCreator.swift
//  masterDetail
//
//  Created by Burak Gunerhanal on 15/05/2017.
//  Copyright © 2017 Burak Gunerhanal. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class CwCreator: UIViewController {
    
    var courseWork = [Coursework]()
    var reminderDate : Date!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var markAwardedTextfield: UITextField!
    @IBOutlet weak var cwNameTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var moduleNameTextField: UITextField!
    @IBOutlet weak var worthSlider: UISlider!
    @IBOutlet weak var showWorth: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func closePopup(_ sender: UIButton) {
        self.removeAnimate()
    }
    
    @IBAction func saveCw(_ sender: UIButton) {
        self.insertData()
       // self.fetchData()
        self.removeAnimate()
    }
    
    func insertData()
    {
        let cw = Coursework(context: context)
        
        let level = Int(levelTextField.text!)
        cw.level =  Int32(level!)
        
        cw.cwWorth = Int32(worthSlider.value)
        
        let awarded = Int(markAwardedTextfield.text!)
        cw.markAwarded = Int32(awarded!)
        
        cw.dueDate =  dueDatePicker.date as NSDate?
        
        cw.cwName =  cwNameTextField.text
        cw.notes =  notesTextField.text
        cw.moduleName = moduleNameTextField.text
        
   
        appDelegate.saveContext()

    }
    
//    func fetchData(){
//        do {
//            courseWork = try context.fetch(Coursework.fetchRequest())
//            for line in courseWork
//            {
//                print("Name : \(line.cwName)")
//                
//            }
//        } catch  {
//            //hanfle error
//        }
//    }
    
    @IBAction func worthSlided(_ sender: UISlider) {
        let nonDecimal = roundf(worthSlider.value)
        showWorth.text = "\(nonDecimal)"
    }


    func showAnimate()
    {
        self.view.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction func switchReminder(_ sender: UISwitch) {
        if sender.isOn{
            reminder()
        }
    }
    
    func reminder() {
        reminderDate = dueDatePicker.date
        print(reminderDate)
        cwNameTextField.text = cwNameTextField.text
        if(self.reminderDate != nil && self.cwNameTextField.text != "") {
            let store:EKEventStore = EKEventStore()
            store.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
                
                if let e = error {
                    print("Error \(e.localizedDescription)")
                }
                
                if granted {
                    print("Calendar access granted")
                    
                    let date : Date = Date()
                    let event:EKEvent = EKEvent(eventStore: store)
                    print("Reminder for \(date)")
                    if (self.cwNameTextField.text! != "" ) {
                        event.title = self.cwNameTextField.text!
                    }
                    
                    event.startDate =  self.reminderDate
                    event.endDate =  self.reminderDate
                    event.isAllDay = false
                    event.calendar = store.defaultCalendarForNewEvents
                    do {
                        
                        try store.save(event, span: EKSpan.thisEvent, commit: true)
                        
                    } catch {
                        print(error)
                    }
                }
            }
        }else {
            print("Missing coursework details")
            let alert = UIAlertController(title: "No due date", message: "You need to set the due date to and task name to set a reminder", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //self.reminderSeg.selectedSegmentIndex = 0
        }
    }
}
