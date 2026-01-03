# My Summer/Winter Car Song Converter and Renamer
A powershell script that levereges Winget and FFmpeg to convert music files into .ogg for My Summer/Winter Car

# Purpose
I love playing MSC and now MWC, however whenever I bought music through 7Digital or rip from a CD, I'll have to open up Audacium, add in all the music I want, convert to .OGG at 48000 Hz sample rate, then rename all of the files to track1.ogg, track2.ogg, etc.

I know that I know there's RafaXIS CD-Builder, however nexusmods.com put the file under review, so I thought I'd post this as a steam guide, out in the open, completely exposed so you can view the script and see what it does.

My powershell script utilizes WinGet to install FFmpeg, then it uses FFmpeg to convert the file to something My Summer/Winter Car can use, then uninstalls FFmpeg (of course unless you already had it installed). Feel free to make any changes or look over my script, I just made this because I felt lazy, and I thought others would appreciate using this. Unfortunately it doesn't change the CD's cover art. In fact, IDK how to even do that within Powershell, however if you're pretty good with GIMP or Photoshop that shouldn't be too hard to do.

# The Script
Download music converter.ps1 and put it into your CD or Radio folders.

#Using the script (and how it works)
Make sure you move over your music to the CD or Radio folder, from wherever you got it them.
Ready to convert? Right click on "music converter.ps1" so then you can select "Run with PowerShell." It may look different depending on how Windows is feeling.
It will open up a PowerShell terminal.
I did my best to have it say what it's doing, but it will download the latest Gyan build of FFmpeg from WinGet, (you can ignore the text saying to restart your shell, the script does that for you). This part is automatically skipped if you already had FFmpeg installed, since you probably have a good reason to install it in the first place. In the next step it then looks in it's current folder, and moves the original files to a temporary work folder, and then converts and renames them so MSC/MWC can use them. Once that's done, it moves the originals to a new folder named "Original_Files_Backup" but it also moves the track files back to where the script is ran. If you didn't have FFmpeg installed, it will then uninstall FFmpeg for you, then it will wait for you to press Enter so the script exits out.

# Launch the Game and Import
All that needs to happen now is for you to launch the game, and import your music from the main menu (bottom left). You should now hear the music on your CD or on the Radio! Yay!

# Shortcomings
There are a few shortcomings with this script unfortunately. I did just make this set-and-forget, however when you add in more music, it works alphabetically, so it will either put your music before the track file, or after the track files. If you want to put your music in a specific place, I would add a number at the very beginning of the song then run the script. I know that defeats half the purpose of this script, but that's the only roundabout way I can think on doing this.
