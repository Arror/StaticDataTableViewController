//
//  ViewController.swift
//  Sample
//
//  Created by Arror on 14/12/2017.
//  Copyright © 2017 Arror. All rights reserved.
//

import UIKit
import StaticDataTableViewController

class ViewController: StaticDataTableViewController {
    
    @IBOutlet weak var a1: UITableViewCell!
    @IBOutlet weak var b1: UITableViewCell!
    @IBOutlet weak var c1: UITableViewCell!
    
    @IBOutlet weak var a2: UITableViewCell!
    @IBOutlet weak var b2: UITableViewCell!
    @IBOutlet weak var c2: UITableViewCell!
    
    @IBOutlet weak var a3: UITableViewCell!
    @IBOutlet weak var b3: UITableViewCell!
    @IBOutlet weak var c3: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func o1Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.delete(cells: [self.b1], with: .left)
            
            return true
            
        }, completion: { _ in })
    }
    
    @IBAction func o2Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.insert(cells: [self.b1], with: .right)
            
            return false
            
        }, completion: { _ in })
    }
    
    @IBAction func o3Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.delete(cells: [self.a2], with: .left)
            context.delete(cells: [self.b2], with: .middle)
            context.delete(cells: [self.c2], with: .right)
            
            return true
            
        }, completion: { _ in })
    }
    
    @IBAction func o4Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.insert(cells: [self.a2], with: .left)
            context.insert(cells: [self.b2], with: .middle)
            context.insert(cells: [self.c2], with: .right)
            
            return false
            
        }, completion: { _ in })
    }
    
    @IBAction func o5Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.update(cell: self.b3, with: 120.0)
            
            return true
            
        }, completion: { _ in })
    }
    
    @IBAction func o6Tapped(_ sender: UIBarButtonItem) {
        
        self.performBatchUpdates({ context in
            
            context.update(cell: self.b3, with: 240.0)
            
            return false
            
        }, completion: { _ in })
    }
}


