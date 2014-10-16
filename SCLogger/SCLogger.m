//
//  SCLogger.m
//  SCLogger
//
//  Created by Siriuscode Solutions on 05/09/14.
//  Copyright (c) 2014 Siriuscode Solutions. All rights reserved.
//

#import "SCLogger.h"

@interface SCLogger ()

@property (strong, nonatomic) NSMutableString *messageLog;
@property (strong, nonatomic) UITextView *logText;
@property (strong, nonatomic) NSFileHandle *logFile;
@property (assign, getter = isDragging) BOOL dragging;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) UIViewController *viewController;

@end

@implementation SCLogger


#pragma mark -
#pragma mark - Singleton class

+ (void)load
{
    [SCLogger performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (SCLogger *)sharedInstance
{
    static SCLogger *sharedInstance = nil;
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[SCLogger alloc] init];
        sharedInstance.messageLog = [[NSMutableString alloc] init];
        [sharedInstance.messageLog appendString:@"\nSCLogger start\n\n"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        sharedInstance.filename = [NSString stringWithFormat:@"%@.log", name];
        NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/%@", sharedInstance.filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
            [[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents: nil
                                                  attributes: nil];
        }
        
        sharedInstance.logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [sharedInstance.logFile seekToEndOfFile];

        #if DEBUG
        UILongPressGestureRecognizer* longRecon = [[UILongPressGestureRecognizer alloc] initWithTarget:sharedInstance action:@selector(show)];
        longRecon.numberOfTouchesRequired = 3;
        [sharedInstance.getWindow addGestureRecognizer:longRecon];
        #endif
    });
    return sharedInstance;
}



#pragma mark -
#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    
    self.view.frame = [self mainScreenBounds];
    
    self.logText = [[UITextView alloc] initWithFrame:[self mainScreenBounds]];
    self.logText.editable = NO;
    self.logText.textColor = [UIColor whiteColor];
    self.logText.delegate = self;
    
    self.logText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleBottomMargin;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark -
#pragma mark - Public methods class

+ (void)showDebug
{
    [self.sharedInstance show];
}

+ (void)closeDebug
{
    [self.sharedInstance close];
}

+ (void)log:(NSString *)format
{
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

- (CGRect)mainScreenBounds
{
    CGRect bounds = [[UIScreen mainScreen] bounds]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
    }
    return bounds;
}

- (UIWindow *)getWindow
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    return window;
}

- (UIViewController *)visibleViewController
{
    UIViewController *rootViewController = [self getWindow].rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *) vc
{
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

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy HHmmss" options:0 locale:[NSLocale currentLocale]];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
    });
    
    return _dateFormatter;
}

- (void)sendMail
{
    if( [MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *nameApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        [picker setSubject:nameApp];
        
        NSString *emailBody = @"";
        
        NSString *arquivo = [NSString stringWithFormat:@"/Documents/%@", self.filename];
        NSString *caminho = [NSHomeDirectory() stringByAppendingPathComponent:arquivo];
        
        NSData *myData = [NSData dataWithContentsOfFile:caminho];
        [picker addAttachmentData:myData mimeType:@"text/plain" fileName:self.filename];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Please ensure that you have logged into your mail account" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }
}

- (void)show
{
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

- (void)close
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }];
    
}



#pragma mark -
#pragma mark - Function

void managerLogger(NSString *format, ...) {
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    
    fprintf(stderr, "%s", [string UTF8String]);
    [SCLogger log:string];
}

void managerLoggerv(NSString *format, va_list args) {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];

    fprintf(stderr, "%s", [string UTF8String]);
    [SCLogger log:string];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.logText.layoutManager.allowsNonContiguousLayout = NO;
}



#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
