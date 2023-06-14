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
    
    let arView = ARView(frame: .zero)
    
    let destination: URL
    
    func makeUIView(context: Context) -> ARView {
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        loadModel(destination: destination)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadModel(destination: URL) {
        DispatchQueue.main.async {
            do {
                let model = try Entity.loadAnchor(contentsOf: destination)
                arView.scene.addAnchor(model)
            } catch {
                print("Fail loading entity.")
            }
        }
    }
    
    private func loadModels(destination: URL) {
        DispatchQueue.main.async {
            do {
                let model = try Entity.loadAnchor(contentsOf: destination)
                arView.scene.addAnchor(model)
            } catch {
                print("Fail loading entity.")
            }
        }
    }
}
