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
    
    private struct Item {
        var id: Int
        var title: String
    }
    
    private var items: [Item] = (0...50).map {
        Item(id: $0, title: "\($0)")
    }
    
    private var selected = Set<Int>()
    
    private lazy var dataSource =  UITableViewDiffableDataSource<Section, Int>(tableView: tableView) {
        tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = self.selected.contains(itemIdentifier) ? .checkmark : .none
        return cell
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleTupped))
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        updateDataSource(animated: false)
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
    
    private func updateDataSource(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @objc private func shuffleTupped() {
        items.shuffle()
        updateDataSource(animated: true)
    }
}

//MARK: - Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if selected.contains(item) {
            selected.remove(item)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            selected.insert(item)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        guard let first = dataSource.snapshot().itemIdentifiers.first, first != item else { return }
        
        var snapshort = dataSource.snapshot()
        snapshort.moveItem(item, beforeItem: first)
        dataSource.apply(snapshort)
    }
}
