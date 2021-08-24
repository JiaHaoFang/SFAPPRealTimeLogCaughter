//
//  VSLogCaughterLogModel.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/12.
//

import Foundation
class LogDataModel {
    private var logData: [String] = []
    public var length: Int {
        get {
            var count: Int = 0
            for item in logData {
                count += item.count
            }
            return count
        }
    }

    init() {
        logData = []
    }
    
    public func setLog(data: String) {
        logData.append(data)
    }
    
    public func getLog() -> [String] {
        return self.logData
    }
    
    public func getLogAsString() -> String {
        var data: String = ""
        for item in self.logData {
            data += item
        }
        return data
    }
    
    public func clear() {
        self.logData = []
    }
}
