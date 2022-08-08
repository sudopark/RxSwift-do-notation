//
//  InfallibleType+DoNotation.swift
//  
//
//  Created by sudo.park on 2022/03/31.
//

import Foundation

import RxSwift

extension InfallibleType {
    
    public func flatMap<T>(do expression: @Sendable @escaping (Element) async -> T?) -> Infallible<T> {
        
        let runExpression: (Element) -> Infallible<T> = { element in
            
            return Infallible.create { callback in
                
                let task = Task {
                    if let result = await expression(element) {
                        callback(.next(result))
                    }
                    callback(.completed)
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async -> T?) -> Infallible<T> {
        
        return Infallible.just(())
            .flatMap(do: expression)
    }
}
