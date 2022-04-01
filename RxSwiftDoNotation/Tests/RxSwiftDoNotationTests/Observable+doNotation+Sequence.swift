//
//  File.swift
//  
//
//  Created by sudo.park on 2022/04/01.
//

import XCTest

import RxSwift

import RxSwiftDoNotation


class ObservableDoNotationTests_sequence: BaseTestsCase {
    

    func testObservableDoNotation_flattenExpression_whichMakeAsyncSequence() {
        // given
        let expect = expectation(description: "should onNext event occur from flattened expression")
        var sum: Int?
        let source = Observable.just(Array(0..<10))
        
        // when
        source
            .flatMap { [weak self] ints -> Int? in
                guard let self = self else { return nil }
                let increads = AsyncStream.from(ints).map { try await self.increase($0) }
                return try await increads.reduce(0) { sum, next in
                    return await self.add(sum, rhs: next)
                }
            }
            .subscribe(onNext: {
                sum = $0
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: 0.1)
        
        // then
        XCTAssertEqual(sum, 55)
    }
}
