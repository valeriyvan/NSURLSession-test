# NSURLSession-test
Project to illustrate question asked on stackoverflow

To be short, question is why suspended upload task starts uploading when app goes to background. According to documentation for [NSURLSessionTask](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionTask_class/index.html#//apple_ref/swift/cl/c:objc(cs)NSURLSessionTask) (NSURLSessionUpload task is subsclass of it), task is created suspended and has to be resumed to start working. Is this a bug? Or do I miss sumething?
