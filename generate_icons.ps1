Add-Type -AssemblyName System.Drawing

$themeDir = "layout\Library\Themes\BerserkTheme.theme\IconBundles"
$size = 180

# Список всех целевых бандлов: встроенные приложения iOS 15 + популярные
$iconConfigs = @{
    # 1. Встроенные iOS приложения
    "com.apple.mobilephone-large.png"     = "phone"
    "com.apple.MobileSMS-large.png"       = "sms"
    "com.apple.mobilesafari-large.png"     = "safari"
    "com.apple.camera-large.png"           = "camera"
    "com.apple.mobileslideshow-large.png"  = "photos"
    "com.apple.Music-large.png"            = "music"
    "com.apple.Preferences-large.png"      = "settings"
    "com.apple.mobiletimer-large.png"      = "clock"
    "com.apple.calculator-large.png"       = "calculator"
    "com.apple.DocumentsApp-large.png"     = "files"
    "com.apple.AppStore-large.png"         = "appstore"
    "com.apple.mobilemail-large.png"       = "mail"
    "com.apple.mobilenotes-large.png"      = "notes"
    "com.apple.reminders-large.png"        = "reminders"
    "com.apple.mobilecal-large.png"        = "calendar"
    "com.apple.weather-large.png"          = "weather"
    "com.apple.Maps-large.png"             = "maps"
    "com.apple.Health-large.png"           = "health"
    "com.apple.Passbook-large.png"         = "wallet"
    "com.apple.VoiceMemos-large.png"       = "voicememos"
    "com.apple.shortcuts-large.png"        = "shortcuts"
    "com.apple.findmy-large.png"           = "findmy"
    "com.apple.compass-large.png"          = "compass"
    "com.apple.podcasts-large.png"         = "podcasts"
    "com.apple.Tips-large.png"             = "tips"
    "com.apple.measure-large.png"          = "measure"
    "com.apple.Bridge-large.png"           = "watch"

    # 2. Happ VPN (все возможные bundle id)
    "com.happ.app-large.png"               = "happ"
    "com.happ.vpn-large.png"               = "happ"
    "com.happproxy.client-large.png"       = "happ"
    "com.happ.proxy-large.png"             = "happ"
    "com.happproxy-large.png"              = "happ"

    # 3. TikTok
    "com.zhiliaoapp.musically-large.png"   = "tiktok"
    "com.ss.iphone.ugc.Ame-large.png"      = "tiktok"

    # 4. Telegram
    "ph.telegra.Telegraph-large.png"       = "telegram"
    "org.telegram.messenger-large.png"     = "telegram"

    # 5. Geometry Dash
    "com.robtop.geometryjump-large.png"    = "gd"
    "com.robtop.geometrydash-large.png"    = "gd"
    "com.robtop.geometrydashlite-large.png"= "gd"

    # 6. YouTube, VK, Discord, WhatsApp, Sileo, Filza
    "com.google.ios.youtube-large.png"     = "youtube"
    "com.vk.vkclient-large.png"            = "vk"
    "com.hammerandchisel.discord-large.png"= "discord"
    "net.whatsapp.WhatsApp-large.png"      = "whatsapp"
    "org.coolstar.SileoStore-large.png"    = "sileo"
    "com.tigisoftware.Filza-large.png"     = "filza"
}

function Draw-BaseBackground([System.Drawing.Graphics]$g) {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)

    # 1. Тёмный металл Затмения
    $cTop = [System.Drawing.Color]::FromArgb(255, 14, 13, 16)
    $cBottom = [System.Drawing.Color]::FromArgb(255, 28, 10, 14)
    $gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cTop, $cBottom, 45.0)
    $g.FillRectangle($gradBrush, $rect)
    $gradBrush.Dispose()

    # 2. Кроваво-стальная рамка с неоновым свечением
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 240, 20, 30), 3.5)
    $g.DrawRectangle($borderPen, 2, 2, $size - 4, $size - 4)
    $borderPen.Dispose()

    $innerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 255, 60, 60), 1.2)
    $g.DrawRectangle($innerPen, 6, 6, $size - 12, $size - 12)
    $innerPen.Dispose()
}

function Draw-Brand([System.Drawing.Graphics]$g, [float]$ox, [float]$oy, [float]$scale) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 30, 35), (3.0 * $scale))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Центральный стержень
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 8 * $scale), ($ox + 50 * $scale), ($oy + 132 * $scale))

    # Верхние рога
    $g.DrawBezier($pen, ($ox + 50 * $scale), ($oy + 16 * $scale), ($ox + 18 * $scale), ($oy + 10 * $scale), ($ox + 16 * $scale), ($oy + 48 * $scale), ($ox + 50 * $scale), ($oy + 58 * $scale))
    $g.DrawBezier($pen, ($ox + 50 * $scale), ($oy + 16 * $scale), ($ox + 82 * $scale), ($oy + 10 * $scale), ($ox + 84 * $scale), ($oy + 48 * $scale), ($ox + 50 * $scale), ($oy + 58 * $scale))

    # Перекрестие
    $g.DrawLine($pen, ($ox + 20 * $scale), ($oy + 38 * $scale), ($ox + 80 * $scale), ($oy + 82 * $scale))
    $g.DrawLine($pen, ($ox + 80 * $scale), ($oy + 38 * $scale), ($ox + 20 * $scale), ($oy + 82 * $scale))

    # Нижние зубцы
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 82 * $scale), ($ox + 22 * $scale), ($oy + 124 * $scale))
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 82 * $scale), ($ox + 78 * $scale), ($oy + 124 * $scale))

    $pen.Dispose()
}

