//
//  SegmentedControl.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 12.07.2023.
//

import UIKit
import SwiftUI

enum GlassesState: CaseIterable {
    case street, inside
    
    var title: String {
        switch self {
        case .street:
            return "Street"
        case .inside:
            return "Inside"
        }
    }
    
    var image: UIImage {
        switch self {
        case .street:
            return Images.sun
        case .inside:
            return Images.home
        }
    }
}

struct SegmentedControl: UIViewRepresentable {

    @Binding var needToDarken: Bool
    
    func makeUIView(context: Context) -> GlassesStateControl {
        GlassesStateControl()
    }
    
    func updateUIView(_ uiView: GlassesStateControl, context: Context) {
        uiView.needToDarken = { isNeeded in
            needToDarken = isNeeded
        }
    }
    
}

final class GlassesStateControl: UIView {
    
    var needToDarken: ((Bool) -> Void)?
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: GlassesState.allCases.map {
            UIImage.textEmbeded(image: $0.image, string: $0.title, isImageBeforeText: true, segFont: Fonts.jostRegular16ui)
        })
        view.selectedSegmentIndex = .zero
        view.selectedSegmentTintColor = .black
        view.backgroundColor = .clear
        view.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        view.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .normal)
        view.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        addBlur(view: self)
        addSubview(segmentedControl)
        configureConstraints()
    }
    
    private func configureConstraints() {
        segmentedControl.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            needToDarken?(true)
        case 1:
            needToDarken?(false)
        default:
            break
        }
    }
    
    private func addBlur(view: UIView) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
}
