//
//  DetailViewController.swift
//  masterDetail
//
//  Created by Burak Gunerhanal on 04/04/2017.
//  Copyright © 2017 Burak Gunerhanal. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    
    var courseWork = [NSManagedObject]()
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var cwNameLabel: UILabel!
    @IBOutlet weak var moduleNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var worthLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var awardedLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var headerTask: UINavigationItem!
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    var overProgress:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.headerTask.rightBarButtonItem = addButton
    }
    
    func configureView() {
        
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let labelHeader = self.moduleNameLabel {
                labelHeader.text = "Module Name: " + detail.moduleName!
            }
            if let labelcwName = self.cwNameLabel {
                labelcwName.text = "Coursework Name: " + detail.cwName!
            }
            if let labellevel = self.levelLabel {
                labellevel.text = "Level: " + "\(detail.level)"
            }
            if let labelworth = self.worthLabel {
                labelworth.text = "Worth: " + "\(detail.cwWorth)"
            }
            if let labelawarded = self.awardedLabel {
                labelawarded.text = "Awarded: " + "\(detail.markAwarded)"
            }
            if (self.dueDateLabel) == nil {
                let getDate = detail.dueDate
                //dueDate.text = String(self.daysBetween(date1: getDate as! Date))
                
                let title = UILabel()
                title.text = String(self.daysBetween(date1: getDate as! Date))
                title.numberOfLines = 0
                title.frame = CGRect(x: 24, y:94 , width:160 , height:160)
                // self.view.bounds.size.width/2,50,self.view.bounds.size.width, self.view.bounds.size.height
                title.textAlignment = .center
                title.backgroundColor = UIColor.green
                title.textColor = UIColor.white
                title.font = UIFont(name: "Thonburi-bold", size: 35)
                title.layer.masksToBounds = true
                title.layer.cornerRadius = 15
                view.addSubview(title)

            }
            if let noteslevel = self.notesLabel {
                noteslevel.text = "Notes: " + "\(detail.notes!)"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let event = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withCw: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: - Fetched results controller
    
    //var detailItem : Coursework?
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController! 
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "cwName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
                let currentTask = self.detailItem
                if(self.detailItem != nil){
                    let predicate = NSPredicate(format: "taskName = %@", currentTask!)
                    fetchRequest.predicate = predicate
                }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath:#keyPath(Task.taskName), cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.taskTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.taskTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.taskTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            taskTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            taskTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(taskTableView.cellForRow(at: indexPath!)!, withCw: anObject as! Task)
        case .move:
            taskTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.taskTableView.endUpdates()
    }
    
    func configureCell(_ cell: UITableViewCell, withCw cw: Task){
        cell.textLabel?.text = cw.taskName

    }
    
    func daysBetween(date1:Date)  -> String
    {
        
        //var elapsed = date1.timeIntervalSince(date2)
        var elapsed = ""
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfYear,.day,.hour,.minute,.second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .full
        elapsed = dateComponentsFormatter.string(from: date1.timeIntervalSinceNow)!
        return elapsed
    }
    
    func insertNewObject(_ sender: Any) {
        
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "taskCreator") as! TaskCreator
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame//CGRect(x: 0, y: 348, width: 500, height:550)//self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Coursework? {
        didSet {
            // Update the view.
            self.configureView()
        }
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
    
    @IBAction func editBtn(_ sender: UIButton) {
        if(editBtn.titleLabel!.text == "🔓")
        {
            print("editable")
            editBtn.setTitle("🔒", for: UIControlState.normal)
            cwNameLabel.isUserInteractionEnabled = true
            worthLabel.isUserInteractionEnabled = true
            levelLabel.isUserInteractionEnabled = true
            notesLabel.isUserInteractionEnabled = true
            awardedLabel.isUserInteractionEnabled = true
            dueDateLabel.isUserInteractionEnabled = true
            moduleNameLabel.isUserInteractionEnabled = true
        }
        else
        {
            print("non-editable")
            editBtn.setTitle("🔓", for: UIControlState.normal)
            cwNameLabel.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func update(_ sender: UIButton) {
        
        let detail = self.detailItem
        
        var stringCwName = ""
        
        stringCwName = cwNameLabel.text!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coursework")
        
        do {
            let results = try manageContext.fetch(fetchRequest); courseWork = results as! [NSManagedObject]
            
            let managedObject = detail
            
            managedObject?.setValue(stringCwName, forKey: "cwName")
            try manageContext.save()
        }
        catch let error as NSError {
            print("Could not Fetch \(error), \(error.userInfo)")
        }
    }
}


