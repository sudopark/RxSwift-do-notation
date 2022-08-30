//
//  ObservableType+DoNotation.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation

import RxSwift

extension ObservableType {
    
    public func flatMap<T>(do expression: @Sendable @escaping (Element) async throws -> T?) -> Observable<T> {
        
        let runExpression: (Element) throws -> Observable<T> = { element in
            return Observable<T>.create(with: element, do: expression)
        }
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async throws -> T?) -> Observable<T> {
        
        return Observable<T>.create(with: (), do: expression)
    }
    
    
    private static func create<I, R>(
        with input: I,
        do expression: @Sendable @escaping (I) async throws -> R?
    ) -> Observable<R> {
        return Observable.create { observer in

            let task = Task {
                do {
                    if let result = try await expression(input) {
                        observer.onNext(result)
                    }
                    observer.onCompleted()
                        
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create { task.cancel() }
        }
    }
}

