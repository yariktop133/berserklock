#import "BerserkRunicRenderer.h"

@implementation BerserkRunicRenderer

#pragma mark - Canonical Brand of Sacrifice (Каноничное Клеймо Жертвы)

+ (UIBezierPath *)canonicalBrandOfSacrificeInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat ox = rect.origin.x;
    CGFloat oy = rect.origin.y;

    CGFloat sx = w / 100.0f;
    CGFloat sy = h / 140.0f;

    #define P(px, py) CGPointMake(ox + (px) * sx, oy + (py) * sy)

    // 1. Центральный вертикальный стержень (позвоночник Клейма)
    [path moveToPoint:P(50, 4)];
    [path addLineToPoint:P(50, 136)];

    // 2. Левый каноничный изогнутый рог
    [path moveToPoint:P(50, 14)];
    [path addCurveToPoint:P(16, 42)
            controlPoint1:P(30, 8)
            controlPoint2:P(14, 20)];
    [path addCurveToPoint:P(50, 58)
            controlPoint1:P(18, 56)
            controlPoint2:P(36, 58)];

    // 3. Правый каноничный изогнутый рог
    [path moveToPoint:P(50, 14)];
    [path addCurveToPoint:P(84, 42)
            controlPoint1:P(70, 8)
            controlPoint2:P(86, 20)];
    [path addCurveToPoint:P(50, 58)
            controlPoint1:P(82, 56)
            controlPoint2:P(64, 58)];

    // 4. Центральное диагональное перекрестие (X-образный рунический узел)
    [path moveToPoint:P(20, 38)];
    [path addLineToPoint:P(80, 82)];

    [path moveToPoint:P(80, 38)];
    [path addLineToPoint:P(20, 82)];

    // 5. Нижние расходящиеся зазубренные плавники
    [path moveToPoint:P(50, 82)];
    [path addLineToPoint:P(22, 126)];

    [path moveToPoint:P(50, 82)];
    [path addLineToPoint:P(78, 126)];

    #undef P
    return path;
}

#pragma mark - Runic Digits 0-9 (Рунические цифры в стиле Берсерка)

+ (UIBezierPath *)pathForDigit:(NSInteger)digit inRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat ox = rect.origin.x;
    CGFloat oy = rect.origin.y;

    CGFloat sx = w / 100.0f;
    CGFloat sy = h / 100.0f;

    #define P(px, py) CGPointMake(ox + (px) * sx, oy + (py) * sy)

    switch (digit) {
        case 0:
            // Рунический вытянутый гексагон с центральным разделительным стержнем
            [path moveToPoint:P(50, 4)];
            [path addLineToPoint:P(86, 28)];
            [path addLineToPoint:P(86, 72)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(14, 72)];
            [path addLineToPoint:P(14, 28)];
            [path closePath];
            // Внутренний стержень руны
            [path moveToPoint:P(50, 20)];
            [path addLineToPoint:P(50, 80)];
            break;

        case 1:
            // Острый вертикальный клинок с верхним наклонным шипом
            [path moveToPoint:P(54, 4)];
            [path addLineToPoint:P(54, 96)];
            // Верхний скошенный шип
            [path moveToPoint:P(54, 16)];
            [path addLineToPoint:P(22, 36)];
            // Нижняя опора
            [path moveToPoint:P(32, 96)];
            [path addLineToPoint:P(76, 96)];
            break;

        case 2:
            // Руническая двойка с резкими изломами
            [path moveToPoint:P(18, 26)];
            [path addLineToPoint:P(50, 4)];
            [path addLineToPoint:P(82, 26)];
            [path addLineToPoint:P(82, 46)];
            [path addLineToPoint:P(18, 86)];
            [path addLineToPoint:P(86, 86)];
            [path addLineToPoint:P(86, 96)];
            break;

        case 3:
            // Остроугольная тройка с центральным клиновидным выступом
            [path moveToPoint:P(18, 10)];
            [path addLineToPoint:P(82, 10)];
            [path addLineToPoint:P(46, 48)];
            [path addLineToPoint:P(84, 56)];
            [path addLineToPoint:P(84, 82)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(18, 84)];
            break;

        case 4:
            // Острый перекрестный рунический знак
            [path moveToPoint:P(76, 96)];
            [path addLineToPoint:P(76, 4)];
            [path moveToPoint:P(76, 68)];
            [path addLineToPoint:P(14, 68)];
            [path addLineToPoint:P(62, 4)];
            break;

        case 5:
            // Руническая пятерка с верхним лезвием и нижним изломом
            [path moveToPoint:P(84, 10)];
            [path addLineToPoint:P(20, 10)];
            [path addLineToPoint:P(20, 46)];
            [path addLineToPoint:P(80, 46)];
            [path addLineToPoint:P(84, 80)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(16, 84)];
            break;

        case 6:
            // Нижнее руническое кольцо со скошенным верхним пиком
            [path moveToPoint:P(74, 16)];
            [path addLineToPoint:P(32, 8)];
            [path addLineToPoint:P(16, 38)];
            [path addLineToPoint:P(16, 76)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(84, 76)];
            [path addLineToPoint:P(84, 52)];
            [path addLineToPoint:P(50, 46)];
            [path addLineToPoint:P(16, 60)];
            break;

        case 7:
            // Верхняя планка с диагональным руническим рассечением
            [path moveToPoint:P(16, 10)];
            [path addLineToPoint:P(86, 10)];
            [path addLineToPoint:P(38, 96)];
            // Поперечный штрих
            [path moveToPoint:P(34, 50)];
            [path addLineToPoint:P(68, 50)];
            break;

        case 8:
            // Сдвоенные рунические кристаллы
            [path moveToPoint:P(50, 6)];
            [path addLineToPoint:P(80, 25)];
            [path addLineToPoint:P(50, 48)];
            [path addLineToPoint:P(20, 25)];
            [path closePath];

            [path moveToPoint:P(50, 48)];
            [path addLineToPoint:P(86, 72)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(14, 72)];
            [path closePath];
            break;

        case 9:
            // Верхняя руническая петля с нисходящим клинком
            [path moveToPoint:P(50, 50)];
            [path addLineToPoint:P(16, 44)];
            [path addLineToPoint:P(16, 20)];
            [path addLineToPoint:P(50, 4)];
            [path addLineToPoint:P(84, 20)];
            [path addLineToPoint:P(84, 44)];
            [path closePath];

            [path moveToPoint:P(84, 20)];
            [path addLineToPoint:P(84, 78)];
            [path addLineToPoint:P(50, 96)];
            [path addLineToPoint:P(24, 88)];
            break;

        default:
            break;
    }

    #undef P
    return path;
}

