//
//  SCLogger.m
//  SCLogger
//
//  Created by Siriuscode Solutions on 05/09/14.
//  Copyright (c) 2014 Siriuscode Solutions. All rights reserved.
//

#import "SCLogger.h"
#include <sys/sysctl.h>

@interface SCLogger ()

@property (strong, nonatomic) NSMutableString *messageLog;
@property (strong, nonatomic) UITextView *logText;
@property (strong, nonatomic) NSFileHandle *logFile;
@property (assign, getter = isDragging) BOOL dragging;
@property (assign, getter = isShow) BOOL show;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) UIViewController *viewController;

@end

@implementation SCLogger


#pragma mark -
#pragma mark - Singleton class

+ (void)load {
    [SCLogger performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (SCLogger *)sharedInstance {
    static SCLogger *sharedInstance = nil;
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[SCLogger alloc] init];
        sharedInstance.messageLog = [[NSMutableString alloc] init];
        
        [sharedInstance.messageLog appendString:@"\nSCLogger start\n\nDouble tap to close.\nTouch with two fingers to send log to email.\n\n"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        
        sharedInstance.filename = [NSString stringWithFormat:@"%@.log", name];
        NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/%@", sharedInstance.filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
            [[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents: nil
                                                  attributes: nil];
        }
        
        sharedInstance.logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [sharedInstance.logFile seekToEndOfFile];
        
    });
    return sharedInstance;
}



#pragma mark -
#pragma mark - Init methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    
    self.view.frame = [self mainScreenBounds];
    
    self.logText = [[UITextView alloc] initWithFrame:[self mainScreenBounds]];
    self.logText.editable = NO;
    self.logText.selectable = NO;
    self.logText.textColor = [UIColor whiteColor];
    self.logText.delegate = self;
    
    
    self.logText.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.logText];
    
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(close)];
    tapRecon.numberOfTapsRequired = 2;
    tapRecon.numberOfTouchesRequired = 1;
    [self.logText addGestureRecognizer:tapRecon];
    
    UITapGestureRecognizer* tapReconEmail = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(sendMail)];
    tapReconEmail.numberOfTapsRequired = 1;
    tapReconEmail.numberOfTouchesRequired = 2;
    [self.logText addGestureRecognizer:tapReconEmail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark -
#pragma mark - Public methods class

+ (void)enabledLogger {
#if SCLOGGER_DEBUG
    UILongPressGestureRecognizer* longRecon = [[UILongPressGestureRecognizer alloc] initWithTarget:self.sharedInstance action:@selector(show)];
    longRecon.numberOfTouchesRequired = 3;
    [self.sharedInstance.getWindow addGestureRecognizer:longRecon];
#endif
}

+ (void)showDebug {
    [self.sharedInstance show];
}

+ (void)closeDebug {
    [self.sharedInstance close];
}

+ (void)log:(NSString *)format {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *date = [self.sharedInstance.dateFormatter stringFromDate:[NSDate date]];
        
        NSString *string = [NSString stringWithFormat:@"%@ - %@\n",date, format];
        
        [self.sharedInstance.messageLog appendString:string];
        
        CGFloat height, offset;
        height = self.sharedInstance.logText.contentSize.height - self.sharedInstance.logText.bounds.size.height;
        offset = self.sharedInstance.logText.contentOffset.y;
        
        [self.sharedInstance.logFile writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (height == offset) {
            self.sharedInstance.dragging = NO;
            self.sharedInstance.logText.layoutManager.allowsNonContiguousLayout = YES;
        }
        
        self.sharedInstance.logText.text = self.sharedInstance.messageLog;
        
        if (!self.sharedInstance.isDragging) {
            CGPoint p = [self.sharedInstance.logText contentOffset];
            [self.sharedInstance.logText setContentOffset:p animated:NO];
            [self.sharedInstance.logText scrollRangeToVisible:NSMakeRange([self.sharedInstance.logText.text length], 0)];
            [self.sharedInstance.logText setScrollEnabled:NO];
            [self.sharedInstance.logText setScrollEnabled:YES];
        }
    }];
}



#pragma mark -
#pragma mark - Private methods

- (CGRect)mainScreenBounds {
    CGRect bounds = [[UIScreen mainScreen] bounds]; // portrait bounds
    //    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    //        bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
    //    }
    return bounds;
}

