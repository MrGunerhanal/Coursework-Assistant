//
//  TaskCreator.swift
//  masterDetail
//
//  Created by Burak Gunerhanal on 18/05/2017.
//  Copyright © 2017 Burak Gunerhanal. All rights reserved.
//

import UIKit
import CoreData

class TaskCreator: UIViewController {

    @IBOutlet weak var cwIDNameLabel: UILabel!
    var task = [Task]()
    var coursework:Coursework?
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cwIDNameLabel.text = coursework?.cwName
        view.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
        self.showAnimate()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelTask(_ sender: UIButton) {
        self.removeAnimate()
    }
    func insertData()
    {
        
        let task = Task(context: context)
        
        //task.courseworkName?.name = coursework?.name
        task.taskDueDate = deadlineDatePicker.date as NSDate?
        task.startTime = startDatePicker.date as NSDate?
        task.notes = notesTextField.text
        task.taskName = taskNameTextField.text
        coursework?.addToTasks(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }

    @IBAction func saveTask(_ sender: UIButton) {
        self.insertData()
        //appDelegate.saveContext()
        self.removeAnimate()
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
}
