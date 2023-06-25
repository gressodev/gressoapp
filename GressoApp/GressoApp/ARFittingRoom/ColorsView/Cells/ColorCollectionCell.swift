//
//  ColorCollectionCell.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import UIKit
import SnapKit

final class ColorCollectionCell: UICollectionViewCell, ClassIdentifiable {

    // MARK: - UI Elements

    private lazy var colorImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 40
        return view
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupSubviews() {
        contentView.addSubview(colorImageView)
        colorImageView.addSubview(label)
        
        configureConstraints()
    }

    private func configureConstraints() {
        colorImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(colorImageView.snp.width)
            $0.center.equalToSuperview()
        }
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(text: String) {
        label.text = text
        colorImageView.backgroundColor = .green
    }

}
