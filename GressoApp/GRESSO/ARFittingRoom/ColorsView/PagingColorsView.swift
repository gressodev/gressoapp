//
//  PagingColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import UIKit

final class PagingColorsView: UICollectionView {
    
    private enum LocalConstants {
        static let cellSize: CGSize = CGSize(width: 44, height: 96)
        static let minimumLineSpacing: CGFloat = 30
    }
    
    private var currentPage: CGFloat = .zero
    
    private var centerCell: ColorCollectionCell?
    
    var models: [LoadingModel]
    private var completion: (Int) -> Void
    
    init(models: [LoadingModel], completion: @escaping (Int) -> Void) {
        self.models = models
        self.completion = completion
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = LocalConstants.minimumLineSpacing
        layout.minimumInteritemSpacing = .zero
        layout.itemSize = LocalConstants.cellSize
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseId)
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = false
        dataSource = self
        delegate = self
        
        if models.count != .zero {
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

extension PagingColorsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (collectionView.bounds.width - LocalConstants.cellSize.width) / 2
        return UIEdgeInsets(top: .zero, left: inset, bottom: .zero, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        completion(indexPath.row)
        currentPage = CGFloat(indexPath.row)
        if centerCell == nil {
            centerCell = cellForItem(at: IndexPath(row: .zero, section: .zero)) as? ColorCollectionCell
        }
        centerCell?.transformToStandart()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centeredPoint = CGPoint(x: frame.width / 2 + scrollView.contentOffset.x,
                                    y: frame.height / 2 + scrollView.contentOffset.y)
        guard let indexPath = indexPathForItem(at: centeredPoint) else { return }
        centerCell = cellForItem(at: indexPath) as? ColorCollectionCell
        
        // TODO: - Fix transform if scroll is quick
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.05) { [weak self] in
        centerCell?.transformToLarge()
//        }
        
        if let cell = centerCell {
            let offsetX = centeredPoint.x - cell.center.x
            let limit: CGFloat = 8
            if offsetX < -limit || offsetX > limit {
                cell.transformToStandart()
                centerCell = nil
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = contentOffset
        visibleRect.size = bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = indexPathForItem(at: visiblePoint) else { return }
        completion(indexPath.row)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = LocalConstants.cellSize.width + LocalConstants.minimumLineSpacing
        let targetXContentOffset = CGFloat(targetContentOffset.pointee.x)
        let contentWidth = CGFloat(contentSize.width)
        var newPage = currentPage
        
        if velocity.x == 0 {
            newPage = floor((targetXContentOffset - pageWidth / 2) / pageWidth) + 1.0
        } else {
            newPage = velocity.x > 0 ? currentPage + 1 : currentPage - 1
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        currentPage = newPage
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
    
}
