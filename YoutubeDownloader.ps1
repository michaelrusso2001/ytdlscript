

function Start-YoutubeToAudioConversion {
    #param ( $youtubeURL, $fileName )
    $oneDrivePath = "$ENV:OneDrive\Desktop"
    If (Test-Path $oneDrivePath) {
        $defaultFilePath = $oneDrivePath
    } else {
        $defaultFilePath = "$ENV:USERPROFILE\Desktop"
    }
    Write-Host "Getting prerequisites and versions... " -NoNewLine
    $version = yt-dlp --version 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "yt-dlp may not be installed.  Attempting to install it..."
        Write-Host "winget install yt-dlp.yt-dlp --accept-source-agreements"
        winget install yt-dlp.yt-dlp --accept-source-agreements
        Write-Host "Please restart this script!"
        Start-Sleep 20
        Break
    }

    if ($version -lt "2025.10.21") {
        Write-Warning "yt-dlp may be out of date, and downloads are more likely to fail.  Attempting to update with winget..."
        Write-Host "winget update yt-dlp.yt-dlp"
        winget install yt-dlp.yt-dlp
        Write-Host "Please restart this script!"
        Start-Sleep 20
        Break

    }

    ## https://patorjk.com/software/taag/#p=display&f=Straight&t=The+Great+and+Powerful%0AYoutube+Downloader+Scripty+Thing&x=none&v=4&h=4&w=80&we=false
    Write-Host @"
___        __                        __           _                             
 | |_  _  / _  _ _ _ |_   _  _  _|  |__)_     _ _(_   |                         
 | | )(-  \__)| (-(_||_  (_|| )(_|  |  (_)\)/(-| | |_||                         
                                                                                
                     __                           __              ___           
\_/_    |_   |_  _  |  \ _     _ | _  _  _| _ _  (_  _ _. _ |_     | |_ . _  _  
 |(_)|_||_|_||_)(-  |__/(_)\)/| )|(_)(_|(_|(-|   __)(_| ||_)|_\/   | | )|| )(_) 
                                                         |    /             _/  
"@
    $youtubeURL = Read-Host "Paste in your Youtube URL here: "

    $url = $youtubeURL -split "&" -like "*v=*"

    Write-Host "Getting Youtube title info..."
    $videoTitle = yt-dlp --get-title $url 2>$null
    Write-Host ""
    Write-Host "Youtube Title : $videoTitle"

    $videoFileName = $videoTitle -replace '[^A-Za-z0-9_.\-\\ ]', ''

    Write-Host "What do you want to call this File?"
    $fileName = Read-Host " (leave blank to use '$videoFileName') "
    if (!($fileName)) {
        $fileName = $videoFileName
    }
    
    $formats = @("wav", "mp3", "mp4")
    $audioFormats = @("wav", "mp3")
    foreach ($format in $formats) {
        $outputFile = Join-Path $ENV:TEMP $fileName
        $outputFullName = $outputFile + ".$format"
        If (Test-Path $outputFullName) {
            Write-Host -ForegroundColor Yellow "File already exists!"
            Write-Host $outputFullName
            Write-Host "Skipped."
        } else {
            Write-Host -NoNewLine "Downloading $format file..."
            If ($format -in $audioFormats) {
                $result = yt-dlp -x --audio-format $format -o "$outputFile.%(ext)s" $url 2>$null
                Copy-Item "$outputFile.$format" "$defaultFilePath\"
            } else {
                $result = yt-dlp -f $format -o "$outputFullName" $url 2>$null
                Copy-Item $outputFullName "$defaultFilePath\"
            }
            Write-Host -ForegroundColor Green "Done!"
            Write-Host "Result: $outputFile.$format"
        }
    }
    Write-Host "" ; Write-Host ""
    Write-Host "Files should be on your Desktop.  Closing this window in 10 seconds."
    Start-Sleep -Seconds 10

}

Start-YoutubeToAudioConversion
