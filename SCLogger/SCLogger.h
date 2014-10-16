//
//  SCLogger.h
//  SCLogger
//
//  Created by Siriuscode Solutions on 05/09/14.
//  Copyright (c) 2014 Siriuscode Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#define NSLog(...) managerLogger(__VA_ARGS__)
#define NSLogv(...) managerLoggerv(__VA_ARGS__)

@interface SCLogger : UIViewController <UITextViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

+ (void)showDebug;
+ (void)closeDebug;
+ (void)log:(NSString *)format;

void managerLogger(NSString *format, ...);
void managerLoggerv(NSString *format, va_list args);

@end
