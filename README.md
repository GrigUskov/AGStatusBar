# AGStatusBar

Customization of system Status Bar for iOS, including (sure, while your app is running):
* tintColor - colorize all text and icons.
* Arbitarry hire system items, s.a. clock, battery, cellular network name and others.
* Add your own text, iamge or custom view items at any location.
* Maintain Black/White custom views foreground color according to current UIStatusBarStyle (if not tinted).

Language: Objective-C.

---

<b>DISCLAIMER</b> This component was created mostly for research / PoC purposes. USE IT AT YOUR OWN RISK

<b>WARNING</b> This ismplementation violates p.2.5.9 of Apple App Store Review Guidelines:

<i>2.5.9 Apps that alter the functions of standard switches, such as the Volume Up/Down and Ring/Silent switches, or other native user interface elements or behaviors will be rejected.</i>

---

Status bar tinting:

<img src="http://alsedi.com/github/AGStatusBar_anim.gif">

<pre>
[AGStatusBar sharedInstance].tintColor = [UIColor redColor];
[AGStatusBar sharedInstance].tintColor = [UIColor blueColor];
[AGStatusBar sharedInstance].tintColor = [UIColor darkGrayColor];	
...    
</pre>

---

Hidde system items:

<img src="http://alsedi.com/github/AGStatusBar_hidden.png">

<pre>
[[AGStatusBar sharedInstance] setSystemView:kAGSBTimeItem hidden:YES];
[[AGStatusBar sharedInstance] setSystemView:kAGSBServiceItem hidden:YES];
[[AGStatusBar sharedInstance] setSystemView:kAGSBBatteryItem hidden:YES];	
</pre>

---

Add custom items:

<img src="http://alsedi.com/github/AGStatusBar_custom.png">

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

Custom item without automatic tinting:

<img src="http://alsedi.com/github/AGStatusBar_custom_notint.png">

<pre>
...    
UIImage *imageAndroid = [UIImage imageNamed:@"android"];
UIView *androidIco = [[AGStatusBar sharedInstance] addImage:imageAndroid at:CustomViewLocationCenterRight];
androidIco.tag = AGSB_DO_NOT_AUTOTINT_CUSTOM_VIEW;
</pre>
