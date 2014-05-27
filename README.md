GPDownloadProgressView
======================

This progress view is inspired by the download progress view in the Apple App Store, iOS 7.

## Requirements

- XCode 4.4+
- Deployment Target iOS5.0+
- ARC

## Installation

The recommended way is to use [CocoaPods](http://cocoapods.org/) package manager.

To install using CocoaPods open your Podfile and add:
``` bash
pod 'GPDownloadProgressView', :git => 'https://github.com/gpinigin/GPDownloadProgressView.git'
```

## Usage

Just use it as it is a normal UIProgressView. Make sure you set the progress value in the main thread ;)

```objective-c
double delayInSeconds = 2.0;
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        for (float i=0; i<1.1; i+=0.01F) {
            dispatch_async(dispatch_get_main_queue(), ^{
		circularProgressView.progress = i;
            });
            usleep(10000);
        }            
    });
});
```

You can also control the progress view spin animation by using the following two methods to start and stop the spinning, respectively:

```objective-c
// Start spinning
[circularProgressView startAnimating];

// Stop spinning
[circularProgressView stopAnimating];
```

## Acknowledgments

This code is based on [FFCircularProgressView][credits-uri]

[credits-uri]: https://github.com/elbryan/FFCircularProgressView

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

## Android

Are you an Android developer and you love this progress view? No problem! A couple of folks ported it to Android OS and you can get it [here](https://github.com/torryharris/TH-ProgressButton).
