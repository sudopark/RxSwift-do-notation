//
//  File.swift
//  
//
//  Created by sudo.park on 2022/03/24.
//

import XCTest

import RxSwift

import RxSwiftDoNotation


// MARK: - test observable

class ObservableDoNotationTests: BaseTestsCase {
    
    func testObservableDoNotation_addAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "add async increased int")
        var result: Int?
        let source = Observable.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int? in
                guard let self = self else { return nil }
                let lhs = try await self.increase(int)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onNext: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(result, 2)
    }
    
    func testObservableDoNotation_erorrWhenAddAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "should fail add async increased int")
        var error: Error?
        let source = Observable.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int? in
                guard let self = self else { return nil }
                let lhs = try await self.increase(int, shouldFail: true)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onError: {
                error = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(error is TestError, true)
    }
    
    func testObservableDoNotation_cancel() {
        // given
        let expect = expectation(description: "should complete with cancel async task")
        var event: Event<Int>?
        let source = Observable<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] start -> Int? in
                guard let self = self else { return nil }
                async let increaseTaskTriggingResult = self.increase(start)
                return nil
            }
            .subscribe {
                event = $0
                expect.fulfill()
            }
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        if case .completed = event {
            XCTAssert(true)
        } else {
            XCTFail("event should be a completed")
        }
        XCTAssertEqual(self.didCanceledIncrease, true)
    }
}


// MARK: - test single

class SingleDoNotationTests: BaseTestsCase {
    
    struct SelfReleasedError: Error { }
    
    func testSingleDoNotation_addAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "add async increased int")
        var result: Int?
        let source = Single<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int in
                guard let self = self else { throw SelfReleasedError() }
                let lhs = try await self.increase(int)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onSuccess: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(result, 2)
    }
    
    func testSingleDoNotation_erorrWhenAddAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "should fail add async increased int")
        var error: Error?
        let source = Single<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int in
                guard let self = self else { throw SelfReleasedError() }
                let lhs = try await self.increase(int, shouldFail: true)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onFailure: {
                error = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(error is TestError, true)
    }
}


// MARK: - test Maybe

class MaybeDoNotationTests: BaseTestsCase {
    
    func testMaybeDoNotation_addAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "add async increased int")
        var result: Int?
        let source = Maybe<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int? in
                guard let self = self else { return nil }
                let lhs = try await self.increase(int)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onSuccess: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(result, 2)
    }
    
    func testMaybeDoNotation_erorrWhenAddAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "should fail add async increased int")
        var error: Error?
        let source = Maybe<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int? in
                guard let self = self else { return nil }
                let lhs = try await self.increase(int, shouldFail: true)
                let rhs = try await self.increase(int)
                async let sum = self.add(lhs, rhs: rhs)
                return await sum
            }
            .subscribe(onError: {
                error = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(error is TestError, true)
    }
    
    func testMaybeDoNotation_cancel() {
        // given
        let expect = expectation(description: "should complete with cancel async task")
        var event: MaybeEvent<Int>?
        let source = Maybe<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] start -> Int? in
                guard let self = self else { return nil }
                async let increaseTaskTriggingResult = self.increase(start)
                return nil
            }
            .subscribe {
                event = $0
                expect.fulfill()
            }
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        if case .completed = event {
            XCTAssert(true)
        } else {
            XCTFail("event should be a completed")
        }
        XCTAssertEqual(self.didCanceledIncrease, true)
    }
}


// MARK: - test Infallible

class InfallibleDoNotationTests: BaseTestsCase {
    
    func testInfallibleDoNotation_addAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "add async increased int")
        var result: Int?
        let source = Infallible<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] int -> Int? in
                guard let self = self else { return nil }
                do {
                    let lhs = try await self.increase(int)
                    let rhs = try await self.increase(int)
                    async let sum = self.add(lhs, rhs: rhs)
                    return await sum
                } catch {
                    return nil
                }
            }
            .subscribe(onNext: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(result, 2)
    }
    
    func testInfallibleDoNotation_cancel() {
        // given
        let expect = expectation(description: "should complete with cancel async task")
        var event: Event<Int>?
        let source = Infallible<Int>.just(0)
        
        // when
        source
            .flatMap { [weak self] start -> Int? in
                guard let self = self else { return nil }
                async let increaseTaskTriggingResult = self.increase(start)
                return nil
            }
            .subscribe {
                event = $0
                expect.fulfill()
            }
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        if case .completed = event {
            XCTAssert(true)
        } else {
            XCTFail("event should be a completed")
        }
        XCTAssertEqual(self.didCanceledIncrease, true)
    }
}
