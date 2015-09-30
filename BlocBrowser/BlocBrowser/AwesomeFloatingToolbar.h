//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Paul Savage on 29/09/2015.
//  Copyright (c) 2015 Paul Savage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale;

@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype)initWithFourTitles:(NSArray *)titles;

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *) title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