function Draw-Sword([System.Drawing.Graphics]$g) {
    $bladePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 210, 210, 220), 13.0)
    $bladePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($bladePen, 35, 145, 140, 40)
    $bladePen.Dispose()

    $corePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 25, 30), 4.0)
    $g.DrawLine($corePen, 40, 140, 135, 45)
    $corePen.Dispose()

    $guardPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 160, 15, 20), 8.0)
    $g.DrawLine($guardPen, 26, 138, 48, 160)
    $guardPen.Dispose()

    $hiltPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 90, 90, 95), 6.0)
    $g.DrawLine($hiltPen, 35, 145, 20, 160)
    $hiltPen.Dispose()
}

function Draw-Eclipse([System.Drawing.Graphics]$g) {
    $coronaPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 255, 25, 35), 6.0)
    $g.DrawEllipse($coronaPen, 40, 40, 100, 100)
    $coronaPen.Dispose()

    $coreBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 10, 14))
    $g.FillEllipse($coreBrush, 45, 45, 90, 90)
    $coreBrush.Dispose()

    Draw-Brand $g 58 52 0.45
}

foreach ($item in $iconConfigs.GetEnumerator()) {
    $fileName = $item.Key
    $type = $item.Value

    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    Draw-BaseBackground $g

    switch ($type) {
        "safari" { Draw-Eclipse $g }
        "music"  { Draw-Sword $g }
        "camera" {
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 30, 35), 4.5)
            $g.DrawEllipse($pen, 45, 45, 90, 90)
            $pen.Dispose()
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 50, 50))
            $g.FillEllipse($brush, 75, 60, 30, 60)
            $brush.Dispose()
        }
        "photos" {
            # Красный Бехелит
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 190, 20, 30))
            $g.FillEllipse($brush, 50, 40, 80, 100)
            $brush.Dispose()
            Draw-Brand $g 58 54 0.42
        }
        "settings" {
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 210, 30, 35), 5.0)
            $g.DrawEllipse($pen, 45, 45, 90, 90)
            $pen.Dispose()
            Draw-Brand $g 58 50 0.42
        }
        "happ" {
            # Рунический щит Затмения (VPN)
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 245, 30, 40), 4.0)
            $pts = @(
                [System.Drawing.PointF]::new(90, 35),
                [System.Drawing.PointF]::new(145, 60),
                [System.Drawing.PointF]::new(145, 110),
                [System.Drawing.PointF]::new(90, 150),
                [System.Drawing.PointF]::new(35, 110),
                [System.Drawing.PointF]::new(35, 60)
            )
            $g.DrawPolygon($pen, $pts)
            $pen.Dispose()
            Draw-Brand $g 63 56 0.35
        }
        "tiktok" {
            # Нота-клинок в багровом вихре
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 40, 50), 6.0)
            $g.DrawArc($pen, 40, 40, 100, 100, 30, 280)
            $g.DrawLine($pen, 105, 45, 105, 125)
            $pen.Dispose()
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 20, 30))
            $g.FillEllipse($brush, 65, 110, 45, 35)
            $brush.Dispose()
        }
        "telegram" {
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 245, 45, 55), 4.0)
            $pts = @(
                [System.Drawing.PointF]::new(40, 95),
                [System.Drawing.PointF]::new(145, 45),
                [System.Drawing.PointF]::new(90, 140),
                [System.Drawing.PointF]::new(75, 105)
            )
            $g.DrawPolygon($pen, $pts)
            $g.DrawLine($pen, 145, 45, 75, 105)
            $pen.Dispose()
        }
        "gd" {
            # Geometry Dash: Куб с горящими глазами Доспеха Берсерка
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 25, 30), 4.5)
            $g.DrawRectangle($pen, 45, 45, 90, 90)
            $pen.Dispose()
            # Глаза берсерка
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 200, 200))
            $g.FillPolygon($brush, @(
                [System.Drawing.PointF]::new(60, 75),
                [System.Drawing.PointF]::new(82, 70),
                [System.Drawing.PointF]::new(76, 85)
            ))
            $g.FillPolygon($brush, @(
                [System.Drawing.PointF]::new(120, 75),
                [System.Drawing.PointF]::new(98, 70),
                [System.Drawing.PointF]::new(104, 85)
            ))
            $brush.Dispose()
            # Оскал шлема
            $penSmile = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 30, 35), 3.0)
            $g.DrawLine($penSmile, 65, 110, 115, 110)
            $penSmile.Dispose()
        }
        "youtube" {
            # Стальной треугольник воспроизведения с Клеймом
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 30, 35), 4.0)
            $pts = @(
                [System.Drawing.PointF]::new(70, 50),
                [System.Drawing.PointF]::new(125, 90),
                [System.Drawing.PointF]::new(70, 130)
            )
            $g.DrawPolygon($pen, $pts)
            $pen.Dispose()
            Draw-Brand $g 58 54 0.38
        }
        "vk" {
            # Символ VK из вороненой стали
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 35, 45), 5.0)
            $g.DrawLine($pen, 50, 55, 75, 125)
            $g.DrawLine($pen, 75, 125, 95, 80)
            $g.DrawLine($pen, 95, 80, 115, 125)
            $g.DrawLine($pen, 115, 125, 135, 55)
            $pen.Dispose()
        }
        "discord" {
            # Маска шлема Доспеха Берсерка
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 30, 35), 4.5)
            $g.DrawArc($pen, 45, 50, 90, 70, 0, 360)
            $g.DrawLine($pen, 45, 85, 30, 105)
            $g.DrawLine($pen, 135, 85, 150, 105)
            $pen.Dispose()
            Draw-Brand $g 64 56 0.35
        }
        "whatsapp" {
            # Трубка с шипами
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 40, 45), 5.0)
            $g.DrawArc($pen, 45, 45, 90, 90, 45, 180)
            $pen.Dispose()
            Draw-Brand $g 60 50 0.40
        }
        "clock" {
            # Циферблат Затмения
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 25, 30), 4.0)
            $g.DrawEllipse($pen, 45, 45, 90, 90)
            $g.DrawLine($pen, 90, 52, 90, 90)
            $g.DrawLine($pen, 90, 90, 120, 90)
            $pen.Dispose()
        }
        "calculator" {
            # Рунические математические знаки
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 35, 40), 4.0)
            $g.DrawLine($pen, 65, 55, 65, 85)
            $g.DrawLine($pen, 50, 70, 80, 70) # +
            $g.DrawLine($pen, 100, 70, 130, 70) # -
            $g.DrawLine($pen, 55, 110, 75, 130) # x
            $g.DrawLine($pen, 75, 110, 55, 130)
            $g.DrawLine($pen, 100, 115, 130, 115) # =
            $g.DrawLine($pen, 100, 125, 130, 125)
            $pen.Dispose()
        }
        "files" {
            # Гримуар Затмения
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 220, 30, 35), 4.0)
            $g.DrawRectangle($pen, 50, 45, 80, 95)
            $g.DrawLine($pen, 62, 45, 62, 140)
            $pen.Dispose()
            Draw-Brand $g 66 60 0.35
        }
        "health" {
            # Бьющееся проклятое сердце
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 30, 35), 4.5)
            $g.DrawArc($pen, 50, 50, 45, 45, 140, 200)
            $g.DrawArc($pen, 85, 50, 45, 45, 200, 200)
            $g.DrawLine($pen, 54, 88, 90, 135)
            $g.DrawLine($pen, 126, 88, 90, 135)
            $pen.Dispose()
        }
        "mail" {
            # Кровавый вестник / письмо с Клеймом
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 30, 35), 4.0)
            $g.DrawRectangle($pen, 40, 55, 100, 70)
            $g.DrawLine($pen, 40, 55, 90, 95)
            $g.DrawLine($pen, 140, 55, 90, 95)
            $pen.Dispose()
        }
        "weather" {
            # Буря Затмения
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 35, 40), 4.0)
            $g.DrawArc($pen, 45, 65, 50, 40, 160, 200)
            $g.DrawArc($pen, 75, 50, 60, 50, 180, 200)
            $g.DrawLine($pen, 50, 105, 130, 105)
            # Молния
            $g.DrawLine($pen, 85, 110, 75, 130)
            $g.DrawLine($pen, 75, 130, 95, 130)
            $g.DrawLine($pen, 95, 130, 80, 150)
            $pen.Dispose()
        }
        "maps" {
            # Карта Мидланда
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 220, 30, 35), 4.0)
            $g.DrawLine($pen, 45, 50, 75, 65)
            $g.DrawLine($pen, 75, 65, 105, 50)
            $g.DrawLine($pen, 105, 50, 135, 65)
            $g.DrawLine($pen, 135, 65, 135, 135)
            $g.DrawLine($pen, 135, 135, 105, 120)
            $g.DrawLine($pen, 105, 120, 75, 135)
            $g.DrawLine($pen, 75, 135, 45, 120)
            $g.DrawLine($pen, 45, 120, 45, 50)
            $pen.Dispose()
        }
        "compass" {
            Draw-Eclipse $g
        }
        "shortcuts" {
            # Руна молнии
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 30, 35), 5.0)
            $g.DrawLine($pen, 105, 40, 65, 95)
            $g.DrawLine($pen, 65, 95, 105, 95)
            $g.DrawLine($pen, 105, 95, 75, 145)
            $pen.Dispose()
        }
        default {
            # Каноничное Клеймо Жертвы
            Draw-Brand $g 52 35 0.75
        }
    }

    $outPath = Join-Path $themeDir $fileName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Write-Host "Generated $($iconConfigs.Count) Berserk icons successfully in $themeDir"
