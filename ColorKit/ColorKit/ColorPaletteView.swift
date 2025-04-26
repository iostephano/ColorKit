//
//  ColorPaletteView.swift
//  ColorKit
//
//  Created by Stephano Portella on 26/04/25.
//

import UIKit

class ColorPaletteView: UIView {

    private let formatSwitch = UISwitch()
    private let formatLabel = UILabel()
    private let formatContainer = UIStackView()

    private let topRow = UIStackView()
    private let bottomRow = UIStackView()
    private let rowsContainer = UIStackView()

    private var isHexFormat = true {
        didSet {
            formatLabel.text = isHexFormat ? "HEX" : "RGB"
            updateColorCircles()
        }
    }

    private var colors: [UIColor] = [] {
        didSet {
            updateColorCircles()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)

        formatLabel.font = .systemFont(ofSize: 10)
        formatLabel.textAlignment = .center
        formatLabel.textColor = .white
        formatLabel.text = "HEX"

        formatSwitch.isOn = true
        formatSwitch.onTintColor = .systemGreen
        formatSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)

        formatContainer.axis = .vertical
        formatContainer.alignment = .center
        formatContainer.spacing = 2
        formatContainer.addArrangedSubview(formatSwitch)
        formatContainer.addArrangedSubview(formatLabel)

        addSubview(formatContainer)
        formatContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formatContainer.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            formatContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        rowsContainer.axis = .vertical
        rowsContainer.alignment = .center
        rowsContainer.distribution = .equalSpacing
        rowsContainer.spacing = 6

        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing
        topRow.spacing = 8

        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .equalSpacing
        bottomRow.spacing = 8

        rowsContainer.addArrangedSubview(topRow)
        rowsContainer.addArrangedSubview(bottomRow)

        addSubview(rowsContainer)
        rowsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowsContainer.topAnchor.constraint(equalTo: formatContainer.bottomAnchor, constant: 8),
            rowsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            rowsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            rowsContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])

        setupColorCircles(for: topRow)
        setupColorCircles(for: bottomRow)
    }

    private func setupColorCircles(for stack: UIStackView) {
        for _ in 0..<7 {
            let circle = UIView()
            circle.layer.cornerRadius = 20
            circle.clipsToBounds = true
            circle.backgroundColor = .lightGray
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.heightAnchor.constraint(equalToConstant: 40).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 40).isActive = true

            let label = UILabel()
            label.font = .systemFont(ofSize: 8)
            label.textAlignment = .center
            label.textColor = .white
            label.numberOfLines = 1
            label.text = "#FFFFFF"
            label.translatesAutoresizingMaskIntoConstraints = false

            let pairStack = UIStackView(arrangedSubviews: [circle, label])
            pairStack.axis = .vertical
            pairStack.alignment = .center
            pairStack.spacing = 2

            stack.addArrangedSubview(pairStack)
        }
    }

    private func updateColorCircles() {
        let colorStacks = [topRow, bottomRow].flatMap { $0.arrangedSubviews.compactMap { $0 as? UIStackView } }

        for (index, stack) in colorStacks.enumerated() {
            guard stack.arrangedSubviews.count == 2,
                  let label = stack.arrangedSubviews[1] as? UILabel else { continue }

            let circle = stack.arrangedSubviews[0]

            if index < colors.count {
                let color = colors[index]
                circle.backgroundColor = color
                label.text = isHexFormat ? color.toHex() : color.toRGB()
            } else {
                circle.backgroundColor = .lightGray
                label.text = ""
            }
        }
    }

    @objc private func switchToggled() {
        isHexFormat.toggle()
    }

    func setColors(_ newColors: [UIColor]) {
        self.colors = Array(newColors.prefix(14))
    }
}

extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    func toRGB() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return "(\(r),\(g),\(b))"
    }
}
