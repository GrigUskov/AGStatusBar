//
//  AGStatusBar.m
//
//  Created by Grig Uskov
//  Copyright © 2016 ALSEDI Group. All rights reserved.
//

#import "AGStatusBar.h"
#import <objc/runtime.h>


@implementation AGStatusBar {
    UIImageView *tintColorView;
    NSString *prevSavedTime;
    NSMutableSet *hiddenItems;
    NSMutableDictionary <NSString *, NSMutableArray *> *customItems;
}



static NSString *_statusBarSelectorName = nil;
static NSString *_timeStringSelectorName = nil;

static Class _statusBarForegreoundViewClass = nil;
static Class _statusBarTimeItemViewClass = nil;
static Class _statusBarItemViewClass = nil;


+ (void)load {
    [super load];
    
#define ks_tatusBar @"tatusBar"
#define ks_UIStatusBar [@"UIS" stringByAppendingString:ks_tatusBar]
    _statusBarSelectorName = [@"s" stringByAppendingString:ks_tatusBar];
    _timeStringSelectorName = [@"_time" stringByAppendingString:@"String"];
    
    _statusBarForegreoundViewClass = NSClassFromString([ks_UIStatusBar stringByAppendingString:@"ForegroundView"]);
    _statusBarTimeItemViewClass = NSClassFromString([ks_UIStatusBar stringByAppendingString:@"TimeItemView"]);
    _statusBarItemViewClass = NSClassFromString([ks_UIStatusBar stringByAppendingString:@"ItemView"]);

    class_swizzleMethodAndStore(_statusBarForegreoundViewClass, @selector(layoutSubviews), (IMP)swizzledLayoutSubviews, (IMP *)&SwizzledLayoutSubviewsIMP);
}


+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AGStatusBar alloc] init];
        // Not using Key-Value Observation in case Clock view reinstanciated
        [NSTimer scheduledTimerWithTimeInterval:1 target:sharedInstance selector:@selector(everySecond) userInfo:nil repeats:1];
    });
    return sharedInstance;
}


- (void)forceLayout {
    [statusBarForegroundView() setNeedsLayout];
}


// ---------------------------- tintColor ------------------------------ //
- (void)setGlobalTintColor:(UIColor *)globalTintColor {
    _globalTintColor = globalTintColor;
    if (!_globalTintColor) {
        statusBarForegroundView().hidden = NO;
        [tintColorView removeFromSuperview];
        tintColorView = nil;
        [self applyCustomViewsSystemTintColor];
    } else
        [self forceLayout];
}


- (void)applyTintColor {
    UIGraphicsBeginImageContextWithOptions(statusBarForegroundView().bounds.size, NO, 0);
    statusBarForegroundView().hidden = NO;
    [statusBarForegroundView().layer renderInContext:UIGraphicsGetCurrentContext()];
    statusBarForegroundView().hidden = YES;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!tintColorView)
        [statusBarView() addSubview:tintColorView = [[UIImageView alloc] init]];
    tintColorView.image = tintImage(image, _globalTintColor);
}


- (void)applyCustomViewsSystemTintColor {
    UIColor *systemTintColor = [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault ? [UIColor blackColor] : [UIColor whiteColor];
    for (UIView *view in self.allCustomViews)
        if (view.tag != AGSB_DO_NOT_AUTOTINT_CUSTOM_VIEW) {
            if ([view isKindOfClass:[UILabel class]])
                ((UILabel *)view).textColor = systemTintColor;
            if ([view isKindOfClass:[UIImageView class]])
                ((UIImageView *)view).image = tintImage(((UIImageView *)view).image, systemTintColor);
        }
}


- (void)everySecond {
    NSString *newTime = [timeSystemView() valueForKey:_timeStringSelectorName];
    if (![newTime isEqualToString:prevSavedTime]) {
        prevSavedTime = newTime;
        if (!![AGStatusBar sharedInstance].globalTintColor && !timeSystemView().hidden)
            [self forceLayout];
    }
}


// ------------------------- System Views Hide ------------------------- //
- (void)setSystemView:(NSString *)viewKey hidden:(Boolean)hidden {
    if (!hiddenItems) hiddenItems = [NSMutableSet set];
    NSString *classKey = [NSString stringWithFormat:@"%@%@ItemView", ks_UIStatusBar, viewKey];
    if (!hidden)
        [hiddenItems removeObject:classKey];
    else
        [hiddenItems addObject:classKey];
    [self forceLayout];
}


// ---------------- UIStatusBarForegroundView Swizzling ---------------- //
typedef IMP *IMPPointer;
static void (*SwizzledLayoutSubviewsIMP)(id self, SEL _cmd);

static BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) { *store = imp; }
    return (imp != NULL);
}


