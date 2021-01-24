//
//  ViewController.swift
//  macos-application-opener
//
//  Created by Syritx on 2021-01-24.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var ipTextField : UITextField!
    var applicationTextField : UITextField!
    
    // networking
    var readStream : Unmanaged<CFReadStream>?
    var writeStream : Unmanaged<CFWriteStream>?
    var inputStream : InputStream!
    var outputStream : OutputStream!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.backgroundColor = .white
        
        let xSizeOffset = 20
        let ySizeOffset = 50
        let yOffset = 20
        let inlineOffset = 10
        
        let width = Int(UIScreen.main.bounds.width)-(xSizeOffset*2)
        
        ipTextField = UITextField()
        ipTextField.backgroundColor = .clear
        ipTextField.frame = CGRect(x: xSizeOffset, y: ySizeOffset+yOffset, width: width, height: ySizeOffset)
        ipTextField.textColor = .black
        ipTextField.attributedPlaceholder = NSAttributedString(string: "Server IP ADDR here",
                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        applicationTextField = UITextField()
        applicationTextField.backgroundColor = .clear
        applicationTextField.frame = CGRect(x: xSizeOffset, y: ySizeOffset*6+yOffset+10-50, width: width, height: ySizeOffset)
        applicationTextField.textColor = .white
        applicationTextField.attributedPlaceholder = NSAttributedString(string: "Insert application name here",
                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        let connectButton = UIButton()
        connectButton.backgroundColor = .link
        connectButton.frame = CGRect(x: xSizeOffset, y: ySizeOffset*2+yOffset+inlineOffset, width: width, height: ySizeOffset)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.setTitle("Connect to IP", for: .normal)
        connectButton.addTarget(self, action: #selector(connectToServer(_:)), for: .touchUpInside)
        
        let openAppl = UIButton()
        openAppl.backgroundColor = .red
        openAppl.frame = CGRect(x: xSizeOffset, y: ySizeOffset*7+yOffset+inlineOffset*2-50, width: width, height: ySizeOffset)
        openAppl.setTitleColor(.white, for: .normal)
        openAppl.setTitle("Open Application", for: .normal)
        openAppl.addTarget(self, action: #selector(openApplication(_:)), for: .touchUpInside)
        
        let menu = UILabel()
        menu.frame = CGRect(x: 0, y: ySizeOffset*3+yOffset+inlineOffset*2, width: width+xSizeOffset*80, height: width+xSizeOffset*80)
        menu.backgroundColor = .black
        menu.transform = CGAffineTransform(rotationAngle: 6.2)
        
        self.view = view
        view.addSubview(ipTextField)
        view.addSubview(connectButton)
        view.addSubview(menu)
        view.addSubview(applicationTextField)
        view.addSubview(openAppl)
    }
    
    @objc func openApplication(_ sender: UIButton) {
        
        var application = applicationTextField.text!
        print(application)
        
        if !application.hasSuffix(".app") {
            application = application+".app"
        }
        
        let data = ("[open_appl]:"+application).data(using: .utf8)!
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                return
            }
            outputStream!.write(pointer, maxLength: data.count)
        }
    }
    
    @objc func connectToServer(_ sender: UIButton) {
        
        let ip = ipTextField.text!
        let port = 6060
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ip as CFString, UInt32(port), &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
        
        print(ip)
    }
}

