#This script uses libraries from the FFmpeg project under the LGPLv2.1
#I got all of the functions I wanted from this script, but I may add in other features and fixes if I can find the time or remember.

#Preamble:
#Hello fellow My Summer Car/My Winter Car gamers and fans!
#I wanted to make a script that uses FFmpeg to convert any audio file I throw into CD1, CD2, CD3, or Radio and converts and renames them to where
#MSC/MWC can use them. I work for an IT-MSP so for batch work like this, I get lazy and just automate stuff as a simple script. I know there's RafaXIS CD-Builder,
#however nexusmods.com put the file under review, so I thought I'd post this as a steam guide, out in the open, completely exposed so you can view the script
#and see what it does. I try my best to comment this script as complete as possible, and try to be down-to-earth on what I write so if you're curious on picking up scripting,
#you can use this as a reference. It is 3 in the morning where I'm at so I might have rambled, but I think I did ok...
#Regretably, I do reference AI, but I do check over each line for functionality if I do use any of it's examples. I don't exclusively reference it, but it is a nice
#tool to work alongside with. learn.microsoft.com is also a good reference, if you want to learn what the verb-noun commands do.
#If you find any tweaks to my code would be worthwhile, please make sure to write a comment on what I should change or add, with the line number. I'll do my best
#to check back in for feedback and update if I can find the time.
#You're completely welcome to modify or rewrite this script, I just ask if you can please send some credit back to me as the original creator. I mean, you don't have
#to, but I'd make me feel warm and fuzzy inside knowing the time spent putting this together was worth it.
#I also want to thank those who work on FFmpeg. Without it, I wouldn't be able to make a script like this.

#VER: 0.6
#Date/Time: 2025/01/01 0954Z
#0.1 Function: Just renames .ogg files, without using FFmpeg
#0.2 Had issues with renaming .ogg files. It liked to count in tens. Idk why, but here I worked the script over again.
#    Started experimenting with wingetting in FFmpeg
#0.4 FFmpeg didn't like to work properly, probably because I was using Get-ChildItem -Include. 
#    Started referencing Gemini and found that Where-Object would be best instead.
#    Added in a File Backup function, so I'm not removing the original files
#0.5 Intended function achieved!
#    Added in checks to see if FFmpeg was already installed, and not to install/uninstall if it was.
#    
#0.6 FFmpeg is converting any files that have album art embedded as a video. Whoops! I don't think MSC/MWC likes that. added -nv parameter
#    also added -c:a libvorbis -q:a 5

#Change this variable to change the audio quality. By default it's set to 5 for balancing quality and speed. (range 0-10)
#Higher is better quality, but larger file
$quality = 5

# This part checks if FFmpeg is already installed, so that way we can skip the installation process through WinGet and avoid uninstalling
# If you had FFmpeg installed already, there's probably a good reason for it, so I don't want to screw up your work process
$ffmpegInstalled = $null -ne (Get-Command ffmpeg -ErrorAction SilentlyContinue)

#FFmpeg isn't installed? That's OK. We'll pull this from WinGet (since that feels more secure) and we'll get rid of it when the script is done.
if (-not $ffmpegInstalled) {
    Write-Host "--- FFmpeg not found. Installing via winget... ---" -ForegroundColor Cyan
    winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements
    
    #Since we can't restart the terminal, we need to refresh Environment Variables so the script can use FFmpeg. Without this the script isn't doing it's job.
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    #As mentioned before, if FFmpeg is already installed, we're not going to install it again via Winget.
    Write-Host "--- FFmpeg already installed. Skipping installation step. ---" -ForegroundColor Green
}

#This part looks for any files that are mp3, wav, flac, m4a, aac, wma, or ogg, then moves them to a temporary working folder called "temp_conversion_process"
#This will be the main working folder, so that way we don't dirty up the folder where MSC/MWC looks for files.
$extensions = ".mp3", ".wav", ".flac", ".m4a", ".aac", ".wma", ".ogg"
$sourceFiles = Get-ChildItem -Path . -File | Where-Object { $extensions -contains $_.Extension.ToLower() }

