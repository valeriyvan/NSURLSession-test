//
//  ViewController.swift
//  NSURLSession-test
//
//  Created by Valeriy Van on 28.04.16.
//  Copyright © 2016 Valeriy Van. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
   
        guard let pathname = NSBundle.mainBundle().pathForResource("IMG_5520", ofType: "JPG") else { return }

        let request = NSMutableURLRequest(URL: NSURL(string:"http://w7software.com/trax/upload")!)
        
        request.HTTPMethod = "POST"
        
        let boundary = "Boundary-" + NSUUID().UUIDString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        guard let bodyPathname = pathForBodyFile(boundary, pathname: pathname) else { return }
        
        let task = uploadSession.uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: bodyPathname))
        
        print("\(#function) task id=\(task.taskIdentifier)")

        //task.resume()
    }

    private lazy var uploadSession: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.NSURLSession-test.backgroundSession")
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 1
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }()

    // Helper function creates temporary file being uploaded
    func pathForBodyFile(boundary: String, pathname: String) -> String? {
        
        let pathnameForTmpFile = pathForSavingFiles((pathname as NSString).lastPathComponent)
        
        guard NSFileManager.defaultManager().createFileAtPath(pathnameForTmpFile, contents: nil, attributes: nil) else { return nil }
        
        guard let fileHandle = NSFileHandle(forWritingAtPath: pathnameForTmpFile) else { return nil }
        
        fileHandle.truncateFileAtOffset(0)
        fileHandle.seekToEndOfFile()
        
        var data: NSData?
        do {
            data = try NSData(contentsOfFile: pathname, options: .DataReadingMappedIfSafe)
        } catch let error as NSError {
            print(error)
        }
        
        let mimetype = mimeType(pathname:pathname)
        
        fileHandle.writeData(NSString(format: "--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        fileHandle.writeData(NSString(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", (pathname as NSString).lastPathComponent, pathname).dataUsingEncoding(NSUTF8StringEncoding)!)
        fileHandle.writeData(NSString(format: "Content-Type: %@\r\n\r\n", mimetype).dataUsingEncoding(NSUTF8StringEncoding)!)
        fileHandle.writeData(data!)
        fileHandle.writeData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        fileHandle.writeData(NSString(format: "--%@--\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        fileHandle.closeFile()
        
        return pathnameForTmpFile
    }
    
    func pathForSavingFiles(filename:String) -> String {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask ,true)
        let path = "\(paths.firstObject!)/\(filename)"
        return path
    }

    func mimeType(pathname pathname: String) -> String {
        
        let url = NSURL(fileURLWithPath: pathname)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue(),
            let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return mimetype as String
        }
        return "application/octet-stream";
    }
}

extension ViewController: NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("\(#function): task id=\(task.taskIdentifier) sent \(totalBytesSent) of \(totalBytesExpectedToSend)")
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print("\(#function): task id=\(dataTask) got \(data.length) bytes of responce")
        if let responseString = String(data: data, encoding: NSUTF8StringEncoding) {
            print("response string: \(responseString)")
        }
    }
    
    // NSURLSessionTaskDelegate
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        var errorDescription = "no error"
        if let error = error {
            errorDescription = error.description
        }
        print("\(#function): task id=\(task.taskIdentifier) complete with error \(errorDescription)")
    }
    
    // NSURLSessionDelegate
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("\(#function)")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.backgroundURLSessionCompletionHandler()
    }
}