#pragma mark - String to Runic Path

+ (UIBezierPath *)pathForTimeString:(NSString *)timeString inRect:(CGRect)rect {
    UIBezierPath *combinedPath = [UIBezierPath bezierPath];
    if (timeString.length == 0) return combinedPath;

    // Рассчитываем ширину каждого глифа
    // Формат обычно "HH:mm" (5 символов: 4 цифры + двоеточие)
    CGFloat totalW = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat y = rect.origin.y;

    // 4 цифры по ширине digitW, двоеточие colonW = digitW * 0.4
    // total = 4 * digitW + colonW + gaps = 4.4 * digitW + 4 * gap
    CGFloat digitW = totalW / 5.2f;
    CGFloat colonW = digitW * 0.40f;
    CGFloat gap = (totalW - (4.0f * digitW + colonW)) / 4.0f;

    CGFloat curX = rect.origin.x;

    for (NSUInteger i = 0; i < timeString.length; i++) {
        unichar c = [timeString characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            NSInteger digit = c - '0';
            CGRect dRect = CGRectMake(curX, y, digitW, h);
            UIBezierPath *dPath = [self pathForDigit:digit inRect:dRect];
            [combinedPath appendPath:dPath];
            curX += digitW + gap;
        } else if (c == ':') {
            // Двоеточие: две острые рунические ромбовидные точки
            CGFloat cx = curX + colonW * 0.5f;
            CGFloat dy1 = y + h * 0.35f;
            CGFloat dy2 = y + h * 0.65f;
            CGFloat dotR = 3.0f;

            // Верхняя ромбовидная точка
            [combinedPath moveToPoint:CGPointMake(cx, dy1 - dotR)];
            [combinedPath addLineToPoint:CGPointMake(cx + dotR, dy1)];
            [combinedPath addLineToPoint:CGPointMake(cx, dy1 + dotR)];
            [combinedPath addLineToPoint:CGPointMake(cx - dotR, dy1)];
            [combinedPath closePath];

            // Нижняя ромбовидная точка
            [combinedPath moveToPoint:CGPointMake(cx, dy2 - dotR)];
            [combinedPath addLineToPoint:CGPointMake(cx + dotR, dy2)];
            [combinedPath addLineToPoint:CGPointMake(cx, dy2 + dotR)];
            [combinedPath addLineToPoint:CGPointMake(cx - dotR, dy2)];
            [combinedPath closePath];

            curX += colonW + gap;
        }
    }

    return combinedPath;
}

@end
