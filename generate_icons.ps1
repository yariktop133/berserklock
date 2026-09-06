Add-Type -AssemblyName System.Drawing

$themeDir = "layout\Library\Themes\BerserkTheme.theme\IconBundles"
$size = 180

$icons = @(
    "com.apple.mobilephone-large.png",
    "com.apple.MobileSMS-large.png",
    "com.apple.mobilesafari-large.png",
    "com.apple.camera-large.png",
    "com.apple.mobileslideshow-large.png",
    "com.apple.Music-large.png",
    "com.apple.Preferences-large.png",
    "com.apple.AppStore-large.png",
    "com.apple.mobiletimer-large.png",
    "com.apple.calculator-large.png",
    "com.apple.DocumentsApp-large.png",
    "org.coolstar.SileoStore-large.png",
    "ph.telegra.Telegraph-large.png",
    "org.telegram.messenger-large.png"
)

function Draw-BaseIcon([System.Drawing.Graphics]$g, [string]$title) {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    
    # 1. Dark forged steel gradient
    $cTop = [System.Drawing.Color]::FromArgb(255, 18, 16, 20)
    $cBottom = [System.Drawing.Color]::FromArgb(255, 36, 12, 16)
    $gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cTop, $cBottom, 45.0)
    $g.FillRectangle($gradBrush, $rect)
    $gradBrush.Dispose()

    # 2. Subtle iron damascus scratch texture
    $scratchPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 220, 40, 50), 1.0)
    for ($i = 0; $i -lt 12; $i++) {
        $x1 = (Get-Random -Minimum 10 -Maximum 170)
        $y1 = (Get-Random -Minimum 10 -Maximum 170)
        $x2 = $x1 + (Get-Random -Minimum -30 -Maximum 30)
        $y2 = $y1 + (Get-Random -Minimum -30 -Maximum 30)
        $g.DrawLine($scratchPen, $x1, $y1, $x2, $y2)
    }
    $scratchPen.Dispose()

    # 3. Deep crimson inner glow border
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 180, 20, 28), 3.5)
    $g.DrawRectangle($borderPen, 2, 2, $size - 4, $size - 4)
    $borderPen.Dispose()

    $innerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 240, 60, 60), 1.2)
    $g.DrawRectangle($innerPen, 6, 6, $size - 12, $size - 12)
    $innerPen.Dispose()
}

function Draw-BrandSymbol([System.Drawing.Graphics]$g, [float]$ox, [float]$oy, [float]$scale) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 30, 35), (2.8 * $scale))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Central spine
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 10 * $scale), ($ox + 50 * $scale), ($oy + 130 * $scale))

    # Upper horns
    $g.DrawBezier($pen, ($ox + 50 * $scale), ($oy + 18 * $scale), ($ox + 20 * $scale), ($oy + 12 * $scale), ($ox + 18 * $scale), ($oy + 48 * $scale), ($ox + 50 * $scale), ($oy + 58 * $scale))
    $g.DrawBezier($pen, ($ox + 50 * $scale), ($oy + 18 * $scale), ($ox + 80 * $scale), ($oy + 12 * $scale), ($ox + 82 * $scale), ($oy + 48 * $scale), ($ox + 50 * $scale), ($oy + 58 * $scale))

    # Center cross
    $g.DrawLine($pen, ($ox + 22 * $scale), ($oy + 40 * $scale), ($ox + 78 * $scale), ($oy + 82 * $scale))
    $g.DrawLine($pen, ($ox + 78 * $scale), ($oy + 40 * $scale), ($ox + 22 * $scale), ($oy + 82 * $scale))

    # Lower barbs
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 82 * $scale), ($ox + 24 * $scale), ($oy + 122 * $scale))
    $g.DrawLine($pen, ($ox + 50 * $scale), ($oy + 82 * $scale), ($ox + 76 * $scale), ($oy + 122 * $scale))

    $pen.Dispose()
}

function Draw-DragonSlayerSword([System.Drawing.Graphics]$g) {
    # Giant sword diagonal
    $bladePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 200, 200, 210), 14.0)
    $bladePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($bladePen, 35, 145, 140, 40)
    $bladePen.Dispose()

    $corePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 220, 25, 30), 4.0)
    $g.DrawLine($corePen, 40, 140, 135, 45)
    $corePen.Dispose()

    # Guard and hilt
    $guardPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 140, 15, 20), 8.0)
    $g.DrawLine($guardPen, 26, 138, 48, 160)
    $guardPen.Dispose()

    $hiltPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 80, 80, 85), 6.0)
    $g.DrawLine($hiltPen, 35, 145, 20, 160)
    $hiltPen.Dispose()
}

function Draw-EclipseSymbol([System.Drawing.Graphics]$g) {
    # Red corona
    $coronaPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 240, 20, 30), 6.0)
    $g.DrawEllipse($coronaPen, 40, 40, 100, 100)
    $coronaPen.Dispose()

    # Black sun core
    $coreBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 8, 12))
    $g.FillEllipse($coreBrush, 45, 45, 90, 90)
    $coreBrush.Dispose()

    # Brand in the center of Eclipse
    Draw-BrandSymbol $g 58 52 0.45
}

foreach ($iconName in $icons) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    Draw-BaseIcon $g $iconName

    if ($iconName -like "*safari*") {
        Draw-EclipseSymbol $g
    } elseif ($iconName -like "*Music*") {
        Draw-DragonSlayerSword $g
    } elseif ($iconName -like "*camera*") {
        # Apostle Eye / Camera Iris
        $eyePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 20, 30), 4.0)
        $g.DrawEllipse($eyePen, 45, 45, 90, 90)
        $eyePen.Dispose()
        $pupilBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 40, 40))
        $g.FillEllipse($pupilBrush, 75, 60, 30, 60)
        $pupilBrush.Dispose()
    } elseif ($iconName -like "*Preferences*" -or $iconName -like "*Settings*") {
        # Iron Gear of Fate
        $gearPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 200, 30, 35), 5.0)
        $g.DrawEllipse($gearPen, 50, 50, 80, 80)
        $gearPen.Dispose()
        Draw-BrandSymbol $g 60 52 0.40
    } elseif ($iconName -like "*Telegraph*" -or $iconName -like "*telegram*") {
        # Wing / Paper plane with blood lightning
        $planePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 40, 50), 3.5)
        $points = @(
            [System.Drawing.PointF]::new(40, 95),
            [System.Drawing.PointF]::new(145, 45),
            [System.Drawing.PointF]::new(90, 140),
            [System.Drawing.PointF]::new(75, 105)
        )
        $g.DrawPolygon($planePen, $points)
        $g.DrawLine($planePen, 145, 45, 75, 105)
        $planePen.Dispose()
    } elseif ($iconName -like "*Sileo*") {
        # Behelit & Dragon crest
        Draw-EclipseSymbol $g
    } else {
        # Default: Iconic Brand of Sacrifice
        Draw-BrandSymbol $g 52 35 0.75
    }

    $outPath = Join-Path $themeDir $iconName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Write-Host "Generated $($icons.Count) Berserk icons successfully in $themeDir"