- (UIWindow *)getWindow {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    return window;
}

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = [self getWindow].rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy HHmmss" options:0 locale:[NSLocale currentLocale]];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
    });
    
    return _dateFormatter;
}

- (void)sendMail {
    if( [MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *nameApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        
        [picker setSubject:nameApp];
        
        UIDevice *myDevice = [UIDevice currentDevice];
        NSUUID *uuid = [NSUUID UUID];
        NSString *deviceUDID = uuid.UUIDString;
        NSString *deviceName = myDevice.name;
        NSString *deviceSystemName = myDevice.systemName;
        NSString *deviceOSVersion = myDevice.systemVersion;
        NSString *devicePlatform = [self platformString];
        NSString *device = [NSString stringWithFormat:@"\nUDID: %@\nName: %@\nVersion: %@%@\nDevice: %@",deviceUDID,deviceName, deviceSystemName,deviceOSVersion,devicePlatform];
        
        NSString *emailBody = device;
        
        NSString *arquivo = [NSString stringWithFormat:@"/Documents/%@", self.filename];
        NSString *caminho = [NSHomeDirectory() stringByAppendingPathComponent:arquivo];
        
        NSData *myData = [NSData dataWithContentsOfFile:caminho];
        [picker addAttachmentData:myData mimeType:@"text/plain" fileName:self.filename];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self.viewController presentViewController:picker animated:YES completion:nil];
    } else {
        
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Cannot send email";
        alertController.message = @"Please ensure that you have logged into your mail account";
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)show {
    if (self.isShow)
        return;
    
    self.show = YES;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (self.view != nil) {
            self.view.alpha = 0;
        }
        
        self.dragging = NO;
        
        self.viewController = [self visibleViewController];
        [self.viewController.view addSubview:self.view];
        self.view.frame = [self mainScreenBounds];
        self.logText.frame = [self mainScreenBounds];
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.view.alpha = 1;
            self.logText.text = self.messageLog;
            CGPoint bottomOffset = CGPointMake(0, self.logText.contentSize.height - self.logText.bounds.size.height);
            
            if (bottomOffset.y > 0) {
                [self.logText setContentOffset:bottomOffset animated:YES];
            }
        } completion:^(BOOL finished) {}];
    }];
}

- (void)close {
    self.show = NO;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }];
    
}

- (NSString *) platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

