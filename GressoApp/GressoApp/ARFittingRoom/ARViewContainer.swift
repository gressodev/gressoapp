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
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
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
    
    func saveSnapshot(saveToHDR: Bool) {
        arView.snapshot(saveToHDR: saveToHDR) { image in
            guard let cgImage = image?.cgImage else { return }
            let uiImage = UIImage(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }
    }
    
}
