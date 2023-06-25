//
//  PagingColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import UIKit

final class PagingColorsView: UICollectionView {
    
    private enum LocalConstants {
        static let cellSize: CGSize = CGSize(width: 80, height: 80)
    }
    
    private var items: [String]
    private var completion: (Int) -> Void
    
    init(items: [String], completion: @escaping (Int) -> Void) {
        self.items = items
        self.completion = completion
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 30
        layout.sectionInset = .zero
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseId)
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        dataSource = self
        delegate = self
        
        if items.count != .zero {
            DispatchQueue.main.async {
                completion(.zero)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource

extension PagingColorsView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionCell.reuseId,
            for: indexPath
        ) as? ColorCollectionCell else { return UICollectionViewCell() }
        
        cell.configure(text: item)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PagingColorsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        LocalConstants.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = collectionView.bounds.width / 2 - LocalConstants.cellSize.width / 2
        return UIEdgeInsets(top: .zero, left: inset, bottom: .zero, right: inset)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = contentOffset
        visibleRect.size = bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = indexPathForItem(at: visiblePoint) else { return }
        completion(indexPath.row)
    }
    
}
