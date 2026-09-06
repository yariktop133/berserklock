#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BerserkClockView.h"
#import "BerserkLightningOverlayView.h"

// Ключи для ассоциированных объектов
static const void *kBerserkClockKey = &kBerserkClockKey;
static const void *kBerserkLightningKey = &kBerserkLightningKey;
static const void *kBerserkPanGestureKey = &kBerserkPanGestureKey;
static const void *kBerserkTapGestureKey = &kBerserkTapGestureKey;

static const void *kBerserkHomeLightningKey = &kBerserkHomeLightningKey;
static const void *kBerserkHomePanKey = &kBerserkHomePanKey;
static const void *kBerserkHomeTapKey = &kBerserkHomeTapKey;

// Делегат для одновременного распознавания жестов
@interface BerserkGestureDelegate : NSObject <UIGestureRecognizerDelegate>
+ (instancetype)sharedInstance;
@end

@implementation BerserkGestureDelegate
+ (instancetype)sharedInstance {
    static BerserkGestureDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BerserkGestureDelegate alloc] init];
    });
    return instance;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
@end

// Предварительное объявление системных классов для Clang
@interface CSCoverSheetViewController : UIViewController
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan;
- (void)berserk_handleTap:(UITapGestureRecognizer *)tap;
@end

@interface SBHomeScreenViewController : UIViewController
- (void)berserk_handleHomePan:(UIPanGestureRecognizer *)pan;
- (void)berserk_handleHomeTap:(UITapGestureRecognizer *)tap;
@end

@interface SBFLockScreenDateView : UIView
@end

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBIcon : NSObject
- (id)applicationBundleID;
- (id)leafIdentifier;
- (id)nodeIdentifier;
- (id)application;
- (UIImage *)generateIconImageWithInfo:(struct SBIconImageInfo)info;
- (UIImage *)iconImageWithInfo:(struct SBIconImageInfo)info;
- (UIImage *)generateIconImage:(int)type;
- (UIImage *)getIconImage:(int)type;
@end

@interface SBIconImageView : UIView
- (SBIcon *)icon;
- (void)setIcon:(SBIcon *)icon location:(id)location animated:(BOOL)animated;
- (void)setIconImage:(UIImage *)image;
- (void)setContentsImage:(UIImage *)image;
- (void)updateImageAnimated:(BOOL)animated;
@end

@interface SBMutableIconLabelImageParameters : NSObject
- (void)setTextColor:(UIColor *)color;
- (void)setFont:(UIFont *)font;
@end

@interface SBIconView : UIView
- (SBIcon *)icon;
@end

@interface SBHWidgetContainerView : UIView
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end

@interface CCUIContinuousSliderView : UIControl
@end

@interface CCUILabeledRoundButton : UIView
@end

@interface UITextInputTraits : NSObject
- (UIKeyboardAppearance)keyboardAppearance;
@end

@interface UIKBRenderConfig : NSObject
- (BOOL)lightKeyboard;
@end

@interface UIKeyboardDockView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface UIKBKeyView : UIView
@end

@interface TPRevealingRingView : UIView
@end

@interface TPNumberPadButton : UIControl
+ (id)imageForCharacter:(unsigned)character;
+ (id)imageForCharacter:(unsigned)character highlighted:(BOOL)highlighted;
+ (id)imageForCharacter:(unsigned)character highlighted:(BOOL)highlighted whiteVersion:(BOOL)whiteVersion;
@end

@interface SBUIPasscodeLockViewBase : UIView
@end

@interface SBUILabel : UILabel
@end

@interface _SBUIPasscodeField : UIView
@end

#pragma mark - Helper для извлечения Bundle ID и подмены иконок

static NSString *berserk_extractBundleID(SBIcon *icon) {
    if (!icon) return nil;

    NSString *bundleID = nil;

    if ([icon respondsToSelector:@selector(applicationBundleID)]) {
        bundleID = [icon applicationBundleID];
    }

    if ((!bundleID || bundleID.length == 0) && [icon respondsToSelector:@selector(application)]) {
        id app = [icon application];
        if (app && [app respondsToSelector:@selector(bundleIdentifier)]) {
            bundleID = [app performSelector:@selector(bundleIdentifier)];
        }
    }

    if ((!bundleID || bundleID.length == 0) && [icon respondsToSelector:@selector(leafIdentifier)]) {
        bundleID = [icon leafIdentifier];
    }

    if ((!bundleID || bundleID.length == 0) && [icon respondsToSelector:@selector(nodeIdentifier)]) {
        bundleID = [icon nodeIdentifier];
    }

    return bundleID;
}

