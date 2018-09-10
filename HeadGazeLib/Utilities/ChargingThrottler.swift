// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

typealias EventType = Int

public class ChargingThrottler: Throttler{
    
    private var currentEventType: EventType? = nil
    
    func throttle(eventtype: EventType, block: @escaping () -> ()) {
        if currentEventType != eventtype {
            self.previousRun = Date()
            currentEventType = eventtype
        }
        
        super.throttle {
            block()
        }
    }
}
