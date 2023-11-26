//
//  ARViewContainer.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 09.06.2023.
//

import SwiftUI
import RealityKit
import ARKit

@MainActor
struct ARViewContainer: UIViewRepresentable {
    
    @Binding var currentDestination: URL?
    @Binding var needToTakeSnapshot: Bool
    @Binding var needToDarken: Bool
    
    var didTakeSnapshot: (UIImage) -> Void
    
    func makeUIView(context: Context) -> ARFaceTrackingView {
        let arView = ARFaceTrackingView(frame: .zero)
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARFaceTrackingView, context: Context) {
        uiView.scene.anchors.removeAll()
        
        if let currentDestination {
            uiView.changeModel(
                currentDestination: currentDestination,
                needToDarken: needToDarken
            )
        }
        if needToTakeSnapshot {
            guard let image = uiView.takeScreenshot() else { return }
            DispatchQueue.main.async {
                didTakeSnapshot(image)
                needToTakeSnapshot = false
            }
        }
    }
    
}

final class ARFaceTrackingView: ARView {
    
    deinit {
        session.pause()
    }
    
    func changeModel(currentDestination: URL, needToDarken: Bool) {
        do {
            let model = try RCProject.loadScene(realityFileSceneURL: currentDestination)
            scene.addAnchor(model)
            
            if needToDarken {
                model.notifications.darkenLenses.post()
            } else {
                model.notifications.lightenLenses.post()
            }
        } catch {
            print("Fail loading entity.", error.localizedDescription)
        }
    }
    
}

//final class ARFittingRoomViewTest: UIView {
//    @Binding var loadingModels: [LoadingModel]
//    private var modelLink: URL?
//    private let modelName: String
//    
//    @Binding var currentDestination: URL?
//    @Binding var needToTakeSnapshot: Bool
//    @Binding var needToDarken: Bool
//    
//    var didTakeSnapshot: (UIImage) -> Void
//    
//    init(
//        loadingModels: Binding<[LoadingModel]>,
//        modelLink: URL?,
//        modelName: String,
//        currentDestination: Binding<URL?>,
//        needToTakeSnapshot: Binding<Bool>,
//        needToDarken: Binding<Bool>,
//        didTakeSnapshot: @escaping (UIImage) -> Void
//    ) {
//        self._loadingModels = loadingModels
//        self.modelLink = modelLink
//        self.modelName = modelName
//        self._currentDestination = currentDestination
//        self._needToTakeSnapshot = needToTakeSnapshot
//        self._needToDarken = needToDarken
//        self.didTakeSnapshot = didTakeSnapshot
//        super.init()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
