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

/// Удар молнии из неба в точку тапа
- (void)triggerTapStrikeAt:(CGPoint)tapPoint;

/// Очистка всех активных разрядов
- (void)clearLightnings;

@end
