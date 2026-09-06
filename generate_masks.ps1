Add-Type -AssemblyName System.Drawing

$maskDir = "layout\Library\Themes\BerserkTheme.theme\Masks"

function Generate-Mask([int]$size, [string]$suffix) {
    # 1. Mask (solid white rounded rectangle)
    $bmpMask = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmpMask)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $radius = [int]($size * 0.22)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc(0, 0, $d, $d, 180, 90)
    $path.AddArc($size - $d, 0, $d, $d, 270, 90)
    $path.AddArc($size - $d, $size - $d, $d, $d, 0, 90)
    $path.AddArc(0, $size - $d, $d, $d, 90, 90)
    $path.CloseFigure()

    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillPath($brushWhite, $path)
    $brushWhite.Dispose()
    $path.Dispose()
    $g.Dispose()

    $bmpMask.Save((Join-Path $maskDir "AppIconMask$suffix.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmpMask.Dispose()

    # 2. Overlay (dark steel border with crimson glow)
    $bmpOverlay = New-Object System.Drawing.Bitmap($size, $size)
    $g2 = [System.Drawing.Graphics]::FromImage($bmpOverlay)
    $g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g2.Clear([System.Drawing.Color]::Transparent)

    $path2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $inset = [int]($size * 0.02)
    $path2.AddArc($inset, $inset, $d, $d, 180, 90)
    $path2.AddArc($size - $d - $inset, $inset, $d, $d, 270, 90)
    $path2.AddArc($size - $d - $inset, $size - $d - $inset, $d, $d, 0, 90)
    $path2.AddArc($inset, $size - $d - $inset, $d, $d, 90, 90)
    $path2.CloseFigure()

    # Outer crimson glow
    $penGlow = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 255, 20, 30), [float]($size * 0.035))
    $g2.DrawPath($penGlow, $path2)
    $penGlow.Dispose()

    # Inner steel hairline
    $penSteel = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 200, 180, 190), [float]($size * 0.015))
    $g2.DrawPath($penSteel, $path2)
    $penSteel.Dispose()

    $path2.Dispose()
    $g2.Dispose()

    $bmpOverlay.Save((Join-Path $maskDir "AppIconOverlay$suffix.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmpOverlay.Dispose()
}

Generate-Mask 120 "@2x"
Generate-Mask 180 "@3x"
Generate-Mask 60 ""

Write-Host "Masks generated successfully in $maskDir"
