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
    
    @Binding var currentDestination: URL?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
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
    
}
