#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BerserkClockView.h"
#import "BerserkLightningOverlayView.h"

// Ключи для ассоциированных объектов
static const void *kBerserkClockKey = &kBerserkClockKey;
static const void *kBerserkLightningKey = &kBerserkLightningKey;
static const void *kBerserkPanGestureKey = &kBerserkPanGestureKey;

// Делегат для одновременного распознавания жестов (чтобы свайпы не конфликтовали с iOS)
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
    // Разрешаем одновременную работу с родными жестами разблокировки/шторок
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
@end

// Предварительное объявление классов для Clang
@interface CSCoverSheetViewController : UIViewController
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan;
@end

@interface SBFLockScreenDateView : UIView
@end

#pragma mark - Hook CSCoverSheetViewController (Экран блокировки iOS 15)

%hook CSCoverSheetViewController

- (void)viewDidLoad {
    %orig;

    UIView *parentView = self.view;

    // 1. Создаем и монтируем оверлей молний
    BerserkLightningOverlayView *overlay = [[BerserkLightningOverlayView alloc] initWithFrame:parentView.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parentView addSubview:overlay];
    objc_setAssociatedObject(self, kBerserkLightningKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 2. Распознаватель жеста свайпа по экрану
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;
    pan.delegate = [BerserkGestureDelegate sharedInstance];
    [parentView addGestureRecognizer:pan];
    objc_setAssociatedObject(self, kBerserkPanGestureKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 3. Создаем и монтируем часы в стиле Берсерка
    // Для iPhone SE 1 экран 320x568 pt, часы размещаются в верхней трети экрана
    CGFloat screenW = parentView.bounds.size.width > 0 ? parentView.bounds.size.width : 320.0f;
    CGRect clockFrame = CGRectMake(0, 42.0f, screenW, 220.0f);
    BerserkClockView *clockView = [[BerserkClockView alloc] initWithFrame:clockFrame];
    clockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [parentView addSubview:clockView];
    objc_setAssociatedObject(self, kBerserkClockKey, clockView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [clockView startClock];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    // Остановка анимаций и таймеров для сохранения аккумулятора
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [clockView stopClock];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        [overlay clearLightnings];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        clockView.frame = CGRectMake(0, 42.0f, self.view.bounds.size.width, 220.0f);
        [clockView updateLayoutForBounds:clockView.bounds];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        overlay.frame = self.view.bounds;
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

#pragma mark - Hook SBFLockScreenDateView (Скрытие стандартных часов iOS 15)

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
    // Предотвращаем включение видимости стоковых часов системой
    %orig(0.0f);
}

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end
