//
//  LoadGlassesService.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 15.06.2023.
//

import Foundation

protocol LoadGlassesServiceInterface: Sendable {
    func loadModel(with modelName: String, _ colorName: String, completion: @escaping (URL?) -> Void)
    func loadModels(with modelName: String, completion: @escaping (URL?) -> Void)
}

final class LoadGlassesService: LoadGlassesServiceInterface {
    
    func loadModel(with modelName: String, _ colorName: String, completion: @escaping (URL?) -> Void)  {
        let path = "https://gressotest.s3.us-east-2.amazonaws.com/"
        let realityExtention = ".reality"
        guard let url = URL(string: path + modelName + "/" + colorName + realityExtention) else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documents.appendingPathComponent(url.lastPathComponent)
        let session = URLSession(configuration: .default,
                                 delegate: nil,
                                 delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location: URL?,
                                                                                     response: URLResponse?,
                                                                                     error: Error?) -> Void in
            guard let response = response as? HTTPURLResponse else { completion(nil); return }
            guard 200..<300 ~= response.statusCode else { completion(nil); return }
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: destination.path) {
                try! fileManager.removeItem(atPath: destination.path)
            }
            do {
                try fileManager.moveItem(atPath: location!.path,
                                          toPath: destination.path)
                completion(destination)
            } catch {
                completion(nil)
            }
        })
        downloadTask.resume()
    }
    
    func loadModels(with modelName: String, completion: @escaping (URL?) -> Void) {
        let path = "https://gressotest.s3.us-east-2.amazonaws.com/"
        guard let url = URL(string: path + modelName) else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documents.appendingPathComponent(url.lastPathComponent + "/")
        let session = URLSession(configuration: .default,
                                 delegate: nil,
                                 delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location: URL?,
                                                                                     response: URLResponse?,
                                                                                     error: Error?) -> Void in
            guard let response = response as? HTTPURLResponse else { completion(nil); return }
            guard 200..<300 ~= response.statusCode else { completion(nil); return }
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: destination.path) {
                try! fileManager.removeItem(atPath: destination.path)
            }
            do {
                try fileManager.moveItem(atPath: location!.path,
                                          toPath: destination.path)
                completion(destination)
            } catch {
                completion(nil)
            }
        })
        downloadTask.resume()
    }

}