static UIImage *berserk_iconForBundleID(NSString *bundleID) {
    if (!bundleID || bundleID.length == 0) return nil;

    static NSMutableDictionary *iconCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconCache = [[NSMutableDictionary alloc] init];
    });

    @synchronized(iconCache) {
        UIImage *cached = iconCache[bundleID];
        if (cached) return cached;
    }

    NSArray *searchPaths = @[
        @"/var/jb/Library/Application Support/BerserkLock/Icons",
        @"/Library/Application Support/BerserkLock/Icons",
        @"/var/jb/Library/Themes/BerserkTheme.theme/IconBundles",
        @"/Library/Themes/BerserkTheme.theme/IconBundles"
    ];

    NSFileManager *fm = [NSFileManager defaultManager];

    for (NSString *baseDir in searchPaths) {
        NSString *path1 = [NSString stringWithFormat:@"%@/%@.png", baseDir, bundleID];
        if ([fm fileExistsAtPath:path1]) {
            UIImage *img = [UIImage imageWithContentsOfFile:path1];
            if (img) {
                @synchronized(iconCache) { iconCache[bundleID] = img; }
                return img;
            }
        }

        NSString *path2 = [NSString stringWithFormat:@"%@/%@-large.png", baseDir, bundleID];
        if ([fm fileExistsAtPath:path2]) {
            UIImage *img = [UIImage imageWithContentsOfFile:path2];
            if (img) {
                @synchronized(iconCache) { iconCache[bundleID] = img; }
                return img;
            }
        }
    }

    return nil;
}

static UIImage *berserk_renderPasscodeDigitImage(unsigned character, BOOL highlighted) {
    unichar c = (unichar)character;
    int digit = -1;
    if (c >= '0' && c <= '9') {
        digit = c - '0';
    } else if (c <= 9) {
        digit = (int)c;
    }

    if (digit < 0 || digit > 9) return nil;

    static NSMutableDictionary *digitCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        digitCache = [[NSMutableDictionary alloc] init];
    });

    NSString *cacheKey = [NSString stringWithFormat:@"%d_%d", digit, highlighted ? 1 : 0];
    @synchronized(digitCache) {
        UIImage *cached = digitCache[cacheKey];
        if (cached) return cached;
    }

    CGSize size = CGSizeMake(75.0f, 75.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    UIColor *textColor = highlighted ? [UIColor colorWithRed:1.0 green:0.55 blue:0.55 alpha:1.0] : [UIColor colorWithRed:0.98 green:0.18 blue:0.22 alpha:1.0];
    UIColor *glowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85];

    NSString *digitStr = [NSString stringWithFormat:@"%d", digit];
    // Чистая округлая системная типографика пароля iOS в неоновом кроваво-красном стиле
    UIFont *font = [UIFont systemFontOfSize:38.0f weight:UIFontWeightMedium];

    CGContextSetShadowWithColor(ctx, CGSizeZero, 6.0f, glowColor.CGColor);

    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: textColor
    };
    CGSize strSize = [digitStr sizeWithAttributes:attrs];
    CGFloat yOffset = (digit == 0) ? (size.height - strSize.height) * 0.5f : (size.height - strSize.height) * 0.30f;
    CGRect textRect = CGRectMake((size.width - strSize.width) * 0.5f, yOffset, strSize.width, strSize.height);
    [digitStr drawInRect:textRect withAttributes:attrs];

    // Буквы под цифрами (A B C, D E F...)
    NSArray *lettersArray = @[@"", @"", @"A B C", @"D E F", @"G H I", @"J K L", @"M N O", @"P Q R S", @"T U V", @"W X Y Z"];
    if (digit >= 2 && digit <= 9) {
        NSString *letters = lettersArray[digit];
        UIFont *subFont = [UIFont systemFontOfSize:9.5f weight:UIFontWeightMedium];
        NSDictionary *subAttrs = @{
            NSFontAttributeName: subFont,
            NSForegroundColorAttributeName: [UIColor colorWithRed:0.85 green:0.32 blue:0.35 alpha:0.85]
        };
        CGSize subSize = [letters sizeWithAttributes:subAttrs];
        CGRect subRect = CGRectMake((size.width - subSize.width) * 0.5f, yOffset + strSize.height - 2.0f, subSize.width, subSize.height);
        [letters drawInRect:subRect withAttributes:subAttrs];
    }

    UIImage *rendered = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (rendered) {
        @synchronized(digitCache) {
            digitCache[cacheKey] = rendered;
        }
    }
    return rendered;
}

