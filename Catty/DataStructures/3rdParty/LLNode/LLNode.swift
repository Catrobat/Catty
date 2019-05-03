// swiftlint:disable file_header
//
//  LList.swift
//  SwiftStructures
//
//  Created by Wayne Bishop on 6/7/14.
//  Copyright (c) 2014 Arbutus Software Inc. All rights reserved.
//
// swiftlint:enable file_header

import Foundation

class LLNode<T> {

    var key: T!
    var next: LLNode?
    var previous: LLNode?

}
