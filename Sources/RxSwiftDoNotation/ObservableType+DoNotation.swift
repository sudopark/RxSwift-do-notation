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
            
            return Observable.create { observer in
                
                
                let task = Task {
                    do {
                        if let result = try await expression(element) {
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
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async throws -> T?) -> Observable<T> {
        
        return Observable.just(())
            .flatMap(do: expression)
    }
}

