/*
 * CustomWKWebView.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@interface CustomWKWebView : WKWebView<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic, copy) void (^updateSearchBarTextBlock)(NSString*);
@property(nonatomic, copy) void (^finishNavigationProgressBlock)(void);
@property(nonatomic, copy) void (^updateHistoryNumber)(void);
@property(nonatomic, copy) void (^saveHistory)(NSString*);
@property(nonatomic, strong) NSMutableArray* loadedRequests;

+ (instancetype)sharedInstance;
- (void)initialize;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;
@end
