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
            
            return Infallible<T>.create(with: element, do: expression)
        }
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async -> T?) -> Infallible<T> {
        
        return Infallible<T>.create(with: (), do: expression)
    }
    
    private static func create<I, R>(
        with input: I,
        do expression: @Sendable @escaping (I) async -> R?
    ) -> Infallible<R> {
        return Infallible.create { callback in
            
            let task = Task {
                if let result = await expression(input) {
                    callback(.next(result))
                }
                callback(.completed)
            }
            
            return Disposables.create { task.cancel() }
        }
    }
}
