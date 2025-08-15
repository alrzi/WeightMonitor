//
//  HeaderView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 04.05.2023.
//

import UIKit

final class WeightHistoryTableViewHeaderView: UITableViewHeaderFooterView {
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "weightHistory.history", table: "WeightList")
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "weightHistory.weight", table: "WeightList")
        label.textColor = .secondaryLabel
        label.alpha = 0.4
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "weightHistory.change", table: "WeightList")
        label.textColor = .secondaryLabel
        label.alpha = 0.4
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let dataLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "weightHistory.date", table: "WeightList")
        label.textColor = .secondaryLabel
        label.alpha = 0.4
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        view.alpha = 0.4
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
       
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemBackground
        
        let labelStackView = UIStackView()
        labelStackView.addSubviews(weightLabel, changeLabel, dataLabel)
        labelStackView.axis = .horizontal
        labelStackView.spacing = 8
        labelStackView.alignment = .center
        
        addSubviews(historyLabel, labelStackView, separatorLine)
        
        NSLayoutConstraint.activate([
       
            // Constraints for historyLabel
            historyLabel.topAnchor.constraint(equalTo: topAnchor),
            historyLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            // Constraints for labelStackView
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.heightAnchor.constraint(equalToConstant: 16),
            labelStackView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 16),
            
            // Constraints for weightLabel
            weightLabel.widthAnchor.constraint(equalToConstant: 116),
            
            // Constraints for changeLabel
            changeLabel.widthAnchor.constraint(equalToConstant: 116),
            
            // Constraints for separatorLine
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
