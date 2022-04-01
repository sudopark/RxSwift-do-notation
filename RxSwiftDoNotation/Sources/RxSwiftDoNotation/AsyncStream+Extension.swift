//
//  File.swift
//  
//
//  Created by sudo.park on 2022/04/01.
//

import Foundation


extension AsyncStream {
    
    public static func from(_ elements: [Element]) -> AsyncStream {
        
        return AsyncStream { continuation in
            
            elements.forEach { element in
                continuation.yield(element)
            }
            continuation.finish()
        }
    }
}


extension AsyncThrowingStream {
    
    public static func from(_ elements: [Element]) -> AsyncThrowingStream<Element, Error> {
        
        return AsyncThrowingStream<Element, Error> { continuation in

            elements.forEach { element in

                continuation.yield(element)
            }
            continuation.finish()
        }
    }
}
