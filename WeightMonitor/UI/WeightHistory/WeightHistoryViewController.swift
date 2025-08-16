//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import UIKit

extension WeightHistoryViewController: CurrentWeightViewDelegate {
    func isSwitchOn(_ isOn: Bool) {
        let unit = isOn ? UnitMass.kilograms : .pounds
        viewModel?.setWeightUnit(unit)
    }
}

final class WeightHistoryViewController: UIViewController {
    private let nameOfScreen = UILabel()
    private let currentWeightView = CurrentWeightView()
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.allowsSelection = false
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.separatorStyle = .none
        view.backgroundColor = .systemBackground
        view.register(cellClass: WeightHistoryCell.self)
        view.registerHeader(headerClass: WeightHistoryTableViewHeaderView.self)
        return view
    }()
    private let addNewWeightButton: UIButton = {
        let addButton = UIButton()
        addButton.layer.cornerRadius = 24
        addButton.layer.masksToBounds = true
        let image = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        addButton.setImage(image, for: .normal)
        addButton.backgroundColor = .systemIndigo
        return addButton
    }()
    private let newRecordNotification: UILabel = {
        let newRecordNotification = UILabel()
        newRecordNotification.text = String(localized: "weightHistory.newWeightRecord", table: "WeightList")
        newRecordNotification.textAlignment = .center
        newRecordNotification.backgroundColor = .label
        newRecordNotification.textColor = .systemBackground
        newRecordNotification.layer.cornerRadius = 12
        newRecordNotification.layer.masksToBounds = true
        return newRecordNotification
    }()
    
    private var viewModel: WeightHistoryViewModel?
    
    func setViewModel(_ viewModel: WeightHistoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
        viewModel?.$weightRecords.bind({ [weak self] records in
            guard !records.isEmpty else {
                self?.viewModel?.updateViewWnenZeroRecords()
                return
            }
            self?.currentWeightView.updateView(records)
            self?.tableView.reloadData()
        })
        
        viewModel?.$initialRecord.bind({ [weak self] record in
            self?.currentWeightView.updateViewOnZeroRecords(record)
            self?.updateTableView(self?.viewModel?.batchUpdate)
        })
        
        viewModel?.$isNewRecordAdded.bind({ [weak self] isNewRecordAdded in
            if isNewRecordAdded {
                self?.showNotification()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.becomeFirstResponder()
    }
    
    @objc func addWeight() {
        presentAddWeightViewController()
    }
}

// MARK: - Private methods
private extension WeightHistoryViewController {
    func updateView() {
        guard let viewModel = viewModel else { return }       
        viewModel.setWeightUnit()
    }
    
    func setupLayout() {
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = .zero
        
        view.backgroundColor = .systemBackground
        nameOfScreen.text = String(localized: "weightHistory.title", table: "WeightList")
        nameOfScreen.font = .systemFont(ofSize: 20, weight: .semibold)
        nameOfScreen.textColor = .label
        
        currentWeightView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        addNewWeightButton.addTarget(self, action: #selector(addWeight), for: .touchUpInside)
        
        view.addSubviews(nameOfScreen, tableView, currentWeightView, addNewWeightButton)
        NSLayoutConstraint.activate([
            nameOfScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameOfScreen.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentWeightView.topAnchor.constraint(equalTo: nameOfScreen.bottomAnchor, constant: 24),
            currentWeightView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentWeightView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: currentWeightView.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addNewWeightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addNewWeightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewWeightButton.heightAnchor.constraint(equalToConstant: 48),
            addNewWeightButton.widthAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    func showNotification() {
        view.addSubviews(newRecordNotification)
        newRecordNotification.alpha = 1
                        
        newRecordNotification.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -24).isActive = true
        
        newRecordNotification.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 16).isActive = true
        
        newRecordNotification.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -16).isActive = true
        
        newRecordNotification.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5) {
                self.newRecordNotification.alpha = 0
            } completion: { _ in
                self.newRecordNotification.removeFromSuperview()
                self.newRecordNotification.superview?.removeConstraints(self.newRecordNotification.constraints)
            }
        }
    }
    
    func updateTableView(_ update: DataProviderUpdate?) {
        guard let update = update else { return }
        tableView.performBatchUpdates {
            if !update.insertedIndexes.isEmpty {
                tableView.insertRows(at: [update.insertedIndexes], with: .automatic)
            }
            if !update.insertedSection.isEmpty {
                tableView.insertSections(update.insertedSection, with: .automatic)
            }
            if !update.deletedIndexes.isEmpty {
                tableView.deleteRows(at: [update.deletedIndexes], with: .automatic)
            }
            if !update.deletedSection.isEmpty {
                tableView.deleteSections(update.deletedSection, with: .automatic)
            }
            if !update.updatedIndexes.isEmpty {
                tableView.reloadRows(at: [update.updatedIndexes], with: .automatic)
            }
        }
    }
    
    func presentAddWeightViewController(_ id: String? = nil) {
        let vc = AddWeightViewController()
        vc.modalTransitionStyle = .crossDissolve
        let viewModel = AddWeightViewModel(recordId: id)
        vc.setViewModel(viewModel)
        present(vc, animated: true)
    }
}

extension WeightHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.weightRecords.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeightHistoryCell = tableView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModel?.weightRecords[indexPath.row]
        cell.viewModel = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: WeightHistoryTableViewHeaderView = tableView.dequeueReusableHeaderFooterView()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 67
    }
}

extension WeightHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.remove(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let id = self.viewModel?.getRecordIdForIndexPath(indexPath)
            self.presentAddWeightViewController(id)
            
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
