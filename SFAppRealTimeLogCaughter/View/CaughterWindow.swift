//
//  CaughterWindow.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/10.
//

import UIKit
import SnapKit

class CaughterWindow: UIWindow {
    //MARK: - Private data
    private var caughter: LogCatchAndProcess?
    private var wakeUpBtnPosition = CGPoint(x: sizeOfFloatBtn().edgeWidth, y: 200)
    
    //MARK: - Subviews
    private lazy var wakeUpView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = .clear
        return view
    }()
    private lazy var showLogView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = MyColor().backgroundColor
        return view
    }()
    private lazy var wakeUpBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeOfFloatBtn().x, height: sizeOfFloatBtn().y))
        btn.backgroundColor = UIColor.init(red: 0, green: 193/255, blue: 188/255, alpha: 0.5)
        btn.layer.cornerRadius = sizeOfFloatBtn().corner
        btn.addTarget(self, action: #selector(floatBtnAction(sender:)), for: .touchUpInside)
        return btn
    }()
    private lazy var hideBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(hideBtnAction), for: .touchUpInside)
        btn.setTitle("Hide", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        btn.setTitle("Save", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var clearBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(clearBtnAction), for: .touchUpInside)
        btn.setTitle("Clear", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.caughter?.cleanDelegate = self.searchBar
        return btn
    }()
    private lazy var onOffBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(onOffBtnAction), for: .touchUpInside)
        btn.setTitle("State", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var searchBar: SearchBarForWindow = {
        let sb = SearchBarForWindow()
        guard let caughter = caughter else { return sb }
        sb.searchDelegate = self.caughter
        return sb
    }()
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 0.6)
        tv.textColor = .black
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textAlignment = .left
        tv.layer.cornerRadius = 12
        tv.layer.masksToBounds = true
        tv.isScrollEnabled = true
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.isEditable = false
        tv.text = ""
        tv.isSelectable = true
        return tv
    }()
    private lazy var atuoScrollSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        return s
    }()
    private lazy var alertWindow: UIAlertController = {
        let alert = UIAlertController(title: "Saved successfully!\nFile path is:", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let copy = UIAlertAction(title: "Copy", style: .default, handler: {_ in
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = alert.message
        })
        alert.addAction(ok)
        alert.addAction(copy)
        return alert
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
}

//MARK: - IO
extension CaughterWindow {
    public func show() {
        self.isHidden = false
    }
}

//MARK: - UpdateData Delegate
extension CaughterWindow: ReceiveDataDelegate {
    func updateData() {
        guard let caughter = self.caughter else {
            print("error")
            return
        }
        
        self.textView.text = caughter.returnLog(self.searchBar.isActive)
        
        if self.atuoScrollSwitch.isOn {
            self.textView.setContentOffset(CGPoint(x: 0, y: self.textView.contentSize.height <= self.textView.frame.height ? 0 : self.textView.contentSize.height - self.textView.frame.height/1.3), animated: false)
        }
    }
}

//MARK: - Button Event Action
extension CaughterWindow {
    private func showWakeUpView() {
        self.frame = CGRect(x: wakeUpBtnPosition.x, y: wakeUpBtnPosition.y, width: sizeOfFloatBtn().x, height: sizeOfFloatBtn().y)
        self.showLogView.isHidden = true
        self.wakeUpView.isHidden = false
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:  #selector(floatBtnDragAction(gesture:))))
        self.rootViewController?.view.addSubview(self.wakeUpView)
    }
    
    private func showShowLogView() {
        self.frame = CGRect(x: 0, y: SafeAreaTopH, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
        self.wakeUpView.isHidden = true
        self.showLogView.isHidden = false
        self.gestureRecognizers?.removeAll()
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:  #selector(logWindowDragAction(gesture:))))
        self.rootViewController?.view.addSubview(self.showLogView)
    }
}

//MARK: - Configure
extension CaughterWindow {
    private func configure() {
        if self.caughter == nil {
            self.caughter = LogCatchAndProcess()
        }
        self.caughter?.receiveDelegate = self
        self.rootViewController = UIViewController()
        self.windowLevel =  UIWindow.Level.statusBar - 1
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.createWakeUpPage()
        self.createShowLogPage()
        self.showWakeUpView()
    }
    
    private func createWakeUpPage() {
        self.wakeUpView.frame = CGRect(x: 0, y: 0, width: sizeOfFloatBtn().x, height: sizeOfFloatBtn().y)
        self.wakeUpView.addSubview(self.wakeUpBtn)
    }
    
    private func createShowLogPage() {
        self.showLogView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
        
        self.showLogView.addSubview(hideBtn)
        self.showLogView.addSubview(saveBtn)
        self.showLogView.addSubview(clearBtn)
        self.showLogView.addSubview(onOffBtn)
        self.showLogView.addSubview(searchBar)
        self.showLogView.addSubview(textView)
        self.showLogView.addSubview(atuoScrollSwitch)
        
        self.hideBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.saveBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-65)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.clearBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-120)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.onOffBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-175)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.searchBar.snp.makeConstraints{ (make) in
            make.height.equalTo(36)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-210)
            make.left.equalToSuperview()
        }
        self.textView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(46 + 10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        self.atuoScrollSwitch.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(60)
        }
        
        self.searchBar.textField.delegate = self.searchBar
        self.searchBar.textField.addTarget(self, action: #selector(textFiledEditingChanged), for: .editingChanged)
    }
    
    @objc private func floatBtnAction(sender: UIButton) {
        self.showShowLogView()
        NSLog("floatBtnAction")
    }
    
    @objc private func hideBtnAction() {
        self.showWakeUpView()
        NSLog("hideBtnAction")
    }
    @objc private func saveBtnAction() {
        alertWindow.message = self.caughter?.saveFile()
        self.rootViewController?.present(alertWindow, animated: true, completion: nil)
        NSLog("saveBtnAction")
    }
    @objc private func clearBtnAction() {
        self.caughter?.cleanAllAndStartAgain()
        NSLog("clearBtnAction")
    }
    
    @objc private func onOffBtnAction() {
        guard caughter != nil else {
            return
        }
        if caughter!.switchState() {
            self.onOffBtn.setTitle("On", for: .normal)
            NSLog("State: On")
        } else {
            self.onOffBtn.setTitle("Off", for: .normal)
            NSLog("State: Off")
        }
        
        
    }
    
    @objc private func textFiledEditingChanged(_ textField: UITextField) {
        updateData()
    }
    
    @objc private func floatBtnDragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .began:
            break
        case .changed:
            let point = gesture.translation(in: self.wakeUpView)
            self.center = CGPoint(x: self.center.x + point.x, y: self.center.y + point.y)
            if self.center.y <= SafeAreaTopH + sizeOfFloatBtn().y/2 {
                self.center.y = SafeAreaTopH + sizeOfFloatBtn().y/2
            } else if self.center.y >= UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 - SafeAreaBottomH {
                self.center.y = UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 - SafeAreaBottomH
            }
            break
        case .ended:
            let point = gesture.translation(in: self.wakeUpView)
            var newPoint = CGPoint(x: self.center.x + point.x, y: self.center.y + point.y)
            
            if newPoint.x < UIScreen.main.bounds.width / 2.0 {
                newPoint.x = sizeOfFloatBtn().x/2 + sizeOfFloatBtn().edgeWidth
            } else {
                newPoint.x = UIScreen.main.bounds.width - sizeOfFloatBtn().x/2 - sizeOfFloatBtn().edgeWidth
            }
            UIView.animate(withDuration: 0.25) {
                self.center = newPoint
            }
            self.wakeUpBtnPosition.x = self.center.x - sizeOfFloatBtn().x/2
            self.wakeUpBtnPosition.y = self.center.y - sizeOfFloatBtn().y/2
            break
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: self.wakeUpView)
    }
    
    @objc func logWindowDragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .began:
            break
        case .changed:
            let point = gesture.translation(in: self.showLogView)
            self.center = CGPoint(x: self.center.x, y: self.center.y + point.y)
            if self.center.y <= SafeAreaBottomH + sizeOfFloatBtn().y/2 {
                self.center.y = SafeAreaBottomH + sizeOfFloatBtn().y/2
            } else if self.center.y >= UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 {
                self.center.y = UIScreen.main.bounds.height - sizeOfFloatBtn().y/2
            }
            break
        case .ended:
            let point = gesture.translation(in: self.showLogView)
            var newPoint = CGPoint(x: self.center.x, y: self.center.y + point.y)
            
            if newPoint.y <= SafeAreaTopH + self.bounds.height/2 {
                newPoint.y = SafeAreaTopH + self.bounds.height/2
            } else if newPoint.y >= UIScreen.main.bounds.height - self.bounds.height/2 - SafeAreaBottomH {
                newPoint.y = UIScreen.main.bounds.height - self.bounds.height/2 - SafeAreaBottomH
            }
            
            UIView.animate(withDuration: 0.25) {
                self.center = newPoint
            }
            
            self.wakeUpBtnPosition.y = self.center.y - self.bounds.height/2
            break
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: self.showLogView)
    }
}