#pragma mark - Hook SBIcon & SBIconImageView (Двойная гарантия подмены иконок + 60 FPS)

%hook SBIcon

- (UIImage *)generateIconImageWithInfo:(struct SBIconImageInfo)info {
    NSString *bundleID = berserk_extractBundleID(self);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        return customImage;
    }
    return %orig;
}

- (UIImage *)iconImageWithInfo:(struct SBIconImageInfo)info {
    NSString *bundleID = berserk_extractBundleID(self);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        return customImage;
    }
    return %orig;
}

- (UIImage *)generateIconImage:(int)type {
    NSString *bundleID = berserk_extractBundleID(self);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        return customImage;
    }
    return %orig;
}

- (UIImage *)getIconImage:(int)type {
    NSString *bundleID = berserk_extractBundleID(self);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        return customImage;
    }
    return %orig;
}

%end

%hook SBIconImageView

- (void)setIcon:(SBIcon *)icon location:(id)location animated:(BOOL)animated {
    %orig;
    NSString *bundleID = berserk_extractBundleID(icon);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        self.layer.contents = (id)customImage.CGImage;
    }
}

- (void)setIconImage:(UIImage *)image {
    SBIcon *icon = nil;
    if ([self respondsToSelector:@selector(icon)]) {
        icon = [self icon];
    }
    NSString *bundleID = berserk_extractBundleID(icon);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        %orig(customImage);
        self.layer.contents = (id)customImage.CGImage;
        return;
    }
    %orig(image);
}

- (void)setContentsImage:(UIImage *)image {
    SBIcon *icon = nil;
    if ([self respondsToSelector:@selector(icon)]) {
        icon = [self icon];
    }
    NSString *bundleID = berserk_extractBundleID(icon);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        %orig(customImage);
        self.layer.contents = (id)customImage.CGImage;
        return;
    }
    %orig(image);
}

- (void)updateImageAnimated:(BOOL)animated {
    %orig;
    SBIcon *icon = nil;
    if ([self respondsToSelector:@selector(icon)]) {
        icon = [self icon];
    }
    NSString *bundleID = berserk_extractBundleID(icon);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        self.layer.contents = (id)customImage.CGImage;
    }
}

- (void)layoutSubviews {
    %orig;
    SBIcon *icon = nil;
    if ([self respondsToSelector:@selector(icon)]) {
        icon = [self icon];
    }
    NSString *bundleID = berserk_extractBundleID(icon);
    UIImage *customImage = berserk_iconForBundleID(bundleID);
    if (customImage) {
        self.layer.contents = (id)customImage.CGImage;
    }

    // Для любых сторонних приложений без кастомной иконки применяем тонирование в стиле темной обсидиановой стали
    CALayer *unthemedOverlay = nil;
    for (CALayer *sub in self.layer.sublayers) {
        if ([sub.name isEqualToString:@"BerserkUnthemedOverlay"]) {
            unthemedOverlay = sub;
            break;
        }
    }
    if (!customImage) {
        if (!unthemedOverlay) {
            unthemedOverlay = [CALayer layer];
            unthemedOverlay.name = @"BerserkUnthemedOverlay";
            unthemedOverlay.backgroundColor = [UIColor colorWithRed:0.14 green:0.04 blue:0.06 alpha:0.60].CGColor;
            unthemedOverlay.cornerRadius = 14.0f;
            unthemedOverlay.masksToBounds = YES;
            [self.layer addSublayer:unthemedOverlay];
        }
        unthemedOverlay.frame = self.bounds;
        unthemedOverlay.hidden = NO;
    } else {
        if (unthemedOverlay) {
            unthemedOverlay.hidden = YES;
        }
    }

    // 3D объемный выпуклый купол (Convex Dome Specular Highlight & Deep Ambient Shadow)
    CAGradientLayer *bevel = nil;
    for (CALayer *sub in self.layer.sublayers) {
        if ([sub.name isEqualToString:@"BerserkIconBevel"]) {
            bevel = (CAGradientLayer *)sub;
            break;
        }
    }
    if (!bevel) {
        bevel = [CAGradientLayer layer];
        bevel.name = @"BerserkIconBevel";
        bevel.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.38].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.12].CGColor,
            (id)[UIColor clearColor].CGColor,
            (id)[UIColor colorWithRed:0.60 green:0.0 blue:0.0 alpha:0.30].CGColor,
            (id)[UIColor colorWithWhite:0.0 alpha:0.55].CGColor
        ];
        bevel.locations = @[@0.0, @0.18, @0.48, @0.80, @1.0];
        bevel.cornerRadius = 14.0f;
        bevel.masksToBounds = YES;
        [self.layer addSublayer:bevel];
    }
    bevel.frame = self.bounds;
    [self.layer addSublayer:bevel];

    // Кованый кровавый кант
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.88 green:0.10 blue:0.15 alpha:0.85].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 14.0f;
}

