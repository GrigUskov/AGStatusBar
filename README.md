# AGStatusBar

Customization of system Status Bar for iOS, including (sure, while your app is running):
* globalTintColor - colorize all text and icons.
* Arbitarry hire system items, s.a. clock, battery, cellular network name and others.
* Add your own text, iamge or custom view items at any location.

Other features:
* Maintain Black/White custom views foreground color according to current UIStatusBarStyle.

Language: Objective-C.

<img src="http://alsedi.com/github/AGStatusBar_anim.gif">

Global tinting:
<pre>
    [AGStatusBar sharedInstance].globalTintColor = [UIColor redColor];
    [AGStatusBar sharedInstance].globalTintColor = [UIColor blueColor];
    [AGStatusBar sharedInstance].globalTintColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    [AGStatusBar sharedInstance].globalTintColor = [UIColor darkGrayColor];	
	...    
</pre>


---
<img src="http://alsedi.com/github/AGStatusBar_hidden.png">

Hidden system items:
<pre>
	[[AGStatusBar sharedInstance] setSystemView:kAGSBTimeItem hidden:YES];
	[[AGStatusBar sharedInstance] setSystemView:kAGSBServiceItem hidden:YES];
	[[AGStatusBar sharedInstance] setSystemView:kAGSBBatteryItem hidden:YES];	
</pre>


---
<img src="http://alsedi.com/github/AGStatusBar_custom.png">

Custom items:
<pre>
    [[AGStatusBar sharedInstance] setSystemView:kAGSBDataNetworkItem hidden:YES];
    [[AGStatusBar sharedInstance] setSystemView:kAGSBBatteryItem hidden:YES];
    [[AGStatusBar sharedInstance] setSystemView:kAGSBTimeItem hidden:YES];
    
    [[AGStatusBar sharedInstance] addText:@"Analogue" at:CustomViewLocationLeft];
    
    UIImage *imagePower = [UIImage imageNamed:@"power"];
    [[AGStatusBar sharedInstance] addImage:imagePower at:CustomViewLocationRightEdge];
    
    UIImage *imageAndroid = [UIImage imageNamed:@"android"];
    [[AGStatusBar sharedInstance] addImage:imageAndroid at:CustomViewLocationCenterRight];
</pre>

---
<img src="http://alsedi.com/github/AGStatusBar_custom.png">

Custom item without automatic tinting:
<pre>
	...    
    UIImage *imageAndroid = [UIImage imageNamed:@"android"];
    UIView *androidIco = [[AGStatusBar sharedInstance] addImage:imageAndroid at:CustomViewLocationCenterRight];
    androidIco.tag = AGSB_DO_NOT_AUTOTINT_CUSTOM_VIEW;
</pre>

