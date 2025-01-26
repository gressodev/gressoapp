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
    
    func downloadAllModelsIfNeeded(completion: @escaping () -> Void) {
        guard let listObjectsRequest = AWSS3ListObjectsRequest() else { completion(); return }
        listObjectsRequest.bucket = bucketName
        
        s3.listObjects(listObjectsRequest).continueOnSuccessWith { [weak self] (task) -> Any? in
            guard let self else { completion(); return }
            if let error = task.error {
                print("Error occurred: \(error)")
                completion()
                return nil
            }

            guard let listObjectsOutput = task.result else { completion(); return }
            guard let contents = listObjectsOutput.contents?.dropFirst() else { completion(); return }
            let dispatchGroup = DispatchGroup()
            for object in contents {
                guard let objectKey = object.key else { continue }
                let folderName = objectKey.components(separatedBy: "/")[0]
                let colorName = objectKey.components(separatedBy: "/")[1]
                guard colorName.contains("-") else { continue }
                
                dispatchGroup.enter()
                
                loadModelIfNeeded(modelName: folderName, colorName: colorName, objectKey: objectKey, completion: { _ in
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .global(qos: .background)) {
                completion()
            }
            
            return nil
        }
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
                guard let key = object.key?.components(separatedBy: "/")[1], key.contains("-") else { completion(nil, nil); continue }
                
                let fixedKey = key.components(separatedBy: "-")[1]
                if let imageUrl = URL(string: "https://gressotest.s3.us-east-2.amazonaws.com/colors/\(fixedKey).png") {
                    self.downloadImage(from: imageUrl) { [weak self] image in
                        guard let self else { return }
                        self.loadModelIfNeeded(modelName: folderName, colorName: key, objectKey: object.key!, completion: { url in
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
    
    private func loadModelIfNeeded(modelName: String, colorName: String, objectKey: String, completion: @escaping (URL?) -> Void)  {
        let path = "https://gressotest.s3.us-east-2.amazonaws.com/"
        guard let url = URL(string: path + modelName + "/" + colorName) else { return }
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destination = documents.appendingPathComponent(url.lastPathComponent)
        let fileExists = fileManager.fileExists(atPath: destination.path)
        
        if fileExists {
            // Проверяем актуальность модели
            checkModelIsUpToDate(key: objectKey, localURL: destination) { [weak self] isUpToDate in
                guard let self else { return }
                if isUpToDate {
                    completion(destination)
                } else {
                    downloadModel(
                        modelName: modelName,
                        colorName: colorName,
                        destination: destination
                    ) { url in
                        completion(url)
                    }
                }
            }
        } else {
            downloadModel(
                modelName: modelName,
                colorName: colorName,
                destination: destination
            ) { url in
                completion(url)
            }
        }
    }
    
    private func downloadModel(modelName: String, colorName: String, destination: URL, completion: @escaping (URL?) -> Void)  {
        let path = "https://gressotest.s3.us-east-2.amazonaws.com/"
        guard let url = URL(string: path + modelName + "/" + colorName) else { return }
        
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
                guard let location else { completion(nil); return }
                try fileManager.moveItem(atPath: location.path,
                                         toPath: destination.path)
                completion(destination)
            } catch {
                completion(nil)
                print("###, download error:", error)
            }
        })
        downloadTask.resume()
    }
    
    private func checkModelIsUpToDate(key: String, localURL: URL, completion: @escaping (Bool) -> Void) {
        let headObjectRequest = AWSS3HeadObjectRequest()!
        headObjectRequest.bucket = bucketName
        headObjectRequest.key = key
        
        s3.headObject(headObjectRequest).continueWith { task in
            if let error = task.error {
                print("Failed to check model: \(error)")
                completion(false)
            } else if let headObjectOutput = task.result {
                let lastModified = headObjectOutput.lastModified
                let localFileAttributes = try? FileManager.default.attributesOfItem(atPath: localURL.path)
                let localModificationDate = localFileAttributes?[.modificationDate] as? Date
                
                if let lastModified, let localModificationDate {
                    completion(lastModified <= localModificationDate)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
            return nil
        }
    }
    
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
    
}