%end

#pragma mark - Hook SBMutableIconLabelImageParameters (Кроваво-рунические подписи иконок)

%hook SBMutableIconLabelImageParameters

- (void)setTextColor:(UIColor *)color {
    %orig([UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:0.95]);
}

- (void)setFont:(UIFont *)font {
    if (font) {
        UIFont *bf = [UIFont fontWithName:@"Copperplate-Bold" size:font.pointSize];
        if (bf) {
            %orig(bf);
            return;
        }
    }
    %orig(font);
}

%end

#pragma mark - Hook SBHWidgetContainerView (Стилизация виджетов на iOS 15)

%hook SBHWidgetContainerView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 20.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.6f;
    self.layer.borderColor = [UIColor colorWithRed:0.90 green:0.10 blue:0.15 alpha:0.85].CGColor;
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.06 blue:0.08 alpha:0.90];
}

%end

#pragma mark - Hook CSCoverSheetViewController (Экран блокировки)

%hook CSCoverSheetViewController

- (void)viewDidLoad {
    %orig;

    UIView *parentView = self.view;

    BerserkLightningOverlayView *overlay = [[BerserkLightningOverlayView alloc] initWithFrame:parentView.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parentView addSubview:overlay];
    objc_setAssociatedObject(self, kBerserkLightningKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;
    pan.delegate = [BerserkGestureDelegate sharedInstance];
    [parentView addGestureRecognizer:pan];
    objc_setAssociatedObject(self, kBerserkPanGestureKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handleTap:)];
    tap.cancelsTouchesInView = NO;
    tap.delaysTouchesBegan = NO;
    tap.delegate = [BerserkGestureDelegate sharedInstance];
    [parentView addGestureRecognizer:tap];
    objc_setAssociatedObject(self, kBerserkTapGestureKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    CGFloat screenW = parentView.bounds.size.width > 0 ? parentView.bounds.size.width : 320.0f;
    CGRect clockFrame = CGRectMake(0, 36.0f, screenW, 230.0f);
    BerserkClockView *clockView = [[BerserkClockView alloc] initWithFrame:clockFrame];
    clockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [parentView addSubview:clockView];
    objc_setAssociatedObject(self, kBerserkClockKey, clockView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [self.view bringSubviewToFront:clockView];
        [clockView startClock];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        [self.view bringSubviewToFront:overlay];
        [overlay startAmbientLightning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [clockView stopClock];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        [overlay stopAmbientLightning];
        [overlay clearLightnings];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        clockView.frame = CGRectMake(0, 36.0f, self.view.bounds.size.width, 230.0f);
        [clockView updateLayoutForBounds:clockView.bounds];
        [self.view bringSubviewToFront:clockView];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        overlay.frame = self.view.bounds;
        [self.view bringSubviewToFront:overlay];
    }
}

%new
- (void)berserk_handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
        if (overlay) {
            CGPoint point = [tap locationInView:self.view];
            [overlay triggerTapStrikeAt:point];
        }
    }
}

