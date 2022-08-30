//
//  PrimitiveSequenceType+doNotation.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation

import RxSwift


// MARK: - single

extension PrimitiveSequenceType where Trait == SingleTrait {
    
    public func flatMap<T>(do expression: @Sendable @escaping (Element) async throws -> T) -> Single<T> {
        
        let runExpression: (Element) throws -> Single<T> = { element in
            
            return Single<T>.create(with: element, do: expression)
        }
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async throws -> T) -> Single<T> {
        
        return Single<T>.create(with: (), do: expression)
    }
    
    private static func create<I, R>(
        with input: I,
        do expression: @Sendable @escaping (I) async throws -> R
    ) -> Single<R> {
        return Single.create { callback in
            
            let task = Task {
                do {
                    let result = try await expression(input)
                    callback(.success(result))
                    
                } catch {
                    callback(.failure(error))
                }
            }
            
            return Disposables.create { task.cancel() }
        }
    }
}


// MARK: - maybe

extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    public func flatMap<T>(do expression: @Sendable @escaping (Element) async throws -> T?) -> Maybe<T> {
        
        let runExpression: (Element) throws -> Maybe<T> = { element in
            return Maybe<T>.create(with: element, do: expression)
        }
        
        return self.flatMap(runExpression)
    }
    
    public static func create<T>(do expression: @Sendable @escaping () async throws -> T?) -> Maybe<T> {
        return Maybe<T>.create(with: (), do: expression)
    }
    
    private static func create<I, R>(
        with input: I,
        do expression: @Sendable @escaping (I) async throws -> R?
    ) -> Maybe<R> {
        
        return Maybe.create { callback in
            
            let task = Task {
                do {
                    if  let result = try await expression(input) {
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
}
