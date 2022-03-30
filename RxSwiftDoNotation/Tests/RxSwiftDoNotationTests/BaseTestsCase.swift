//
//  BaseTestsCase.swift
//  
//
//  Created by sudo.park on 2022/03/31.
//

import XCTest

import RxSwift

import RxSwiftDoNotation


class BaseTestsCase: XCTestCase {
    
    struct TestError: Error { }
    
    let sleepInterval: TimeInterval = 0.0001
    let timeout: TimeInterval = 0.001
    
    var disposeBag: DisposeBag!
    var didCanceledIncrease: Bool?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.didCanceledIncrease = nil
        self.disposeBag = nil
    }
    
    func increase(_ int: Int, shouldFail: Bool = false) async throws -> Int {
        
        let interval = self.sleepInterval
        
        let operation: () async throws -> Int = {
            Thread.sleep(forTimeInterval: interval)
            if shouldFail {
                throw TestError()
            } else {
                return int + 1
            }
        }
        
        let canceled: @Sendable () -> Void = {
            self.didCanceledIncrease = true
        }
        
        return try await withTaskCancellationHandler(operation: operation, onCancel: canceled)
    }
    
    func add(_ lhs: Int, rhs: Int) async -> Int {
        let interval = self.sleepInterval
        return await withCheckedContinuation { continuation in
            Thread.sleep(forTimeInterval: interval)
            continuation.resume(returning: lhs + rhs)
        }
    }
}
