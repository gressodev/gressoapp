//
//  ContentView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 07.06.2023.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
        
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        loadModel(arView)

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadModel(_ arView: ARView) {
        let url = URL(string: "https://gressotest.s3.us-east-2.amazonaws.com/santiago/Santiago.reality")
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documents.appendingPathComponent(url!.lastPathComponent)
        let session = URLSession(configuration: .default,
                                 delegate: nil,
                                 delegateQueue: nil)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location: URL?,
                                                                                     response: URLResponse?,
                                                                                     error: Error?) -> Void in
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: destination.path) {
                try! fileManager.removeItem(atPath: destination.path)
            }
            try! fileManager.moveItem(atPath: location!.path,
                                      toPath: destination.path)
            
            DispatchQueue.main.async {
                do {
                    let model = try Entity.loadAnchor(contentsOf: destination)
                    arView.scene.addAnchor(model)
                } catch {
                    print("Fail loading entity.")
                }
            }
        })
        downloadTask.resume()
    }
    
}
