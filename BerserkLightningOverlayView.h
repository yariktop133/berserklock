#import <UIKit/UIKit.h>

@interface BerserkLightningOverlayView : UIView

/// Инициализация полноэкранного оверлея молний
- (instancetype)initWithFrame:(CGRect)frame;

/// Запуск фоновых спонтанных раскатов молний (каждые ~3 секунды)
- (void)startAmbientLightning;

/// Остановка фоновых молний (для сохранения аккумулятора при блокировке)
- (void)stopAmbientLightning;

/// Обработка свайпа/тача в точке (вызывается из распознавателя жестов)
- (void)handleTouchAtPoint:(CGPoint)point isStart:(BOOL)isStart isEnd:(BOOL)isEnd;

/// Очистка всех активных разрядов
- (void)clearLightnings;

@end
