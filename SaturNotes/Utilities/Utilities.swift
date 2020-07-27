//
//  StringExtension.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/26/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation


class Utilities {
    
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
// Try these out on your programmatic views! ( they clean up a lot of repeated variable names )
    
//    public protocol KtxApplicable { }
//
//    public extension KtxApplicable {
//
//        @inline(__always) func convertTo<T>(_ block: (Self) -> (T)) -> T {
//            return block(self)
//        }
//
//        @inline(__always) func takeIf(_ block: (Self) -> (Bool)) -> Self? {
//            return block(self) ? self : nil
//        }
//
//        @inline(__always) @discardableResult func apply(_ block: (Self) -> ()) -> Self {
//            block(self)
//            return self
//        }
//
//        @inline(__always) func run(_ block: (Self) -> ()) {
//            block(self)
//        }
//    }
//
//    extension NSObject: KtxApplicable { }
//    extension String: KtxApplicable { }
//    extension Int: KtxApplicable { }
//    extension Double: KtxApplicable { }
//    extension Float: KtxApplicable { }
//    extension Array: KtxApplicable { }
//    extension Dictionary: KtxApplicable { }
   
// Sample
//    let animation = CABasicAnimation(keyPath: AnimationProperty.position.keyPath).apply({
//        $0.fromValue = NSValue(cgPoint: startPos)
//        $0.beginTime = CFTimeInterval(delay)
//        $0.duration = duration
//        $0.fillMode = .both
//        $0.isRemovedOnCompletion = true
//    })
//
    
}
