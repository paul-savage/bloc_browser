//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Paul Savage on 29/09/2015.
//  Copyright (c) 2015 Paul Savage. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *disabledColors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, weak)   NSTimer *longPressTimer;
@property (nonatomic) CGFloat lastScale;

@end

@implementation AwesomeFloatingToolbar

- (instancetype)initWithFourTitles:(NSArray *)titles {
    
    // First, call the superclass (UIView's) initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles and set the four colors
        self.currentTitles = titles;
        self.colors = [NSMutableArray arrayWithArray:@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                                                       [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                                                       [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                                                       [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]]];
        
        self.disabledColors = [NSMutableArray arrayWithArray:@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:.25],
                                                       [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:.25],
                                                       [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:.25],
                                                       [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:.25]]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the four labels
        for (NSString *currentTitle in self.currentTitles) {
            
            //UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            button.enabled = NO;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            //UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            UIColor *disabledColorForThisLabel = [self.disabledColors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.userInteractionEnabled = NO;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.backgroundColor = disabledColorForThisLabel;
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
 
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
            [self setEnabled:NO forButtonWithTitle:thisButton.currentTitle];
        }
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGesture.minimumPressDuration = 1.0;
        [self addGestureRecognizer:self.longPressGesture];
        
        self.lastScale = 1.0;
    }
    
    return self;
}

- (void)layoutSubviews {
    
    // set the frames for the four buttons
    for (UIButton *thisButton in self.buttons) {
        
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust buttonY for each button
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        // adjust labelX for each label
        if (currentButtonIndex % 2 == 0) {
            // 0 or 2, so on left
            buttonX = 0;
        } else {
            // 1 or 3, son on right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        CGRect newFrame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        thisButton.frame = newFrame;
        thisButton.titleLabel.frame = newFrame;
    }
}

#pragma mark - Touch Handling

- (void)buttonTapped:(UIButton *)targetButton {
    
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:targetButton.currentTitle];
    }
}

- (void)panFired:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)pinchFired:(UIPinchGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        self.lastScale = 1.0;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat newScale = recognizer.scale / (self.lastScale > 0 ? self.lastScale : 1.0);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:newScale];
        }
        
        self.lastScale = recognizer.scale;
    }
}

- (void)longPressFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self.longPressTimer invalidate];
        self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                               target:self
                                                             selector:@selector(cycleColors)
                                                             userInfo:nil
                                                              repeats:YES];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [self.longPressTimer invalidate];
    }
}

- (void)cycleColors {
    
    UIColor *firstColor = self.colors[0];
    UIColor *firstDisabledColor = self.disabledColors[0];
    
    NSInteger numberOfColors = [self.colors count];
    
    for (int i = 0; i < numberOfColors - 1; i++) {
        
        self.colors[i] = self.colors[i + 1];
        self.disabledColors[i] = self.disabledColors[i + 1];
        
        if ([self alphaFromColor:((UIButton *)self.buttons[i]).backgroundColor] > 0.5) {
            ((UIButton *)self.buttons[i]).backgroundColor = self.colors[i];
        } else {
            ((UIButton *)self.buttons[i]).backgroundColor = self.disabledColors[i];
        }
    }
    
    self.colors[numberOfColors - 1] = firstColor;
    self.disabledColors[numberOfColors - 1] = firstDisabledColor;
    
    if ([self alphaFromColor:((UIButton *)self.buttons[numberOfColors - 1]).backgroundColor] > 0.5) {
        ((UIButton *)self.buttons[numberOfColors - 1]).backgroundColor = self.colors[numberOfColors - 1];
    } else {
        ((UIButton *)self.buttons[numberOfColors - 1]).backgroundColor = self.disabledColors[numberOfColors - 1];
    }
}

#pragma mark - Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
   
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        
        UIButton *button = [self.buttons objectAtIndex:index];
        button.enabled = enabled;
        button.backgroundColor = enabled ? self.colors[index] : self.disabledColors[index];
    }
}

#pragma mark - Miscellaneous

- (CGFloat)alphaFromColor:(UIColor *)color {
    
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return alpha;
}

@end
