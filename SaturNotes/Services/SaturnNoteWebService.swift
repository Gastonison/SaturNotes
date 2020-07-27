//
//  SaturnNoteWebService.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

struct SaturnNoteWebService {
    
    static func uploadImage(
        imageData: Data,
        success: (([String: Any]) -> Void)? = nil,
        fail: ((Error) -> Void)? = nil) {
        
        let queue = DispatchQueue(
            label: "upload",
            qos: .background,
            attributes: .concurrent)
        
        Alamofire
            .Session
            .default
            .upload(multipartFormData: {
                $0.append(
                    imageData,
                    withName: "file",
                    fileName: "file.jpg",
                    mimeType: "image/jpg")
            }, with: Router.uploadImage)
            .response(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { break }
                    if let jsonArray =
                        try? JSONSerialization.jsonObject(
                            with: data,
                            options: .allowFragments) as? Dictionary<String,Any> {
                        success?(jsonArray)
                    }
                    
                case .failure(let error):
                    fail?(error)
                }
        }
    }
    
    static func createNote(
        title: String,
        imageId: String,
        success: (([String: Any]) -> Void)? = nil,
        fail: ((Error) -> Void)? = nil) {
        
        let queue = DispatchQueue(
            label: "create",
            qos: .background,
            attributes: .concurrent)
        
        Alamofire
            .Session
            .default
            .request(Router.createNote(title: title, imageId: imageId))
            .response(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { break }
                    if let jsonArray =
                        try? JSONSerialization.jsonObject(
                            with: data,
                            options: .allowFragments) as? Dictionary<String,Any> {
                        success?(jsonArray)
                    }
                    
                case .failure(let error):
                    fail?(error)
                }
                
        }
        
    }
    
    static func getNotes(
        success: (([[String: Any]]) -> Void)? = nil,
        fail: ((Error) -> Void)? = nil) {
        
        let queue = DispatchQueue(
            label: "get",
            qos: .background,
            attributes: .concurrent)
        
        Alamofire
            .Session
            .default
            .request(Router.getNotes)
            .response(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { break }
                    if let jsonArray =
                        try? JSONSerialization.jsonObject(
                            with: data,
                            options: .allowFragments) as? [Dictionary<String,Any>] {
                        success?(jsonArray)
                    }
                    
                case .failure(let error):
                    fail?(error)
                }
                
        }
    }
    
    
    fileprivate enum Router: URLRequestConvertible {
        
        case uploadImage
        case createNote(title: String, imageId: String)
        case getNotes
        
        var method: HTTPMethod {
            switch self {
            case .getNotes:
                return .get
            case .uploadImage, .createNote:
                return .post
            }
        }
        
        var path: String {
            switch self {
            case .getNotes:
                return "/test-notes"
            case .uploadImage:
                return "/test-notes/photo"
            case .createNote:
                return "/test-notes"
            }
        }
        
        public func asURLRequest() throws -> URLRequest {
            let url = URL(string: Constants.serverURL)!
                .appendingPathComponent(path)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var parameters = Parameters()
            
            switch self {
            case .createNote(let title, let imageId):
                parameters["title"] = title
                parameters["image_id"] = imageId
            default:
                break
            }
                        
            switch method {
            case .post, .put:
                return try JSONEncoding.default
                    .encode(urlRequest, with: parameters)
            default:
                return try URLEncoding.default
                    .encode(urlRequest, with: parameters)
            }
            
        }
    }
}

