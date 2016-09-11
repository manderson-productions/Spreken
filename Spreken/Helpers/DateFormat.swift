//
//  DateFormat.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import Foundation

class DateFormat {

    static let sharedInstance = DateFormat()

    fileprivate let dateFormatter = DateFormatter()

    fileprivate init() {
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .medium
        self.dateFormatter.locale = Locale.current
    }

    open func stringFromDate(date: Date) -> String {
        return self.dateFormatter.string(from: date)
    }
}