static void swizzledLayoutSubviews(UIView *self, SEL _cmd) {
    SwizzledLayoutSubviewsIMP(self, _cmd);
    
    Boolean needsCustomLayout = [AGStatusBar sharedInstance].allCustomViews.count > 0;
    for (UIView *view in statusBarForegroundView().subviews) {
        view.hidden = [[AGStatusBar sharedInstance]->hiddenItems containsObject:NSStringFromClass(view.class)];
        needsCustomLayout |= view.hidden;
    }

    if (needsCustomLayout) {
#define _padding 6
#define _gap 4
        NSMutableArray *leftViews = [NSMutableArray arrayWithArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationLeftEdge]];
        [leftViews addObjectsFromArray:leftSystemViews()];
        [leftViews addObjectsFromArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationLeft]];
        spreadViews(leftViews, _padding, _gap, YES);
        
        NSMutableArray *rightViews = [NSMutableArray arrayWithArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationRightEdge]];
        [rightViews addObjectsFromArray:rightSystemViews()];
        [rightViews addObjectsFromArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationRight]];
        spreadViews(rightViews, statusBarForegroundView().frame.size.width - _padding, _gap, NO);
        
        NSMutableArray *centerViews = [NSMutableArray arrayWithArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationCenterLeft]];
        [centerViews addObject:timeSystemView()];
        [centerViews addObjectsFromArray:[[AGStatusBar sharedInstance] customViewsAtLocation:CustomViewLocationCenterRight]];
        CGFloat width = 0;
        for (UIView *view in centerViews)
            if (!view.hidden)
                width += view.frame.size.width;
        spreadViews(centerViews, (statusBarForegroundView().frame.size.width - width) / 2, _gap, YES);
    }
    
    if (!![AGStatusBar sharedInstance].globalTintColor) {
        [[AGStatusBar sharedInstance] applyTintColor];
        [AGStatusBar sharedInstance]->tintColorView.frame = statusBarForegroundView().frame;
    } else {
        [[AGStatusBar sharedInstance] applyCustomViewsSystemTintColor];
    }
}


static void spreadViews(NSArray *views, CGFloat padding, CGFloat gap, Boolean leftToRight) {
    CGFloat nextX = padding;
    for (UIView *v in views)
        if (!v.hidden) {
            if ([v isKindOfClass:_statusBarItemViewClass] && ![[v valueForKey:@"_visible"] boolValue]) continue;
            if (v.superview != statusBarForegroundView())
                [statusBarForegroundView() addSubview:v];
            if ([v isKindOfClass:[UILabel class]])
                [v sizeToFit];
            if (leftToRight) {
                v.frame = CGRectMake(nextX, 0, v.frame.size.width, 20);
                nextX += v.frame.size.width + gap;
            } else {
                v.frame = CGRectMake(nextX - v.frame.size.width, 0, v.frame.size.width, 20);
                nextX -= v.frame.size.width + gap;
            }
        }
}


// -------------------------- Custom Views ----------------------------- //
- (UILabel *)addText:(NSString *)text at:(AGStatusBarCustomViewLocation)location {
    UILabel *result = [[UILabel alloc] init];
    result.font = [UIFont systemFontOfSize:12];
    result.text = text;
    
    [self addCustomView:result at:location];
    return result;
}


