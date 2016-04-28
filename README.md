# NSURLSession-test
Protect to illustrate question asked on stackoverflow

To be short, question is why suspended upload task starts uploading when app goes to background. According to documentation for NSURLSessionTask (NSURLSessionUpload task is subsclass of it), task is created suspended and has to be resumed to start working. Is this a bug? Or do I miss sumething?
