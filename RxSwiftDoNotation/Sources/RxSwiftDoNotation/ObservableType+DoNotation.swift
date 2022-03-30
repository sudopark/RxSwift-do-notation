//
//  ObservableType+DoNotation.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation

import RxSwift

extension ObservableType {
    
    public func flatMap<T>(do expression: @escaping (Element) async throws -> T?) -> Observable<T> {
        
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
    
    
    public func flatMap<T, S: AsyncSequence>(do expression: @escaping (Element) -> S) -> Observable<T> where S.Element == T {
        
        return self.flatMap { expression($0).asObservable() }
    }
    
    
    public func flatMapFirst<T, S: AsyncSequence>(do expression: @escaping (Element) -> S) -> Observable<T> where S.Element == T {
        
        return self.flatMapFirst { expression($0).asObservable() }
    }
    
    
    public func flatMapLatest<T, S: AsyncSequence>(do expression: @escaping (Element) -> S) -> Observable<T> where S.Element == T {
        
        return self.flatMapLatest { expression($0).asObservable() }
    }
}

