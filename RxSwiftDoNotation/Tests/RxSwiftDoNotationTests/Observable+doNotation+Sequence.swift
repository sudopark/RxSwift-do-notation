//
//  File.swift
//  
//
//  Created by sudo.park on 2022/04/01.
//

import XCTest

import RxSwift

import RxSwiftDoNotation


class ObservableDoNotationTests_sequence: BaseTestsCase { }


extension ObservableDoNotationTests_sequence {
    
    func testObservableDoNotation_sequence_incraseIntArrayElements() {
        // given
        let expect = expectation(description: "async increased array elements")
        var result: [Int] = []
        let source = Observable.just(Array(0..<10))
        
        // when
        source
            .flatMap { [weak self] ints in
                return JustAsyncSequence.from(ints).map { try await self.increase($0) }
            }
            .subscribe(onNext: {
                result.append(contentsOf: $0)
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: 0.1)
        
        // then
        XCTAssertEqual(sum, 55)
    }
    
    func testObservableDoNotation_sequence_errorWhenSumAsyncIncreasedInts() {
        // given
        let expect = expectation(description: "fail to sum async increased ints")
        var error: Error?
        let source = Observable.just(Array(0..<10))
        
        // when
        source
            .flatMap { [weak self] ints -> Int? in
                guard let self = self else { return nil }
                let increads = AsyncStream.from(ints).map { try await self.increase($0, shouldFail: true) }
                return try await increads.reduce(0) { sum, next in
                    return await self.add(sum, rhs: next)
                }
            }
            .subscribe(onError: {
                error = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: 0.1)
        
        // then
        XCTAssertEqual(error is TestError, true)
    }
    
    func testObservableDoNotation_sequence_cancel() {
        // given
        let expect = expectation(description: "should complete with cancel async task")
        var event: Event<Int>?
        let source = Observable.just(Array(0..<10))
        var termination: AsyncThrowingStream<Int, Error>.Continuation.Termination?
        
        let sequenceSource = PublishSubject<Int>()
        
        // when
        source
            .flatMap { [weak self] ints -> Int? in
                guard let self = self else { return nil }
                return sequenceSource.values
            }
        // then
    }
}
