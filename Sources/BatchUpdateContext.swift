//
//  BatchUpdateContext.swift
//  StaticDataTableViewController
//
//  Created by Arror on 14/12/2017.
//  Copyright © 2017 Arror. All rights reserved.
//

import UIKit

public class BatchUpdateContext {
    
    private let _updateLock = DispatchSemaphore(value: 1)
    
    private var _operationInfos: [BatchUpdateContext.AnimationInfo] = []
    
    internal let sections: [BatchUpdateContext.Section]
    
    internal let tableView: UITableView
    
    public init?(tableView: UITableView) {
        
        guard let dataSource = tableView.dataSource else { return nil }
        
        self.tableView = tableView
        
        var _sections: [BatchUpdateContext.Section] = []
        
        for sectionIndex in 0..<tableView.numberOfSections {
            var _rows: [BatchUpdateContext.Row] = []
            for rowIndex in 0..<tableView.numberOfRows(inSection: sectionIndex) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let cell = dataSource.tableView(tableView, cellForRowAt: indexPath)
                let row = Row(indexPath: indexPath, cell: cell)
                _rows.append(row)
            }
            let section = Section(rows: _rows)
            _sections.append(section)
        }
        
        self.sections = _sections
    }
    
    public func insert(cells: Set<UITableViewCell>, with animation: UITableViewRowAnimation) {
        
        self._set(operation: .insert, cells: cells, with: animation)
    }
    
    public func delete(cells: Set<UITableViewCell>, with animation: UITableViewRowAnimation) {
        
        self._set(operation: .delete, cells: cells, with: animation)
    }
    
    public func reload(cells: Set<UITableViewCell>, with animation: UITableViewRowAnimation) {
        
        self._set(operation: .reload, cells: cells, with: animation)
    }
    
    public func update(cell: UITableViewCell, with height: CGFloat) {
        
        self._set(operation: .update(height), cells: [cell], with: .none)
    }
    
    private func _row(of cell: UITableViewCell) -> BatchUpdateContext.Row? {
        for section in sections {
            for row in section.rows {
                if row.cell == cell { return row }
            }
        }
        return nil
    }
    
    private func _set(operation: BatchUpdateContext.Operation, cells: Set<UITableViewCell>, with animation: UITableViewRowAnimation) {
        
        let rows = cells.flatMap { self._row(of: $0) }
        
        let infos = rows.map { AnimationInfo(operation: operation, row: $0, animation: animation) }
        
        self._operationInfos.append(contentsOf: infos)
    }
    
    private func _prepareForBatchUpdateAnimationInfos() -> [BatchUpdateContext.AnimationInfo] {
        
        var _indexPathMapping: [IndexPath: AnimationInfo] = [:]
        
        self._operationInfos.forEach { info in
            
            _indexPathMapping[info.row.indexPath] = info
        }
        
        var _result: [BatchUpdateContext.AnimationInfo] = []
        
        let result = Array(_indexPathMapping.values)
        
        result.forEach { info in
            switch info.operation {
            case .insert:
                if info.row.isHidden {
                    info.row.isHidden = false
                    _result.append(info)
                }
            case .delete:
                if !info.row.isHidden {
                    info.row.isHidden = true
                    _result.append(info)
                }
            case .reload:
                if !info.row.isHidden {
                    _result.append(info)
                }
            case .update(let height):
                if !info.row.isHidden {
                    info.row.height = height
                    _result.append(info)
                }
            }
        }
        
        self._operationInfos = []
        
        return _result
    }
    
    internal func performBatchUpdates(_ updates: (BatchUpdateContext) -> Bool, completion: (Bool) -> Void) {
        
        let isAnimated = updates(self)
        
        let infos = self._prepareForBatchUpdateAnimationInfos()
        
        if infos.isEmpty {
            completion(false)
            return
        }
        
        self._updateLock.wait()
        
        defer {
            self._updateLock.signal()
        }
        
        if isAnimated {
            self.tableView.beginUpdates()
            infos.forEach { info in
                switch info.operation {
                case .insert:
                    self.tableView.insertRows(at: [info.row.indexPath], with: info.animation)
                case .delete:
                    self.tableView.deleteRows(at: [info.row.indexPath], with: info.animation)
                case .reload:
                    self.tableView.reloadRows(at: [info.row.indexPath], with: info.animation)
                case .update:
                    break
                }
            }
            self.tableView.endUpdates()
        } else {
            self.tableView.reloadData()
        }
        
        completion(true)
    }
}

extension BatchUpdateContext {
    
    private enum Operation: CustomStringConvertible {
        
        case insert
        case delete
        case reload
        case update(CGFloat)
        
        internal var description: String {
            
            let str: String = {
                switch self {
                case .insert:
                    return "[Insert]"
                case .delete:
                    return "[Delete]"
                case .reload:
                    return "[Reload]"
                case .update(let height):
                    return "[Update] - [Height: \(height)]"
                }
            }()
            
            return "BatchUpdateContext.Operation: \(str)"
        }
    }
}

extension BatchUpdateContext {
    
    private struct AnimationInfo: CustomStringConvertible {
        
        internal let operation: Operation
        
        internal let animation: UITableViewRowAnimation
        
        internal let row: BatchUpdateContext.Row
        
        internal init(operation: BatchUpdateContext.Operation, row: BatchUpdateContext.Row, animation: UITableViewRowAnimation) {
            
            self.operation = operation
            
            self.row = row
            
            self.animation = animation
        }
        
        internal var description: String {
            
            let desc = """
            \(self.operation.description)
            \(self.row.description)
            UITableViewRowAnimation: \(self.animation)
            """
            
            return desc
        }
    }
}

extension BatchUpdateContext {
    
    internal class Section: CustomStringConvertible {
        
        public let rows: [BatchUpdateContext.Row]
        
        public init(rows: [BatchUpdateContext.Row]) {
            self.rows = rows
        }
        
        public var visibleRows: [BatchUpdateContext.Row] {
            
            return rows.filter { !$0.isHidden }
        }
        
        public func visibleRow(at index: Int) -> BatchUpdateContext.Row? {
            
            guard (0..<self.visibleRows.count).contains(index) else { return nil }
            
            return self.visibleRows[index]
        }
        
        public var description: String {
            
            return self.rows.map { $0.description }.joined(separator: "\n")
        }
    }
}

extension BatchUpdateContext {
    
    internal class Row: CustomStringConvertible {
        
        public var isHidden: Bool = false
        public var height: CGFloat? = nil
        
        public let cell: UITableViewCell
        public let indexPath: IndexPath
        
        public init(indexPath: IndexPath, cell: UITableViewCell) {
            self.indexPath = indexPath
            self.cell = cell
        }
        
        public var description: String {
            
            let desc = """
            IndexPath: [Section: \(self.indexPath.section), Row: \(self.indexPath.row)]
            UITableViewCell: \(cell.description)
            Is Hidden: \(self.isHidden)
            Height: \(self.height ?? CGFloat.infinity)
            """
            
            return desc
        }
    }
}

extension UITableViewRowAnimation: CustomStringConvertible {
    
    public var description: String {
        
        let str: String = {
            switch self {
            case .fade:
                return "Fade"
            case .right:
                return "Right"
            case .left:
                return "Left"
            case .top:
                return "Top"
            case .bottom:
                return "Bottom"
            case .none:
                return "None"
            case .middle:
                return "Middle"
            case .automatic:
                return "Automatic"
            }
        }()
        
        return "UITableViewRowAnimation: [\(str)]"
    }
}

