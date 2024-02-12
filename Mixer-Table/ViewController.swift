//
//  ViewController.swift
//  Mixer-Table
//
//  Created by Иван Дроботов on 12.02.2024.

import UIKit

final class ViewController: UIViewController {
    
    private enum Section {
        case main
    }
    
    private struct Item: CustomStringConvertible {
        var id: Int
        var title: String
        var isSelected: Bool = false
        
        var description: String {
            return "(id: \(self.id), title: \(self.title), isSelected: \(self.isSelected))"
        }
    }
    
    private var items: [Item] = (0...50).map {
        Item(id: $0, title: "\($0)")
    }
    
    private lazy var shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleTupped))
    
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    private func style() {
        view.backgroundColor = .systemBackground
        title = "Mixer-Table"
        navigationItem.rightBarButtonItem = shuffleButton
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
        
    }
    
    @objc private func shuffleTupped() {
        let oldList = items
        items.shuffle()
        
        tableView.performBatchUpdates({
            var alreadyMoved = Set<Int>()
            
            for newIndex in items.indices {
                let movedModel = items[newIndex]
                
                guard !alreadyMoved.contains(movedModel.id) else { continue }
                
                if let oldIndex = oldList.firstIndex(where: { $0.id == movedModel.id }) {
                    
                    tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
                    
                    alreadyMoved.insert(movedModel.id)
                }
            }
        }, completion: { _ in
            self.tableView.reloadData()
        })
        
    }
}

//MARK: - DataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        let item = self.items[indexPath.row]
        cell.accessoryType = item.isSelected ? .checkmark : .none
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        cell.contentConfiguration = configuration
        return cell
    }
    
    
}

//MARK: - Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isSelected = !items[indexPath.row].isSelected
        items[indexPath.row].isSelected = isSelected
        
        let toIndexPath = IndexPath(row: 0, section: indexPath.section)
        
        if isSelected {
            let item = items.remove(at: indexPath.row)
            items.insert(item, at: 0)
            
            tableView.performBatchUpdates({
                tableView.moveRow(at: indexPath, to: toIndexPath)
            }, completion: { _ in
                self.tableView.reloadRows(at: [toIndexPath], with: .automatic)
                tableView.deselectRow(at: toIndexPath, animated: true)
            })
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
