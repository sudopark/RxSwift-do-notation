//
//  File.swift
//  
//
//  Created by sudo.park on 2022/03/23.
//

import Foundation
import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)

extension PrimitiveSequenceType where Trait == SingleTrait {
    
    public func flatMap<T>(do notation: @escaping (Element) async throws -> T) -> Single<T> {
        
        let runDoNotation: (Element) throws -> Single<T> = { element in
            return Single.create { callback in
                
                let task = Task {
                    do {
                        let result = try await notation(element)
                        callback(.success(result))
                        
                    } catch {
                        callback(.failure(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runDoNotation)
    }
}


extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    public func flatMap<T>(do notation: @escaping (Element) async throws -> T?) -> Maybe<T> {
        
        let runDoNotation: (Element) throws -> Maybe<T> = { element in
            
            return Maybe.create { callback in
                
                let task = Task {
                    do {
                        guard let result = try await notation(element)
                        else {
                            callback(.completed)
                            return
                        }
                        callback(.success(result))
                        
                    } catch {
                        callback(.error(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runDoNotation)
    }
}

#endif
