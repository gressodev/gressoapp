//
//  PagingColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import UIKit

final class PagingColorsView: UIView {
    
    private var currentPage: CGFloat = .zero
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemWidth = itemSize.widthDimension.dimension
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: .zero, bottom: 3, trailing: .zero)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: .zero,
                leading: (UIScreen.main.bounds.width - itemWidth) / 2,
                bottom: .zero,
                trailing: (UIScreen.main.bounds.width - itemWidth) / 2
            )
            section.orthogonalScrollingBehavior = .groupPagingCentered
            
            section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, point, environment) -> Void in
                guard let self else { return }
                
                visibleItems.forEach { item in
                    let distanceFromCenter = abs((item.frame.midX - point.x) - environment.container.contentSize.width / 2.0)
                    let cell = self.collectionView.cellForItem(at: item.indexPath) as? ColorCollectionCell
                    let limit: CGFloat = 8
                    if distanceFromCenter > limit || distanceFromCenter < -limit {
                        cell?.transformToStandart()
                    } else {
                        cell?.transformToLarge()
                        self.currentPage = CGFloat(item.indexPath.row)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.completion(item.indexPath.row)
                        }
                    }
                }
            }
            return section
        })
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseId)
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = false
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    var models: [LoadingModel]
    private var completion: (Int) -> Void
    
    init(models: [LoadingModel], completion: @escaping (Int) -> Void) {
        self.models = models
        self.completion = completion
        super.init(frame: .zero)
        
        backgroundColor = .clear
        setupSubviews()
        
        if models.count != .zero {
            DispatchQueue.main.async {
                completion(.zero)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource

extension PagingColorsView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionCell.reuseId,
            for: indexPath
        ) as? ColorCollectionCell else { return UICollectionViewCell() }
        
        let model = models[indexPath.item]
        cell.configure(
            isLoading: model.isLoading,
            colorImage: model.colorImage,
            isLarge: Int(currentPage) == indexPath.row
        )
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PagingColorsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
}
