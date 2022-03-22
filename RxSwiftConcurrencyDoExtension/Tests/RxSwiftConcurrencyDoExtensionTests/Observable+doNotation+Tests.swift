//
//  File.swift
//  
//
//  Created by sudo.park on 2022/03/24.
//

import Foundation
import XCTest

import RxSwift

import RxSwiftConcurrencyDoExtension


class ObservableDoNotationTests: XCTestCase {
    
    struct DummyError: Error { }
    
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var sleepInterval: TimeInterval = 0.0001
    
    func asyncIntToString(_ int: Int) async -> String {
        return await withCheckedContinuation { continutation in
            Thread.sleep(forTimeInterval: self.sleepInterval)
            continutation.resume(returning: "\(int)")
        }
    }
    
    func asyncIntToStringWithThrowing(_ int: Int,
                                      shouldThrow: Bool = false) async throws -> String {
        return try await withCheckedThrowingContinuation { continutation in
            Thread.sleep(forTimeInterval: self.sleepInterval)
            guard shouldThrow == false else {
                continutation.resume(throwing: DummyError())
                return
            }
            continutation.resume(returning: "\(int)")
        }
    }
    
    func asyncStringToString(_ string: String) async -> String {
        return await withCheckedContinuation { continutation in
            Thread.sleep(forTimeInterval: self.sleepInterval)
            continutation.resume(returning: "converted-\(string)")
        }
    }
    
    func asyncStringToStringWithThrowing(_ string: String,
                                         shouldThrow: Bool = false) async throws -> String {
        return try await withCheckedThrowingContinuation { continutation in
            Thread.sleep(forTimeInterval: self.sleepInterval)
            guard shouldThrow == false else {
                continutation.resume(throwing: DummyError())
                return
            }
            continutation.resume(returning: "converted-\(string)")
        }
    }
    
    private let source: PublishSubject<Int> = .init()
}


extension ObservableDoNotationTests {
    
    func testObservable_combineAsyncTasks() {
        // given
        let expect = expectation(description: "combine asyn tasks inside flatmap")
        var result: String?
        let observable = self.source
            .flatMap { [weak self] int async throws -> String? in
                guard let self = self else { return nil }
                let str1 = await self.asyncIntToString(int)
                let str2 = try await self.asyncStringToStringWithThrowing(str1)
                return await self.asyncStringToString(str2)
            }
        
        // when
        observable
            .subscribe(onNext: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        source.onNext(10)
        self.wait(for: [expect], timeout: 0.001)
        
        // then
        XCTAssertEqual(result, "converted-converted-10")
    }
    
    func testObservable_combineAyncTasks_withError() {
        // given
        let expect = expectation(description: "combine asyn tasks inside flatmap but throw error")
        let expectForOnNext = expectation(description: "should not fulfill onNext")
        expectForOnNext.isInverted = true
        var result: String?
        var error: Error?
        let observable = self.source
            .flatMap { [weak self] int async throws -> String? in
                guard let self = self else { return nil }
                let str1 = await self.asyncIntToString(int)
                let str2 = try await self.asyncStringToStringWithThrowing(str1, shouldThrow: true)
                return await self.asyncStringToString(str2)
            }
        
        // when
        observable
            .subscribe(onNext: {
                result = $0
                expectForOnNext.fulfill()
            }, onError: {
                error = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        source.onNext(10)
        self.wait(for: [expect, expectForOnNext], timeout: 0.001)
        
        // then
        XCTAssertEqual(result, nil)
        XCTAssertNotNil(error)
    }
}