%new
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan {
    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (!overlay) return;

    CGPoint point = [pan locationInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [overlay handleTouchAtPoint:point isStart:YES isEnd:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [overlay handleTouchAtPoint:point isStart:NO isEnd:NO];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [overlay handleTouchAtPoint:point isStart:NO isEnd:YES];
            break;
        default:
            break;
    }
}

%end

#pragma mark - Hook SBHomeScreenViewController (Рабочий стол SpringBoard)

%hook SBHomeScreenViewController

- (void)viewDidLoad {
    %orig;

    UIView *homeView = self.view;

    BerserkLightningOverlayView *homeOverlay = [[BerserkLightningOverlayView alloc] initWithFrame:homeView.bounds];
    homeOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [homeView addSubview:homeOverlay];
    objc_setAssociatedObject(self, kBerserkHomeLightningKey, homeOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIPanGestureRecognizer *homePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handleHomePan:)];
    homePan.cancelsTouchesInView = NO;
    homePan.delaysTouchesBegan = NO;
    homePan.delaysTouchesEnded = NO;
    homePan.delegate = [BerserkGestureDelegate sharedInstance];
    [homeView addGestureRecognizer:homePan];
    objc_setAssociatedObject(self, kBerserkHomePanKey, homePan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handleHomeTap:)];
    homeTap.cancelsTouchesInView = NO;
    homeTap.delaysTouchesBegan = NO;
    homeTap.delegate = [BerserkGestureDelegate sharedInstance];
    [homeView addGestureRecognizer:homeTap];
    objc_setAssociatedObject(self, kBerserkHomeTapKey, homeTap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [self.view bringSubviewToFront:homeOverlay];
        [homeOverlay startAmbientLightning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [homeOverlay stopAmbientLightning];
        [homeOverlay clearLightnings];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        homeOverlay.frame = self.view.bounds;
        [self.view bringSubviewToFront:homeOverlay];
    }
}

%new
- (void)berserk_handleHomeTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
        if (homeOverlay) {
            CGPoint point = [tap locationInView:self.view];
            [homeOverlay triggerTapStrikeAt:point];
        }
    }
}

%new
- (void)berserk_handleHomePan:(UIPanGestureRecognizer *)pan {
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (!homeOverlay) return;

    CGPoint point = [pan locationInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [homeOverlay handleTouchAtPoint:point isStart:YES isEnd:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [homeOverlay handleTouchAtPoint:point isStart:NO isEnd:NO];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [homeOverlay handleTouchAtPoint:point isStart:NO isEnd:YES];
            break;
        default:
            break;
    }
}

%end

#pragma mark - Hook Экран ввода пароля (Passcode: кольца, цифры, точки, статус)

%hook TPRevealingRingView

- (void)layoutSubviews {
    %orig;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorWithRed:0.92 green:0.10 blue:0.15 alpha:0.75].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
    self.layer.shadowRadius = 6.0f;
    self.layer.shadowOpacity = 0.60f;
    self.layer.shadowOffset = CGSizeZero;
}

%end

%hook TPNumberPadButton

+ (id)imageForCharacter:(unsigned)character {
    UIImage *customImg = berserk_renderPasscodeDigitImage(character, NO);
    if (customImg) return customImg;
    return %orig;
}

+ (id)imageForCharacter:(unsigned)character highlighted:(BOOL)highlighted {
    UIImage *customImg = berserk_renderPasscodeDigitImage(character, highlighted);
    if (customImg) return customImg;
    return %orig;
}

+ (id)imageForCharacter:(unsigned)character highlighted:(BOOL)highlighted whiteVersion:(BOOL)whiteVersion {
    UIImage *customImg = berserk_renderPasscodeDigitImage(character, highlighted);
    if (customImg) return customImg;
    return %orig;
}

- (void)layoutSubviews {
    %orig;
    // Убираем искусственную прямоугольную рамку, сохраняя идеальную окружность TPRevealingRingView
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.shadowOpacity = 0.0f;

    UILabel *numberLabel = nil;
    @try {
        numberLabel = [self valueForKey:@"_numberLabel"];
    } @catch (NSException *e) {}

    if (numberLabel && [numberLabel isKindOfClass:[UILabel class]]) {
        numberLabel.textColor = [UIColor colorWithRed:0.98 green:0.18 blue:0.22 alpha:1.0];
        numberLabel.font = [UIFont systemFontOfSize:numberLabel.font.pointSize weight:UIFontWeightMedium];
        numberLabel.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
        numberLabel.layer.shadowRadius = 6.0f;
        numberLabel.layer.shadowOpacity = 0.75f;
        numberLabel.layer.shadowOffset = CGSizeZero;
    }

    UILabel *letterLabel = nil;
    @try {
        letterLabel = [self valueForKey:@"_letterLabel"];
    } @catch (NSException *e) {}

    if (letterLabel && [letterLabel isKindOfClass:[UILabel class]]) {
        letterLabel.textColor = [UIColor colorWithRed:0.85 green:0.32 blue:0.35 alpha:0.85];
        letterLabel.font = [UIFont systemFontOfSize:letterLabel.font.pointSize weight:UIFontWeightMedium];
    }
}

%end

%hook SBUIPasscodeLockViewBase

