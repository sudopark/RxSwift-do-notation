//
//  ObservableType+DoNotations.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation

import RxSwift


#if swift(>=5.5.2) && canImport(_Concurrency)
extension ObservableType {
    
    public func flatMap<T>(do notation: @escaping (Element) async throws -> T?) -> Observable<T> {
        
        let runDoNotation: (Element) throws -> Observable<T> = { element in
            
            return Observable.create { observer in
                
                let task = Task {
                    
                    do {
                        if let result = try await notation(element) {
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
        
        return self.flatMap(runDoNotation)
    }
    
    
    public func flatMap<T>(do notation: @escaping (Element) -> AsyncThrowingStream<T, Error>) -> Observable<T> {
        
        let runDoNotation: (Element) throws -> Observable<T> = { element in
            return notation(element).asObservable()
        }
        
        return self.flatMap(runDoNotation)
    }
}
#endif
