//
//  ColorCollectionCell.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import UIKit
import SnapKit

final class ColorCollectionCell: UICollectionViewCell, ClassIdentifiable {
    
    private var isLoading = true

    // MARK: - UI Elements
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private lazy var colorImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        return view
    }()
    
    private lazy var cameraImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.image = Images.camera
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
        contentView.addSubview(borderView)
        contentView.addSubview(colorImageView)
        colorImageView.addSubview(activityIndicatorView)
        colorImageView.addSubview(cameraImageView)
        
        configureConstraints()
    }

    private func configureConstraints() {
        borderView.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.center.equalToSuperview()
        }
        colorImageView.snp.makeConstraints {
            $0.size.equalTo(36)
            $0.center.equalToSuperview()
        }
        activityIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cameraImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(13.48)
        }
    }
    
    // MARK: - Configure
    
    func configure(isLoading: Bool, colorImage: UIImage?) {
        self.isLoading = isLoading
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = !isLoading
        colorImageView.image = colorImage
    }
    
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.78, y: 1.78)
        }
        
        self.cameraImageView.isHidden = isLoading
        self.borderView.layer.borderWidth = 8
        self.borderView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }
    
    func transformToStandart() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
        
        self.cameraImageView.isHidden = true
        self.borderView.layer.borderWidth = 2
        self.borderView.layer.borderColor = UIColor.black.cgColor
    }

}