- (UIImageView *)addImage:(UIImage *)image at:(AGStatusBarCustomViewLocation)location {
    UIImageView *result = [[UIImageView alloc] initWithImage:image];
    result.contentMode = UIViewContentModeCenter;
    
    [self addCustomView:result at:location];
    return result;
}


#define locationKey(a) [NSString stringWithFormat:@"%li", (long)a]

- (void)addCustomView:(UIView *)view at:(AGStatusBarCustomViewLocation)location {
    if (!customItems)
        customItems = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSMutableArray array], locationKey(CustomViewLocationLeftEdge),
                       [NSMutableArray array], locationKey(CustomViewLocationLeft),
                       [NSMutableArray array], locationKey(CustomViewLocationCenterLeft),
                       [NSMutableArray array], locationKey(CustomViewLocationCenterRight),
                       [NSMutableArray array], locationKey(CustomViewLocationRight),
                       [NSMutableArray array], locationKey(CustomViewLocationRightEdge), nil];
    for (NSMutableArray *items in customItems.allValues)
        [items removeObject:view];
    [customItems[locationKey(location)] addObject:view];
    [statusBarForegroundView() addSubview:view];
    
    [self forceLayout];
}


- (NSArray <UIView *> *)allCustomViews {
    NSMutableArray *result = [NSMutableArray array];
    for (NSArray *items in customItems.allValues)
        [result addObjectsFromArray:items];
    return result;
}


- (NSArray <UIView *> *)customViewsAtLocation:(AGStatusBarCustomViewLocation)location {
    return customItems[locationKey(location)];
}


- (void)removeCustomView:(UIView *)view {
    for (NSMutableArray *items in customItems.allValues)
        [items removeObject:view];
    [view removeFromSuperview];
    [self forceLayout];
}


- (void)removeAllCustomViews {
    for (NSMutableArray *items in customItems.allValues) {
        for (UIView *view in items)
            [view removeFromSuperview];
        [items removeAllObjects];
    }
    [self forceLayout];
}


// --------------------------------------------------------------------- //
static UIView *statusBarView() {
    if ([[UIApplication sharedApplication] respondsToSelector:NSSelectorFromString(_statusBarSelectorName)])
        return [[UIApplication sharedApplication] valueForKey:_statusBarSelectorName];
    return nil;
}


static UIView *statusBarForegroundView() {
    return subviewOfClass(statusBarView(), _statusBarForegreoundViewClass);
}


static UIView *subviewOfClass(UIView *view, Class class) {
    for (UIView *candidate in view.subviews)
        if (candidate.class == class)
            return candidate;
    return nil;
}


static NSMutableArray <UIView *>*leftSystemViews() {
    UIView *sbf = statusBarForegroundView();
    NSMutableArray *result = [NSMutableArray array];
    for (UIView *v in sbf.subviews)
        if (![[AGStatusBar sharedInstance].allCustomViews containsObject:v])
            if (v.frame.origin.x + v.frame.size.width < sbf.frame.size.width / 2)
                [result addObject:v];
    [result sortUsingComparator:^NSComparisonResult(UIView *v1, UIView *v2) {
        return [@(v1.frame.origin.x) compare:@(v2.frame.origin.x)];
    }];
    return result;
}


static NSMutableArray <UIView *>*rightSystemViews() {
    UIView *sbf = statusBarForegroundView();
    NSMutableArray *result = [NSMutableArray array];
    for (UIView *v in sbf.subviews)
        if (![[AGStatusBar sharedInstance].allCustomViews containsObject:v])
            if (v.frame.origin.x > sbf.frame.size.width / 2)
                [result addObject:v];
    [result sortUsingComparator:^NSComparisonResult(UIView *v1, UIView *v2) {
        return [@(v2.frame.origin.x) compare:@(v1.frame.origin.x)];
    }];
    return result;
}


static UIView *timeSystemView() {
    return subviewOfClass(statusBarForegroundView(), _statusBarTimeItemViewClass);
}


static UIImage *tintImage(UIImage *image, UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [color setFill];
    [[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] drawAtPoint:CGPointZero];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


@end