- (NSString *) platformString {
    NSString *platform = [self platform];
    
    NSDictionary *platformStrings = @{
#if !defined(TARGET_OS_IOS) || TARGET_OS_IOS
                                      @"iPhone1,1": @"iPhone 1G",
                                      @"iPhone1,2": @"iPhone 3G",
                                      @"iPhone2,1": @"iPhone 3GS",
                                      @"iPhone3,1": @"iPhone 4 (GSM)",
                                      @"iPhone3,2": @"iPhone 4 (GSM Rev A)",
                                      @"iPhone3,3": @"iPhone 4 (CDMA)",
                                      @"iPhone4,1": @"iPhone 4S",
                                      @"iPhone5,1": @"iPhone 5 (GSM)",
                                      @"iPhone5,2": @"iPhone 5 (GSM+CDMA)",
                                      @"iPhone5,3": @"iPhone 5C (GSM)",
                                      @"iPhone5,4": @"iPhone 5C (GSM+CDMA)",
                                      @"iPhone6,1": @"iPhone 5S (GSM)",
                                      @"iPhone6,2": @"iPhone 5S (GSM+CDMA)",
                                      @"iPhone7,1": @"iPhone 6 Plus",
                                      @"iPhone7,2": @"iPhone 6",
                                      @"iPhone8,1": @"iPhone 6s",
                                      @"iPhone8,2": @"iPhone 6s Plus",
                                      @"iPhone9,4": @"iPhone 7 Plus",
                                      @"iPhone9,2": @"iPhone 7 Plus",
                                      @"iPhone9,3": @"iPhone 7",
                                      @"iPhone9,1": @"iPhone 7",
                                      @"iPhone10,1" : @"iPhone 8",
                                      @"iPhone10,4" : @"iPhone 8",
                                      @"iPhone10,2" : @"iPhone 8 Plus",
                                      @"iPhone10,5" : @"iPhone 8 Plus",
                                      @"iPhone10,3" : @"iPhone X",
                                      @"iPhone10,6" : @"iPhone X",
                                      @"iPhone8,4": @"iPhone SE",
                                      @"iPod1,1": @"iPod Touch 1G",
                                      @"iPod2,1": @"iPod Touch 2G",
                                      @"iPod3,1": @"iPod Touch 3G",
                                      @"iPod4,1": @"iPod Touch 4G",
                                      @"iPod5,1": @"iPod Touch 5G",
                                      @"iPod7,1": @"iPod Touch 6G",
                                      @"iPad1,1": @"iPad 1",
                                      @"iPad2,1": @"iPad 2 (WiFi)",
                                      @"iPad2,2": @"iPad 2 (GSM)",
                                      @"iPad2,3": @"iPad 2 (CDMA)",
                                      @"iPad2,4": @"iPad 2",
                                      @"iPad2,5": @"iPad Mini (WiFi)",
                                      @"iPad2,6": @"iPad Mini (GSM)",
                                      @"iPad2,7": @"iPad Mini (GSM+CDMA)",
                                      @"iPad3,1": @"iPad 3 (WiFi)",
                                      @"iPad3,2": @"iPad 3 (GSM+CDMA)",
                                      @"iPad3,3": @"iPad 3 (GSM)",
                                      @"iPad3,4": @"iPad 4 (WiFi)",
                                      @"iPad3,5": @"iPad 4 (GSM)",
                                      @"iPad3,6": @"iPad 4 (GSM+CDMA)",
                                      @"iPad4,1": @"iPad Air (WiFi)",
                                      @"iPad4,2": @"iPad Air (WiFi/Cellular)",
                                      @"iPad4,3": @"iPad Air (China)",
                                      @"iPad4,4": @"iPad Mini Retina (WiFi)",
                                      @"iPad4,5": @"iPad Mini Retina (WiFi/Cellular)",
                                      @"iPad4,6": @"iPad Mini Retina (China)",
                                      @"iPad4,7": @"iPad Mini 3 (WiFi)",
                                      @"iPad4,8": @"iPad Mini 3 (WiFi/Cellular)",
                                      @"iPad5,1": @"iPad Mini 4 (WiFi)",
                                      @"iPad5,2": @"iPad Mini 4 (WiFi/Cellular)",
                                      @"iPad5,3": @"iPad Air 2 (WiFi)",
                                      @"iPad5,4": @"iPad Air 2 (WiFi/Cellular)",
                                      @"iPad6,3": @"iPad Pro 9.7-inch (WiFi)",
                                      @"iPad6,4": @"iPad Pro 9.7-inch (WiFi/Cellular)",
                                      @"iPad6,7": @"iPad Pro 12.9-inch (WiFi)",
                                      @"iPad6,8": @"iPad Pro 12.9-inch (WiFi/Cellular)",
                                      @"iPad6,11": @"iPad 5 (WiFi)",
                                      @"iPad6,12": @"iPad 5 (WiFi/Cellular)",
                                      @"iPad7,1": @"iPad Pro 12.9-inch 2nd-gen (WiFi)",
                                      @"iPad7,2": @"iPad Pro 12.9-inch 2nd-gen (WiFi/Cellular)",
                                      @"iPad7,3": @"iPad Pro 10.5-inch (WiFi)",
                                      @"iPad7,4": @"iPad Pro 10.5-inch (WiFi/Cellular)",
#endif
#if TARGET_OS_TV
                                      @"AppleTV5,3": @"Apple TV 4G",
#endif
#if !defined(TARGET_OS_SIMULATOR) || TARGET_OS_SIMULATOR
                                      @"i386": @"Simulator",
                                      @"x86_64": @"Simulator",
#endif
                                      };
    
    return platformStrings[platform] ?: platform;
}


#pragma mark -
#pragma mark - Function

void managerLogger(NSString *format, ...) {
#if SCLOGGER_DEBUG
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    
    fprintf(stderr, "%s\n", [string UTF8String]);
    [SCLogger log:string];
#endif
}

void managerLoggerv(NSString *format, va_list args) {
#if SCLOGGER_DEBUG
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    
    fprintf(stderr, "%s\n", [string UTF8String]);
    [SCLogger log:string];
#endif
}

#pragma mark -
#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.logText.layoutManager.allowsNonContiguousLayout = NO;
}



#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
