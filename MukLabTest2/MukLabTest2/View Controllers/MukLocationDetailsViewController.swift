//
//  MukLocationDetailsViewController.swift
//  MukLabTest2
//
//  Created by Mukhtar Yusuf on 2/1/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import CoreData

class MukLocationDetailsViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukTitleTextField: UITextField!
    @IBOutlet weak var mukSubTitleTextField: UITextField!
    @IBOutlet weak var mukLatitudeTextField: UITextField!
    @IBOutlet weak var mukLongitudeTextField: UITextField!
    @IBOutlet weak var mukDeleteBarButtonItem: UIBarButtonItem!
    
    // MARK: Properties
    var mukCoreDataStack: CoreDataStack!
    lazy var mukManagedObjectContext = {
        mukCoreDataStack.managedContext
    }()
    var mukLocationToEdit: MukLocation?
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Location"
        
        if let mukLocationToEdit = mukLocationToEdit {
            title = "Edit Location"
            mukDeleteBarButtonItem.isEnabled = true
            
            mukTitleTextField.text = mukLocationToEdit.mukTitle
            mukSubTitleTextField.text = mukLocationToEdit.mukSubTitle
            mukLatitudeTextField.text = "\(mukLocationToEdit.mukLatitude)"
            mukLongitudeTextField.text = "\(mukLocationToEdit.mukLongitude)"
        }
    }
    
    // MARK: Action Methods
    @IBAction func mukSave(_ sender: UIBarButtonItem) {
        var mukLocation: MukLocation
        if let mukLocationToEdit = mukLocationToEdit {
            mukLocation = mukLocationToEdit
        } else {
            mukLocation = MukLocation(context: mukManagedObjectContext)
        }
        
        var mukIsValid = true
        var mukMessage = ""
        if let mukTitle = mukTitleTextField.text, !mukTitle.isEmpty {
            mukLocation.mukTitle = mukTitle
        } else {
            mukIsValid = false
            mukMessage = "Please Enter a Title!"
        }
        if let mukSubTitle = mukSubTitleTextField.text, !mukSubTitle.isEmpty {
            mukLocation.mukSubTitle = mukSubTitle
        } else {
            mukIsValid = false
            mukMessage += "\nPlease Enter a Subtitle!"
        }
        if let mukLatitude = Double(mukLatitudeTextField.text ?? "") {
            mukLocation.mukLatitude = mukLatitude
        } else {
            mukIsValid = false
            mukMessage += "\nPlease Enter a valid latitude!"
        }
        if let mukLongitude = Double(mukLongitudeTextField.text ?? "") {
            mukLocation.mukLongitude = mukLongitude
        } else {
            mukIsValid = false
            mukMessage += "\nPlease Enter a valid longitude!"
        }
        
        if mukIsValid {
            mukCoreDataStack.saveContext()
            self.navigationController?.popViewController(animated: true)
        } else {
            mukShowAlert(mukMessage: mukMessage)
        }
    }
    
    @IBAction func mukDelete(_ sender: UIBarButtonItem) {
        guard let mukLocationToEdit = mukLocationToEdit else { return } // Not really needed
        
        mukManagedObjectContext.delete(mukLocationToEdit)
        mukCoreDataStack.saveContext()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Utilities
    func mukShowAlert(mukMessage: String) {
        let mukAlert = UIAlertController(title: mukMessage,
                                         message: nil,
                                         preferredStyle: .alert)
        let mukAction = UIAlertAction(title: "Ok", style: .default)
        mukAlert.addAction(mukAction)
        
        present(mukAlert, animated: true)
    }
}
