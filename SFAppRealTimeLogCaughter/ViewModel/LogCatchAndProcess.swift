//
//  LogCatchAndProcess.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/11.
//

import Foundation

class LogCatchAndProcess {
    //MARK: - Private data
    private var rawLogData = LogDataModel()
    private var matchedLogData = LogDataModel()
    var receiveDelegate: ReceiveDataDelegate?
    var cleanDelegate: ClearDelegate?
    
    private var pipe = Pipe()
    private let fileDelegateQueue = DispatchQueue.global()
    private var source: DispatchSourceRead?
    private var filePathStr: String = ""
    private var matchStr: String = ""
    private var onOffState: Bool = false
    
    private var originalERR: Int32 = dup(STDERR_FILENO)
    private var originalOUT: Int32 = dup(STDOUT_FILENO)
    
    //MARK: - Init
    init() {
        redirect()
    }

    deinit {
        pipe.fileHandleForReading.readabilityHandler = nil
    }
}

//MARK: - IO
extension LogCatchAndProcess {
    public func returnLog(_ isSearching: Bool) -> String {
        var data: String = ""
        for item in (isSearching ? matchedLogData.getLog().suffix(MaxDisplayNumberInTextView) : rawLogData.getLog().suffix(MaxDisplayNumberInTextView)) {
            data += item
            data += "----------\n"
        }
        return data
    }
}

extension LogCatchAndProcess {
    public func switchState() -> Bool {
        defer {
            self.redirect()
        }
        self.onOffState = !self.onOffState
        return onOffState
    }
}

//MARK: - Catch
extension LogCatchAndProcess {
    func redirect() {
        if self.onOffState {
            setvbuf(stderr, nil, _IONBF, 0)
            setvbuf(stdout, nil, _IONBF, 0)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
            pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                let str = String(data: data, encoding: .utf8) ?? "<Non-utf8 data of size\(data.count)>\n"
                self?.rawLogData.setLog(data: str)
                self?.dataFiltAndAppend()
                DispatchQueue.main.async {
                    self?.receiveDelegate?.updateData()
                }
            }
        } else {
            dup2(self.originalERR, STDERR_FILENO)
            dup2(self.originalOUT, STDOUT_FILENO)
        }
        DispatchQueue.main.async {
            self.receiveDelegate?.updateData()
        }
    }
}

//MARK: - Search
extension LogCatchAndProcess: SearchDelegate {
    func search(_ matchStr: String) {
        self.matchStr = matchStr
        dataFiltAndAppend()
    }
}
extension LogCatchAndProcess {
    private func dataFiltAndAppend() {
        self.matchedLogData.clear()
        for item in self.rawLogData.getLog() {
            if item.contains(self.matchStr) {
                self.addMatchedLogData(item)
            }
        }
    }
    
    private func addMatchedLogData(_ data: String) {
        self.matchedLogData.setLog(data: data)
    }
}

//MARK: - Clean
extension LogCatchAndProcess {
    public func cleanAllAndStartAgain() {
        cleanDelegate?.cleanSearchBarText()
        self.rawLogData.clear() //需要先清空Model
        self.matchedLogData.clear()
        redirect()
    }
}

//MARK: - Save
extension LogCatchAndProcess {
    public func saveFile() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let date = Date()
        let saveFileFolderStr = documentsDirectory + "Log/" + date2String(date)
        self.filePathStr = saveFileFolderStr
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: URL(fileURLWithPath: saveFileFolderStr), withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        do {
            let rawLogFile = saveFileFolderStr + "/raw.txt"
            try self.rawLogData.getLogAsString().write(to: URL(fileURLWithPath: rawLogFile), atomically: true, encoding: .utf8)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        do {
            let matchedLogFile = saveFileFolderStr + "/matched.txt"
            try self.matchedLogData.getLogAsString().write(to: URL(fileURLWithPath: matchedLogFile), atomically: true, encoding: .utf8)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        NSLog("\nSave successed! \nPath: \(self.filePathStr)")
        return self.filePathStr
    }
    
    private func date2String(_ date:Date, dateFormat: String = "yyyy-MM-dd-HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
}
