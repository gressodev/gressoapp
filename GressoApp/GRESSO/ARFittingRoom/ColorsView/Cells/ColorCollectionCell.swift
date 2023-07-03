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
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)

    private lazy var colorImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 40
        return view
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
        colorImageView.addSubview(activityIndicatorView)
        
        configureConstraints()
    }

    private func configureConstraints() {
        colorImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(colorImageView.snp.width)
            $0.center.equalToSuperview()
        }
        activityIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(isLoading: Bool, colorImage: UIImage?) {
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = !isLoading
        colorImageView.image = colorImage
    }

}
