#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

// Hook vào FigCapture (mediaserverd) để tráo frame
%hook BWStillImageSampleBufferSinkNode

- (void)renderSampleBuffer:(CMSampleBufferRef)sbuf forInput:(id)input {
    // Đọc settings từ Preferences
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mch.vcam.plist"];
    BOOL isEnabled = [prefs[@"isEnabled"] boolValue];
    
    if (isEnabled) {
        NSLog(@"[Vcam_mch] Tráo frame camera thật bằng ảnh giả!");
        // Logic thay CVPixelBuffer lấy từ mmap của Daemon
        // CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sbuf);
        // ... (Vcam Core logic goes here) ...
    }
    
    %orig(sbuf, input);
}

%end

// Hook overlay lên màn hình 
%hook UIWindow
- (void)layoutSubviews {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 30)];
        label.text = @"Vcam_Mch Active";
        label.textColor = [UIColor redColor];
        label.tag = 9999;
        [self addSubview:label];
    });
}
%end
