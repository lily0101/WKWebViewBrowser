/*
 * CustomWKWebViewController.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import "CustomWKWebViewController.h"
#import "ShareViewController.h"

@interface CustomWKWebViewController()

@property(nonatomic, strong) UIBarButtonItem *backButton;
@property(nonatomic, strong) UIBarButtonItem *forwardButton;
@property(nonatomic, strong) UIBarButtonItem *addButton;
@property(nonatomic, strong) UIBarButtonItem *historyButton;
@property(nonatomic, strong) UIBarButtonItem *shareButton;
@property(nonatomic, strong) HistoryWKWebViewController* historyController;
@property(nonatomic, strong) CustomWKWebView* wkWebView;

@end

@implementation CustomWKWebViewController

- (void)loadView
{
    [super loadView];
    [self addWebView];
    [self addToolBar:UIScreen.mainScreen.bounds.size];
}

- (void)dealloc
{
    NSData *favData = [NSKeyedArchiver archivedDataWithRootObject:self.wkWebView.loadedRequests];
    [[NSUserDefaults standardUserDefaults] setObject:favData forKey:HISTORY];
    self.wkWebView = nil;
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - Private

- (void)addWebView
{
    [self.view addSubview:self.wkWebView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    NSURLRequest* request = [NSURLRequest requestWithURL:HOME_URL];
    [self.wkWebView loadRequest:request];
}

- (void)addToolBar:(CGSize)size
{
    /*
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    button.tintColor = UIColor.blueColor;
    button.titleLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.wkWebView.loadedRequests.count];*/
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
    self.historyButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%lu",self.wkWebView.loadedRequests.count] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonClicked:)];
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(shareButtonClicked:)];
    
    UIImage* back = nil;
    UIImage* forward = nil;
    if (@available(iOS 13.0, *)) {
        back = [UIImage systemImageNamed:@"chevron.backward"];
        forward = [UIImage systemImageNamed:@"chevron.forward"];
    }
    else {
        back = [UIImage imageNamed:@"back"];
        forward = [UIImage imageNamed:@"forward"];
    }
    self.backButton = [[UIBarButtonItem alloc] initWithImage:back style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:forward style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonClicked:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (size.width > size.height)
    {
        // Landscape.
        self.navigationItem.leftBarButtonItems = @[self.backButton, flexibleSpace, self.forwardButton];
        self.navigationItem.rightBarButtonItems = @[self.shareButton,flexibleSpace,self.historyButton,flexibleSpace,self.addButton];
        [self.navigationController setToolbarHidden:YES];
    }
    else
    {
        // Portrait.
        self.toolbarItems = @[self.backButton, flexibleSpace, self.forwardButton, flexibleSpace, self.addButton, flexibleSpace, self.historyButton, flexibleSpace, self.shareButton];
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
        [self.navigationController setToolbarHidden:NO];
    }
}

#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.wkWebView) {
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:(float) self.wkWebView.estimatedProgress animated:animated];
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.hidden = YES;
            }                completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getter
- (WKWebView *)wkWebView
{
    if (_wkWebView == nil) {
        _wkWebView = [CustomWKWebView sharedInstance];
        [_wkWebView initialize];
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        __weak __typeof(self) weakSelf = self;
        _wkWebView.updateSearchBarTextBlock = ^(NSString* urlText){
            typeof(self) strongSelf = weakSelf;
            if(strongSelf.searchBar && urlText){
                strongSelf.searchBar.text = urlText;
            }
        };
        _wkWebView.updateHistoryNumber = ^() {
            typeof(self) strongSelf = weakSelf;
            [strongSelf.historyButton setTitle: [NSString stringWithFormat:@"%lu",strongSelf.wkWebView.loadedRequests.count]];
        };
        _wkWebView.finishNavigationProgressBlock = ^() {
            typeof(self) strongSelf = weakSelf;
            strongSelf.progressView.hidden = NO;
            [strongSelf.progressView setProgress:0.0 animated:NO];
        };
    }
    return _wkWebView;
}


#pragma mark - Actions

- (void)addButtonClicked:(UIButton*)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:HOME_URL];
    [self.wkWebView loadRequest:request];
    [self.historyButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.wkWebView.loadedRequests.count]];
}

- (void)backButtonClicked:(UIButton*)sender
{
    // Back to previous page.
    if ([self.wkWebView canGoBack])
    {
        [self.wkWebView goBack];
        // For oritentation changed.
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.wkWebView.URL]];
        // update search bar.
        self.searchBar.text = self.wkWebView.URL.absoluteString;
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)forwardButtonClicked:(UIButton*)sender
{
    if ([self.wkWebView canGoForward])
    {
        [self.wkWebView goForward];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.wkWebView.URL]];
        // update search bar.
        self.searchBar.text = self.wkWebView.URL.absoluteString;
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)historyButtonClicked:(UIButton*)sender
{
    if (self.historyController == nil)
    {
        self.historyController = [[HistoryWKWebViewController alloc] initWithNibName:@"HistoryView" bundle:[NSBundle mainBundle]];
        __weak __typeof(self) weakSelf = self;
        self.historyController.loadRequest = ^(NSURL* url){
            typeof(self) strongSelf = weakSelf;
            [strongSelf.navigationController dismissViewControllerAnimated:NO completion:^{
                NSURL *loadURL = url;
                if (loadURL == nil)
                {
                    loadURL = HOME_URL;
                }
                NSURLRequest *request = [NSURLRequest requestWithURL:loadURL];
                [strongSelf.wkWebView loadRequest:request];
            }];
        };
        self.historyController.closeHistoryView = ^{
            typeof(self) strongSelf = weakSelf;
            [strongSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
        };
    }
    self.historyController.historyList =  self.wkWebView.loadedRequests;
    [self.navigationController presentViewController:self.historyController animated:YES completion:nil];
}

- (void)shareButtonClicked:(UIButton*)sender
{
    UIImage *imageToShare = [MyHelper createImageWithView:self.wkWebView];
    ShareViewController *shareViewController = [ShareViewController new];
    shareViewController.thumbnail = imageToShare;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:@[shareViewController] applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.navigationController.view;
    activityViewController.excludedActivityTypes =
    @[UIActivityTypePrint,UIActivityTypeMail,
    UIActivityTypePrint,UIActivityTypeAddToReadingList,UIActivityTypeOpenInIBooks,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
    activityViewController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"completed");
        } else  {
            NSLog(@"cancled");
        }
    };
}

#pragma mark - Delegate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

       // Code here will execute before the rotation begins.
       // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    [self addToolBar:size];
    
   [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

       // Place code here to perform animations during the rotation.
       // You can pass nil or leave this block empty if not necessary.

   } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {

       // Code here will execute after the rotation has finished.
       // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]

   }];
}
@end
