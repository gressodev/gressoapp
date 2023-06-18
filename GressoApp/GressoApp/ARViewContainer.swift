//
//  ARViewContainer.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 09.06.2023.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    private let arView = ARView(frame: .zero)
    
    let destinations: [URL]
    @Binding var currentIndex: Int
    @State private var currentDestination: URL?
    
    func makeUIView(context: Context) -> ARView {
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.scene.anchors.removeAll()
        
        if let currentDestination {
            do {
                let anchor = AnchorEntity()
                let model = try Entity.loadAnchor(contentsOf: currentDestination)
                anchor.addChild(model)
                uiView.scene.addAnchor(anchor)
            } catch {
                print("Fail loading entity.", error.localizedDescription)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            parent.currentDestination = parent.destinations[parent.currentIndex]
        }
    }
    
}
