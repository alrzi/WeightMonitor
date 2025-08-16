//
//  CreateWeightViewController.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 04.05.2023.
//

import UIKit

final class AddWeightViewController: UIViewController {
    private let nameOfScreen: UILabel = {
        let nameOfScreen = UILabel()
        nameOfScreen.text = String(localized: "creation.addWeight", table: "WeightCreation")
        nameOfScreen.font = .systemFont(ofSize: 20, weight: .semibold)
        nameOfScreen.textColor = .label
        return nameOfScreen
    }()
   
    private let dateLabel: UILabel = {
        let date = UILabel()
        date.textColor = .label
        date.text = String(localized: "creation.date", table: "WeightCreation")
        date.font = .systemFont(ofSize: 17, weight: .medium)
        return date
    }()
    
    private let setDateOfRecordButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle(String(localized: "creation.today", table: "WeightCreation"), for: .normal)
        addButton.setTitleColor(.systemIndigo, for: .normal)
        return addButton
    }()
    
    private let arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.forward")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.label)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let weightTextField: UITextField = {
        let weightTextField = UITextField()
        
        weightTextField.keyboardType = .numberPad
        weightTextField.placeholder = String(localized: "creation.enterWeight", table: "WeightCreation")
        weightTextField.font = .systemFont(ofSize: 34, weight: .bold)
        weightTextField.backgroundColor = .systemBackground
        return weightTextField
    }()
    
    private let weightUnitLabel: UILabel = {
        let weightUnitLabel = UILabel()
        weightUnitLabel.textColor = .secondaryLabel
        weightUnitLabel.font = .systemFont(ofSize: 17, weight: .medium)
        weightUnitLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return weightUnitLabel
    }()
    
    private let createButton: UIButton = {
        let createButton = UIButton()
        createButton.setTitle(String(localized: "creation.add", table: "WeightCreation"), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .systemIndigo
        createButton.layer.cornerRadius = 10
        createButton.layer.masksToBounds = true
        return createButton
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru")
        datePicker.alpha = 1
        return datePicker
    }()
    
    private let stackView = UIStackView()
    private let firstHorizontalStack = UIStackView()
    private let secondHorizontalStack = UIStackView()
    private var separator1 = UIView()
    private var separator2 = UIView()
    private var separator3 = UIView()
    private let containerViewForDataPicker = UIView()
    
    private var createButtonBottomConstraint: NSLayoutConstraint?
    private let createButtonBottomConstraintConstant: CGFloat = -16
    private var dataPickerContainerViewHeightConstraint: NSLayoutConstraint?
    private let dataPickerContainerViewHeightConstraintConstant: CGFloat = 216
    
    var viewModel: AddWeightViewModel?
    
    func setViewModel(_ viewModel: AddWeightViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
        viewModel?.$weightUnit.bind({ [weak self] unit in
            self?.weightUnitLabel.text = unit
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()        
        updateConstraints()
        setTargets()
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)                
        // Remove the notification observers
        NotificationCenter.default.removeObserver(self)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weightTextField.becomeFirstResponder()
        setUpTextField()
    }
    
    @objc func handleSetTodayButtonTap() {
        dismissKeyboard()
    }
    
    @objc func handleCreateButtonTap() {
        guard let isAllFieldsEntered = viewModel?.isAllFieldsEntered, isAllFieldsEntered else {
            dismissKeyboard()
            viewModel?.setDate(Date())
            return
        }
        viewModel?.addRecord()
        dismiss(animated: true)
    }
    
    @objc func datePickerValueChanged() {
        setDateOfRecordButton.setTitle(datePicker.date.todayOrOtherDayString(), for: .normal)
        viewModel?.setDate(datePicker.date)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
                       
            let bottomInset = view.safeAreaInsets.bottom
            let newKeyboardHeight = keyboardSize.height - bottomInset
            
            animateViews(separator2, containerViewForDataPicker,
                         duration: animationDuration ?? 0.3,
                         shouldHide: true,
                         buttonConstraint: -(newKeyboardHeight + 16),
                         datePickerHeight: .zero
            )
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval

            animateViews(separator2, containerViewForDataPicker,
                         duration: animationDuration ?? 0.3,
                         shouldHide: false,
                         buttonConstraint: self.createButtonBottomConstraintConstant,
                         datePickerHeight: self.dataPickerContainerViewHeightConstraintConstant
            )
        }
    }
}

