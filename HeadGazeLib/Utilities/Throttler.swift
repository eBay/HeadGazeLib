// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit
import Foundation

private extension Date {
    static func second(from referenceDate: Date) -> Float {
        return Float(Date().timeIntervalSince(referenceDate))
    }
}

public class Throttler {
    
    internal let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    internal var job: DispatchWorkItem = DispatchWorkItem(block: {})
    internal var previousRun: Date = Date.distantPast
    internal var maxInterval: Float
    
    init(seconds: Float) {
        self.maxInterval = seconds
    }
    
    func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date.second(from: previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}


