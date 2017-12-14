//
//  StaticDataTableViewController.swift
//  StaticDataTableViewController
//
//  Created by Arror on 14/12/2017.
//  Copyright © 2017 Arror. All rights reserved.
//

open class StaticDataTableViewController: UITableViewController {
    
    private var batchContext: BatchUpdateContext?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.batchContext = BatchUpdateContext(tableView: tableView)
    }
    
    public func performBatchUpdates(_ updates: (BatchUpdateContext) -> Bool, completion: (Bool) -> Void) {
        
        guard let context = self.batchContext else { return }
        
        context.performBatchUpdates(updates, completion: completion)
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard
            let context = self.batchContext else {
                
                return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
        return context.sections[section].visibleRows.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let context = self.batchContext,
            let row = context.sections[indexPath.section].visibleRow(at: indexPath.row) else {
                
                return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return row.cell
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard tableView.estimatedRowHeight != UITableViewAutomaticDimension else { return UITableViewAutomaticDimension }
        
        guard
            let context = self.batchContext,
            let row = context.sections[indexPath.section].visibleRow(at: indexPath.row),
            let height = row.height else {
                
                return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
        return height
    }
    
    open override func tableView(_ view: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard tableView.estimatedSectionHeaderHeight != UITableViewAutomaticDimension else { return UITableViewAutomaticDimension }
        
        let defaultHeight = super.tableView(view, heightForHeaderInSection: section)
        
        guard
            let context = self.batchContext else {
                
                return defaultHeight
        }
        
        return context.sections[section].visibleRows.isEmpty ? CGFloat.leastNonzeroMagnitude : defaultHeight
    }
    
    open override func tableView(_ view: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard tableView.estimatedSectionFooterHeight != UITableViewAutomaticDimension else { return UITableViewAutomaticDimension }
        
        let defaultHeight = super.tableView(view, heightForFooterInSection: section)
        
        guard
            let context = self.batchContext else {
                
                return defaultHeight
        }
        
        return context.sections[section].visibleRows.isEmpty ? CGFloat.leastNonzeroMagnitude : defaultHeight
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let title = super.tableView(tableView, titleForHeaderInSection: section)
        
        guard
            let context = self.batchContext else {
                
                return title
        }
        
        if !context.sections[section].visibleRows.isEmpty {
            return title
        } else {
            return nil
        }
    }
    
    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        let title = super.tableView(tableView, titleForFooterInSection: section)
        
        guard
            let context = self.batchContext else {
                
                return title
        }
        
        if !context.sections[section].visibleRows.isEmpty {
            return title
        } else {
            return nil
        }
    }
}

