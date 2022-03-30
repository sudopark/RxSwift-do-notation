//
//  PrimitiveSequenceType+doNotation.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation

import RxSwift

extension PrimitiveSequenceType where Trait == SingleTrait {
    
    public func flatMap<T>(do expression: @escaping (Element) async throws -> T) -> Single<T> {
        
        let runExpression: (Element) throws -> Single<T> = { element in
            
            return Single.create { callback in
                
                let task = Task {
                    do {
                        let result = try await expression(element)
                        callback(.success(result))
                        
                    } catch {
                        callback(.failure(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}


extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    public func flatMap<T>(do expression: @escaping (Element) async throws -> T?) -> Maybe<T> {
        
        let runExpression: (Element) throws -> Maybe<T> = { element in
            
            return Maybe.create { callback in
                
                let task = Task {
                    do {
                        if  let result = try await expression(element) {
                            callback(.success(result))
                        } else {
                            callback(.completed)
                        }
                        
                        
                    } catch {
                        callback(.error(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}
