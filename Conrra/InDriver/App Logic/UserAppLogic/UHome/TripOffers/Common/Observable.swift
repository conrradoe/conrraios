//
//  Observable.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit

class Observable<T> {
    typealias Listener = (T) -> Void
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