#Checks if there are files to convert over. If there aren't, then we don't need to run this script. If there are, then we can continue to work on them
if ($sourceFiles.Count -eq 0) {
    Write-Host "--- No audio files found to process. ---" -ForegroundColor Yellow
} else {
#We're creating the temporary work folder, and setting the track number to 1.
    $tempFolder = New-Item -Path ".\temp_conversion_process" -ItemType Directory -Force
    $counter = 1

    #This part says "Hay, we have this many files to work with" for the user so you know how many files the script found.
    #Really for debugging reasons, but I found this satisfying so I kept it in
    Write-Host "--- Step 2: Processing $($sourceFiles.Count) files ---" -ForegroundColor Cyan

    #Ok, this is the exciting part. Simply, for each file in the source files folder, we are going forward, assuming that the file doesn't need to be skipped
    #since it's probably a file that doesn't need to be converted (this changes if it really doesn't need to be converted).
    #We then build the name of the file depending on what the variable counter is set to (for example track1.ogg, track2.ogg)
    #Finally, we build out the target path by using Join-Path, so that way we can put together where the converted file goes.
    foreach ($file in $sourceFiles) {
        $skipConversion = $false
        $outputName = "track$counter.ogg"
        $targetPath = Join-Path $tempFolder.FullName $outputName

        #If the file extension is already .ogg, this checks if the sample rate is 48000 Hz, and if so we set the skipConversion variable to $true, so that way
        #we don't spend any more processing power trying to convert something that already meets MSC/MWC's audio criteria.
        if ($file.Extension -eq ".ogg") {
            $sampleRate = ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$($file.FullName)"
            if ($sampleRate -eq "48000") { $skipConversion = $true }
        }

        #Check if we need to skip conversion, and if so just move the file, renaming it correctly.
        #If we need to convert, this uses ffmpeg to then name the file and convert the file to .ogg with a sample rate of 48000 Hz.
        if ($skipConversion) {
            Write-Host "Skipping '$($file.Name)' (Already 48k OGG). Renaming to $outputName." -ForegroundColor DarkGray
            Copy-Item "$($file.FullName)" -Destination $targetPath
        } else {
            Write-Host "Converting '$($file.Name)' to $outputName..." -ForegroundColor Gray
            ffmpeg -i "$($file.FullName)" -vn -ar 48000 -c:a libvorbis -q:a $quality "$targetPath" -loglevel error -y
        }
        #Conversion done? Great! Let's increment the counter up by 1 so that way we can work on the next track without stepping on our own toes.
        $counter++

        # This part goes on for every file that it has in the sourceFiles variable, and when done, it will continue on to the next section of code
    }




    #Lets start building out the final folder structure, and backup any audio files you moved in here. I'm paranoid about deleting any files off of
    #someone else's computer. I didn't pay for it, so it's not my choice on deleting someone else's files. I hope you understand.
    #Feel free to go through the Backup Files and remove anything after confirming this script works.
    #Sadly, this also moves any preconverted files to the backup folder, but I didn't fix that since that could be a blessing in disguise.
    Write-Host "--- Step 3: Finalizing Folder Structure ---" -ForegroundColor Cyan
    $backupFolder = New-Item -Path ".\Original_Files_Backup" -ItemType Directory -Force
    foreach ($file in $sourceFiles) {
        Move-Item "$($file.FullName)" -Destination $backupFolder.FullName -Force -ErrorAction SilentlyContinue
    }

    #Ok, now that we backed up your original files, that will help me sleep at night.
    #Lets do what you intend to do and move the files back to CD1, CD2, Radio, etc. Basically where this script should be ran.
    Get-ChildItem -Path $tempFolder.FullName | Move-Item -Destination .
    #I know I said I hate deleting files off of other people's computer, but if I'm invited to someone's house, I usually clean up after myself.
    #We did do a backup atleast.
    Remove-Item $tempFolder -Recurse
    Write-Host "Success! Tracks sequenced. Originals moved to 'Original_Files_Backup'." -ForegroundColor Green
}

#Speaking of cleaning up after myself, lets remove FFmpeg if you didn't originally have it installed.
#Normally if I was in-person doing this for someone, I'd just ask "Hey, do you want FFmpeg to remain installed?" but since I'm not there with you,
#I'll just clean up, of course if you already had FFmpeg installed, we'll just leave it alone. Again, i'm paranoid that way...
if (-not $ffmpegInstalled) {
    Write-Host "--- Removing temporary FFmpeg installation... ---" -ForegroundColor Cyan
    winget uninstall -e --id Gyan.FFmpeg --silent
} else {
    Write-Host "--- Keeping existing FFmpeg installation. ---" -ForegroundColor Green
}

#Tally ho! Here's the end of the work. I was thinking about removing the "Press Enter to Continue" part since I added that as a debug, so I can read over
#any outputs, but again, it felt good to get feedback from my script so I kept it in. I guess you can remove it if you want, up to you. I hope you found this script useful.
Write-Host "Conversion and Renaming Complete!" -ForegroundColor White
Read-Host -Prompt "Press Enter to continue..." | Out-Null