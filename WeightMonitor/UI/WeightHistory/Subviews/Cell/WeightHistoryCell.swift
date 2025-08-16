//
//  WeightHistoryCell.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import UIKit

final class WeightHistoryCell: UITableViewCell {    
    // MARK: - Public
    var viewModel: WeightHistoryCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            weight.text = viewModel.weightFormatted
            change.text = viewModel.massDifference
            date.text = viewModel.date
        }
    }
    
    // MARK: - Private
    private let stackViewHorizontal: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 8
        return view
    }()
    private let weight: UILabel = {
        let weight = UILabel()
        weight.textColor = .label
        weight.font = .systemFont(ofSize: 17, weight: .medium)
        return weight
    }()
    private let change: UILabel = {
        let change = UILabel()
        change.textColor = .secondaryLabel
        change.font = .systemFont(ofSize: 17, weight: .medium)
        return change
    }()
    private let date: UILabel = {
        let date = UILabel()
        date.textColor = .tertiaryLabel
        date.font = .systemFont(ofSize: 17, weight: .medium)
        return date
    }()
    private let arrowView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.forward")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.label)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.contentMode = .center
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(stackViewHorizontal)
        stackViewHorizontal.addSubviews(weight, change, date, arrowView)
        stackViewHorizontal.setCustomSpacing(4, after: date)
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackViewHorizontal.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackViewHorizontal.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackViewHorizontal.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackViewHorizontal.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                  
            weight.widthAnchor.constraint(equalToConstant: 116),
            change.widthAnchor.constraint(equalToConstant: 116)
        ])
    }
}
