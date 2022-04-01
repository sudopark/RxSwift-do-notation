//
//  File.swift
//  
//
//  Created by sudo.park on 2022/04/01.
//

import Foundation



// MARK: - AnyAsyncSequence

public struct AnyAsyncSequence<Source: AsyncSequence, Element>: AsyncSequence where Source.Element == Element {

    public struct Iterator<SourceIterator: AsyncIteratorProtocol>: AsyncIteratorProtocol where SourceIterator.Element == Element {

        private var sourceIterator: SourceIterator
        init(sourceIterator: SourceIterator) {
            self.sourceIterator = sourceIterator
        }

        public mutating func next() async throws -> Element? {
            return try await self.sourceIterator.next()
        }
    }

    public typealias AsyncIterator = Iterator<Source.AsyncIterator>

    private let source: Source
    public init(_ source: Source) {
        self.source = source
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(sourceIterator: self.source.makeAsyncIterator())
    }
}


// MARK: - EmptyAsyncSequence

public struct EmptyAsyncSequence<Element>: AsyncSequence {
    
    public struct Iterator: AsyncIteratorProtocol {
        
        public mutating func next() async throws -> Element? {
            return nil
        }
    }
    
    public typealias AsyncIterator = Iterator
    
    public typealias Element = Element
    
    public func makeAsyncIterator() -> Iterator {
        return Iterator()
    }
}


// MARK: - JustAsyncSequence

public struct JustAsyncSequence<Element>: AsyncSequence {
    
    public struct Iterator: AsyncIteratorProtocol {
        
        private var elements: [Element]
        init(elements: [Element]) {
            self.elements = elements
        }
        
        public mutating func next() async throws -> Element? {
            guard self.elements.isEmpty == false
            else {
                return nil
            }
            return self.elements.removeFirst()
        }
    }
    
    public typealias AsyncIterator = Iterator
    
    public typealias Element = Element
    
    private let sourceElements: [Element]
    public init(from elements: [Element]) {
        self.sourceElements = elements
    }
    
    public func makeAsyncIterator() -> Iterator {
        return Iterator(elements: self.sourceElements)
    }
}



// MARK: - AsyncSequence and AnyAsyncSequence protocol

extension AsyncSequence {

    public func asAny() -> AnyAsyncSequence<Self, Element> {
        return AnyAsyncSequence(self)
    }
}


extension AnyAsyncSequence {

    public func from(_ elements: [Element]) -> AnyAsyncSequence {

        return JustAsyncSequence(from: elements).asAny()
    }

    public func empty() -> AnyAsyncSequence {

        return EmptyAsyncSequence().asAny()
    }
}
