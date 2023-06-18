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

    func downloadFilesInFolder(folderName: String, completion: @escaping ([URL]) -> Void) {
        guard let listObjectsRequest = AWSS3ListObjectsRequest() else { completion([]); return }
        listObjectsRequest.bucket = bucketName
        listObjectsRequest.prefix = folderName
        
        s3.listObjects(listObjectsRequest).continueOnSuccessWith { [weak self] (task) -> Any? in
            guard let self else { return }
            if let error = task.error {
                print("Error occurred: \(error)")
                completion([])
                return nil
            }
            var urls: [URL] = []
            guard let listObjectsOutput = task.result else { completion([]); return }
            guard let contents = listObjectsOutput.contents?.dropFirst() else { completion([]); return }
            for object in contents {
                guard let key = object.key?.replacingOccurrences(of: folderName + "/", with: "") else { completion([]); return }
                self.loadModel(with: folderName, key, completion: { url in
                    guard let url else { completion([]); return }
                    urls.append(url)
                    if urls.count == contents.count {
                        completion(urls)
                    }
                })
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
            }
        })
        downloadTask.resume()
    }
    
}
