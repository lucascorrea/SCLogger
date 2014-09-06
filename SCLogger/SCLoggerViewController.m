//
//  SCLoggerViewController.m
//  SCLogger
//
//  Created by Siriuscode Solutions on 05/09/14.
//  Copyright (c) 2014 Siriuscode Solutions. All rights reserved.
//

#import "SCLoggerViewController.h"
#import "LoremIpsum.h"

@interface SCLoggerViewController (){
    dispatch_source_t generateTimer;
}

@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (strong, nonatomic) NSMutableString *logString;
@property (assign, getter = isDragging) BOOL dragging;
@property (assign, nonatomic) int index;
@property (strong, nonatomic) LoremIpsum *loremIpsum;

@end

@implementation SCLoggerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.logString = [[NSMutableString alloc] init];
    self.loremIpsum = [[LoremIpsum alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Methods

- (void)generatePhrase
{
    int numWords = random() % 1 + 1;
    NSString *bunchOfWords = [self.loremIpsum words:numWords];
    
    self.index++;

    [self.logString appendFormat:@"%i - %@\n", self.index, bunchOfWords];
    
    [self.logTextView setText:self.logString];
    
    NSLog(@"%i - %@\r", self.index, bunchOfWords);
    
    CGFloat height, offset;
    height = self.logTextView.contentSize.height - self.logTextView.bounds.size.height;
    offset = self.logTextView.contentOffset.y;
    
    if (height == offset) {
        self.dragging = NO;
    }
    
    if (!self.isDragging) {

        CGPoint p = [self.logTextView contentOffset];
        [self.logTextView setContentOffset:p animated:NO];
        [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
        [self.logTextView setScrollEnabled:NO];
        [self.logTextView setScrollEnabled:YES];
    
    }
}


#pragma mark -
#pragma mark - Button Action

- (IBAction)generateButtonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        generateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(generateTimer, DISPATCH_TIME_NOW, .4 * NSEC_PER_SEC, 0.25 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(generateTimer, ^{
            [self generatePhrase];
        });
        
        dispatch_resume(generateTimer);
    }else{
        dispatch_source_cancel(generateTimer);
    }
}

- (IBAction)tapGesture:(id)sender
{
    [SCLogger showDebug];
}



#pragma mark -
#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.logTextView.layoutManager.allowsNonContiguousLayout = NO;
}

@end
