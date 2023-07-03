//
//  S3ServiceHandler.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 18.06.2023.
//

import Foundation
import AWSS3

final class S3ServiceHandler: ObservableObject {
    
    private let bucketName = "gressotest"
    private let s3 = AWSS3.default()
    
    func filesCount(folderName: String, completion: @escaping (Int) -> Void) {
        guard let listObjectsRequest = AWSS3ListObjectsRequest() else { completion(.zero); return }
        listObjectsRequest.bucket = bucketName
        listObjectsRequest.prefix = folderName
        
        s3.listObjects(listObjectsRequest).continueOnSuccessWith { (task) -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                completion(.zero)
                return nil
            }
            guard let listObjectsOutput = task.result else { completion(.zero); return }
            guard let contents = listObjectsOutput.contents?.dropFirst() else { completion(.zero); return }
            completion(contents.count)
            
            return nil
        }
    }
    
//    func downloadColors(completion: @escaping (UIImage) -> Void) {
//        guard let listObjectsRequest = AWSS3ListObjectsRequest() else { return }
//        listObjectsRequest.bucket = bucketName
//        listObjectsRequest.prefix = "colors"
//
//        s3.listObjects(listObjectsRequest).continueOnSuccessWith { [weak self] (task) -> Any? in
//            guard let self else { return }
//            if let error = task.error {
//                print("Error occurred: \(error)")
//                return nil
//            }
//
//            guard let listObjectsOutput = task.result else { return }
//            guard let contents = listObjectsOutput.contents?.dropFirst() else { return }
//            for object in contents {
//                guard let key = object.key else { return }
//                let fixedKey = key.components(separatedBy: "-")[0]
//                downloadImage(withKeyName: fixedKey) { image in
//                    completion(image)
//                }
//            }
//
//            return nil
//        }
//    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("### Error downloading image: \(error)")
                return
            }
            
            guard let data = data else {
                print("### No data returned from the server.")
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image)
            }
        }
        
        task.resume()
    }



    func downloadFilesInFolder(folderName: String, completion: @escaping (URL?, UIImage?) -> Void) {
        guard let listObjectsRequest = AWSS3ListObjectsRequest() else { completion(nil, nil); return }
        listObjectsRequest.bucket = bucketName
        listObjectsRequest.prefix = folderName
        
        s3.listObjects(listObjectsRequest).continueOnSuccessWith { [weak self] (task) -> Any? in
            guard let self else { return }
            if let error = task.error {
                print("Error occurred: \(error)")
                completion(nil, nil)
                return nil
            }

            guard let listObjectsOutput = task.result else { completion(nil, nil); return }
            guard let contents = listObjectsOutput.contents?.dropFirst() else { completion(nil, nil); return }
            for object in contents {
                guard let key = object.key?.replacingOccurrences(of: folderName + "/", with: "") else { completion(nil, nil); return }
                
                let fixedKey = key.replacingOccurrences(of: ".reality", with: "").components(separatedBy: "-")[0]
                if let imageUrl = URL(string: "https://gressotest.s3.us-east-2.amazonaws.com/colors/\(fixedKey).jpeg") {
                    self.downloadImage(from: imageUrl) { [weak self] image in
                        guard let self else { return }
                        self.loadModel(with: folderName, key, completion: { url in
                            guard let url else { completion(nil, nil); return }
                            DispatchQueue.main.async {
                                completion(url, image)
                            }
                        })
                    }
                }
            }
            
            return nil
        }
    }
    
    func loadModel(with modelName: String, _ colorName: String, completion: @escaping (URL?) -> Void)  {
        let path = "https://gressotest.s3.us-east-2.amazonaws.com/"
        guard let url = URL(string: path + modelName + "/" + colorName) else { return }
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
                try? fileManager.removeItem(atPath: destination.path)
            }
            do {
                try fileManager.moveItem(atPath: location!.path,
                                         toPath: destination.path)
                completion(destination)
            } catch {
                completion(nil)
                print("###, download error:", error)
            }
        })
        downloadTask.resume()
    }
    
}