private extension AddWeightViewController {
    func setupView() {
        weightTextField.delegate = self
               
        stackView.axis = .vertical
        stackView.alignment = .fill

        separator1 = createSeparatorView()
        separator2 = createSeparatorView()
        separator2.isHidden = true
        separator3 = createSeparatorView()
                        
        containerViewForDataPicker.addSubviews(datePicker)
        containerViewForDataPicker.isHidden = true
        
        firstHorizontalStack.axis = .horizontal
        firstHorizontalStack.spacing = 8
        
        secondHorizontalStack.axis = .horizontal
        secondHorizontalStack.spacing = 4
        
        firstHorizontalStack.addSubviews(dateLabel, setDateOfRecordButton, arrowImageView)
        secondHorizontalStack.addSubviews(weightTextField, weightUnitLabel)
        
        stackView.addSubviews(firstHorizontalStack,
                              separator1,
                              containerViewForDataPicker,
                              separator2,
                              secondHorizontalStack,
                              separator3)
        view.backgroundColor = .systemBackground
        
        view.addSubviews(
            nameOfScreen,
            
            stackView,
            
            createButton
        )
    }
    
    func updateConstraints() {
        NSLayoutConstraint.activate([
            nameOfScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            nameOfScreen.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            datePicker.centerXAnchor.constraint(equalTo: containerViewForDataPicker.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: containerViewForDataPicker.centerYAnchor),
            
            firstHorizontalStack.heightAnchor.constraint(equalToConstant: 54),
            secondHorizontalStack.heightAnchor.constraint(equalToConstant: 72),
           
            stackView.topAnchor.constraint(equalTo: nameOfScreen.bottomAnchor, constant: 128),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                        
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        dataPickerContainerViewHeightConstraint = containerViewForDataPicker.heightAnchor.constraint(equalToConstant: dataPickerContainerViewHeightConstraint?.constant ?? dataPickerContainerViewHeightConstraintConstant)
        dataPickerContainerViewHeightConstraint?.isActive = true
        
        createButtonBottomConstraint = createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: (createButtonBottomConstraint?.constant ?? createButtonBottomConstraintConstant))
        createButtonBottomConstraint?.isActive = true
    }
    
    func animateViews(_ views: UIView..., duration: CGFloat, shouldHide: Bool, buttonConstraint: CGFloat, datePickerHeight: CGFloat) {
        UIKit.UIView.animate(withDuration: duration + 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.createButtonBottomConstraint?.constant = buttonConstraint
            self.dataPickerContainerViewHeightConstraint?.constant = datePickerHeight
            views.forEach { $0.isHidden = shouldHide }
            views.forEach { $0.alpha = shouldHide ? 0.0 : 1.0 }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
   
    func setTargets() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        setDateOfRecordButton.addTarget(self, action: #selector(handleSetTodayButtonTap), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(handleCreateButtonTap), for: .touchUpInside)
    }
    
    func updateView() {
        viewModel?.updateView()
    }
    
    func createSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.backgroundColor = .tertiaryLabel
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separatorView
    }
    
    func setUpTextField() {
        // Notifications for when the keyboard opens/closes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
}

extension AddWeightViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text in the text field
        guard let currentText = textField.text else { return true }
        
        // Create a new string by replacing the characters in the specified range with the replacement string
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
                
        let formattedText = viewModel?.formatString(updatedText)
        
        // Set the text field's text to the formatted text
        textField.text = formattedText
        viewModel?.setWeight(formattedText)
        
        // Return false to prevent the default behavior of the text field
        return false
    }
}
