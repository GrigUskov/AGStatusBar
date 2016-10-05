//
//  AGStatusBar.h
//
//  Created by Grig Uskov
//  Copyright © 2016 ALSEDI Group. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    CustomViewLocationLeftEdge,
    CustomViewLocationLeft,
    CustomViewLocationCenterLeft,
    CustomViewLocationCenterRight,
    CustomViewLocationRight,
    CustomViewLocationRightEdge
} AGStatusBarCustomViewLocation;


#define kAGSBSignalStrengthItem @"SignalStrength"
#define kAGSBServiceItem 		@"Service"          // Service Provider Name
#define kAGSBDataNetworkItem 	@"DataNetwork"      // WiFi icon, LTE, 3G, E...
#define kAGSBBatteryItem 		@"Battery"
#define kAGSBBatteryPercentItem @"BatteryPercent"
#define kAGSBBluetoothItem 		@"Bluetooth"
#define kAGSBIndicatorItem 		@"Indicator"        // Multiple: VPN, Alarm, Rotation Lock :(
#define kAGSBLocationItem 		@"Location"
#define kAGSBQuietModeItem 		@"QuietMode"
#define kAGSBTimeItem 			@"Time"             // Clock
#define BreadcrumbItem          @"Breadcrumb"       // [<] Back to AppName
#define kAGSBActivityItem		@"Activity"         // UIApplication.networkActivityIndicator and iTunes Synch Activity !!! not animating if tinted :(

#define AGSB_DO_NOT_AUTOTINT_CUSTOM_VIEW 7770554 // set this tag to custom view to preserve it's color regardless of _System Status Bar Color_ changes (custom tintColor is applied to all views)

@interface AGStatusBar : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) UIColor *tintColor;
- (void)setTintColor:(UIColor *)tintColor animated:(Boolean)animated;

- (void)setSystemView:(NSString *)viewKey hidden:(Boolean)hidden;

- (UIImageView *)addImage:(UIImage *)image at:(AGStatusBarCustomViewLocation)location;
- (UILabel *)addText:(NSString *)text at:(AGStatusBarCustomViewLocation)location;
- (void)addCustomView:(UIView *)view at:(AGStatusBarCustomViewLocation)location;

@property (nonatomic, readonly) NSArray <UIView *> *allCustomViews;
- (NSArray <UIView *> *)customViewsAtLocation:(AGStatusBarCustomViewLocation)location;

- (void)removeCustomView:(UIView *)view;
- (void)removeAllCustomViews;

- (void)forceLayout; // call it if you changed custom view width (derectly or indirectly)

@end