- (void)layoutSubviews {
    %orig;

    UILabel *statusTitle = nil;
    @try {
        statusTitle = [self valueForKey:@"_statusTitleView"];
    } @catch (NSException *e) {}

    if (statusTitle && [statusTitle isKindOfClass:[UILabel class]]) {
        statusTitle.textColor = [UIColor colorWithRed:0.95 green:0.20 blue:0.20 alpha:1.0];
        statusTitle.font = [UIFont systemFontOfSize:statusTitle.font.pointSize weight:UIFontWeightMedium];
        statusTitle.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9].CGColor;
        statusTitle.layer.shadowRadius = 6.0f;
        statusTitle.layer.shadowOpacity = 0.8f;
        statusTitle.layer.shadowOffset = CGSizeZero;
    }
}

%end

%hook _SBUIPasscodeField

- (void)layoutSubviews {
    %orig;
    // Окрашивание индикаторов пароля (точек ввода) в кроваво-красный цвет
    self.tintColor = [UIColor colorWithRed:0.98 green:0.12 blue:0.16 alpha:1.0];
}

%end

%hook SBUILabel

- (void)layoutSubviews {
    %orig;
    if (self.text.length > 0) {
        self.textColor = [UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:1.0];
    }
}

%end

#pragma mark - Hook Пункт управления (Control Center: чистая нативная геометрия без рамок-квадратов)

%hook CCUIRoundButton

- (void)layoutSubviews {
    %orig;
    self.layer.borderWidth = 0.0f;

    if (self.selected) {
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
        self.layer.shadowRadius = 8.0f;
        self.layer.shadowOpacity = 0.85f;
        self.layer.shadowOffset = CGSizeZero;
        [self setBackgroundColor:[UIColor colorWithRed:0.92 green:0.08 blue:0.12 alpha:1.0]];
    } else {
        self.layer.shadowOpacity = 0.0f;
        [self setBackgroundColor:[UIColor colorWithRed:0.12 green:0.08 blue:0.10 alpha:0.85]];
    }

    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIImageView class]]) {
            sub.tintColor = self.selected ? [UIColor whiteColor] : [UIColor colorWithRed:0.95 green:0.25 blue:0.28 alpha:1.0];
        }
    }
}

%end

%hook CCUILabeledRoundButton

- (void)layoutSubviews {
    %orig;
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            ((UILabel *)sub).textColor = [UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:1.0];
        }
    }
}

%end

%hook CCUIContinuousSliderView

- (void)layoutSubviews {
    %orig;
    self.layer.borderWidth = 0.0f;
    self.layer.shadowOpacity = 0.0f;

    UIView *valueIndicator = nil;
    @try {
        valueIndicator = [self valueForKey:@"_valueIndicator"];
    } @catch (NSException *e) {}

    if (valueIndicator) {
        valueIndicator.backgroundColor = [UIColor colorWithRed:0.95 green:0.12 blue:0.16 alpha:0.95];
    }
}

%end

#pragma mark - Hook Системная клавиатура (Глобально)

%hook UITextInputTraits

- (UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDark;
}

%end

%hook UITextField

- (UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDark;
}

%end

%hook UITextView

- (UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDark;
}

%end

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
    return NO;
}

- (void)setLightKeyboard:(BOOL)light {
    %orig(NO);
}

+ (id)defaultConfig {
    id config = %orig;
    if ([config respondsToSelector:@selector(setLightKeyboard:)]) {
        [config performSelector:@selector(setLightKeyboard:) withObject:@NO];
    }
    return config;
}

%end

%hook UIKeyboardDockView

- (void)layoutSubviews {
    %orig;
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.06 blue:0.08 alpha:0.95];
}

%end

%hook UIKeyboardLayoutStar

- (void)layoutSubviews {
    %orig;
    self.backgroundColor = [UIColor colorWithRed:0.09 green:0.07 blue:0.09 alpha:0.98];
}

%end

%hook UIKBKeyView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 6.0f;
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.98 green:0.12 blue:0.18 alpha:0.95].CGColor;
    self.layer.backgroundColor = [UIColor colorWithRed:0.18 green:0.08 blue:0.10 alpha:0.92].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
    self.layer.shadowRadius = 4.0f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeZero;
}

%end

#pragma mark - Hook SBFLockScreenDateView (Скрытие стоковых часов)

%hook SBFLockScreenDateView

- (void)didMoveToWindow {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0f;
}

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0f;
}

- (void)setAlpha:(CGFloat)alpha {
    %orig(0.0f);
}

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end
