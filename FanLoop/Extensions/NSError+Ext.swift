//
//  NSError+Ext.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/11.
//

import Foundation

extension NSError {
    static var testError: NSError {
        NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    }
}
