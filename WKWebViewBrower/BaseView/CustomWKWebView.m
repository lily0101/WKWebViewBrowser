/*
 * CustomWKWebView.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import "CustomWKWebView.h"

static CustomWKWebView* instance = nil;

@implementation CustomWKWebView

+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}


- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
    });
    return instance;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
  return instance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
{
  return instance;
}

- (void)initialize
{
    if (self)
    {
        // why can not be called in - (instancetype)init
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
        self.backgroundColor = UIColor.whiteColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.frame = [UIScreen mainScreen].bounds;
        NSData* historyData = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY];
        self.loadedRequests = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:historyData]];
    }
}

- (WKNavigation*)loadRequest:(NSURLRequest*)request
{

    NSString *urlText = nil;
    if (request && request.URL) {
        urlText = request.URL.absoluteString;
    }
    self.updateSearchBarTextBlock(urlText);
    return [super loadRequest:request];
}

#pragma mark - WKNavigationDelegate Implementation

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    // TODO: update search bar.
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    // TODO: Update progress
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    self.updateSearchBarTextBlock(self.URL.absoluteString);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // Latest is first.
    for (WKBackForwardListItem* item in self.loadedRequests)
    {
        if ([item.URL.absoluteString isEqualToString:self.URL.absoluteString])
        {
            [self.loadedRequests removeObject:item];
            break;
        }
    }
    [self.loadedRequests insertObject:self.backForwardList.currentItem atIndex:0];
    
    self.updateSearchBarTextBlock(self.URL.absoluteString);
    self.finishNavigationProgressBlock();
    self.updateHistoryNumber();
}
  
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
}

- (void)webView:(WKWebView *)webView requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame decisionHandler:(void (^)(WKPermissionDecision))decisionHandler
{
    
}

@end
