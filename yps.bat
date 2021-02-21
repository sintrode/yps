::------------------------------------------------------------------------------
:: NAME
::     YouTube Playlist Sync
::
:: DESCRIPTION
::     Uses youtube-dl to download playlists from a config file
::
:: USAGE
::     yps.bat [-U]
::
:: OPTIONAL ARGUMENTS
::     -U    Updates youtube-dl and ffmpeg. Requires 7-Zip and cURL.
::
:: AUTHOR
::     sintrode
::
:: REQUIREMENTS
::     7-Zip      (https://www.7-zip.org/download.html)
::     cURL       (included in Win 10, or https://curl.haxx.se/download.html)
::     ffmpeg     (https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z)
::     youtube-dl (https://ytdl-org.github.io/youtube-dl/download.html)
::
:: THANKS
::     https://www.reddit.com/r/DataHoarder/comments/c6fh4x/
::
:: VERSION HISTORY
::     1.0 (2020-10-21) - Initial Version
::------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion

::------------------------------------------------------------------------------
::                                  CONSTANTS
::------------------------------------------------------------------------------
:: Internal constants
set "root_dir=%~dp0"
set "curl=%systemroot%\System32\curl.exe"

:: /bin constants
set "bin_dir=%root_dir%bin"
set "ydl=%bin_dir%\youtube-dl.exe"
set "ffmpeg=%bin_dir%\ffmpeg.exe"
set "seven_zip=%bin_dir%\7za.exe"

:: /etc constants
set "etc_dir=%root_dir%etc"
set "archive_file=%etc_dir%\snagged.txt"
set "playlist_list=%etc_dir%\playlists.txt"
set "output_dir=F:\Youtube\"

:: Confirm that prerequisites exist
<nul set /p ".=Checking for prerequisites...[    ]"
if not exist "%curl%" call :prereq_fail curl || exit /b 1
if not exist "%ffmpeg%" call :prereq_fail ffmpeg || exit /b 1
if not exist "%seven_zip%" call :prereq_fail 7-zip || exit /b 1
if not exist "%ydl%" call :prereq_fail youtube-dl || exit /b 1

:: Check for updates if requested
if /I "%~1"=="-U" goto :update

:: Confirm that required files exist
if not exist %archive_file% type nul >%archive_file%
if not exist %playlist_list% type nul >%playlist_list%
if not exist "%output_dir%" mkdir "%output_dir%"
echo [5D[32mPASS[0m

:: Build options list
<nul set /p "=Building options list........[    ]"
set "ydl_format=--format "("
for %%A in (4320 2880 2160 1440 1080 720 480 360 240 144) do (
	set "ydl_format=!ydl_format!bestvideo[vcodec^^=av01][height>=%%A][fps>30]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=vp9.2][height>=%%A][fps>30]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=vp9][height>=%%A][fps>30]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=avc1][height>=%%A][fps>30]/"
    set "ydl_format=!ydl_format!bestvideo[height>=%%A][fps>30]/"
	set "ydl_format=!ydl_format!bestvideo[vcodec^^=av01][height>=%%A]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=vp9.2][height>=%%A]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=vp9][height>=%%A]/"
    set "ydl_format=!ydl_format!bestvideo[vcodec^^=avc1][height>=%%A]/"
    set "ydl_format=!ydl_format!bestvideo[height>=%%A]/"
)
set "ydl_format=!ydl_format!bestvideo)+(bestaudio[acodec^^=opus]/bestaudio)/best""

if "%~1"=="" (
	set "ydl_list=-a %playlist_list%"
) else (
	set "ydl_list=%~1"
)
set "ydl_opts=--no-continue --retries infinite --ignore-errors"
set "ydl_opts=%ydl_opts% --merge-output-format mkv --sleep-interval 2"
set "ydl_opts=%ydl_opts% --download-archive %archive_file%"
set "ydl_output_mask=%output_dir%%%(uploader)s\%%(playlist)s\%%(title)s"
echo [5D[32mPASS[0m]

"%ydl%" %ydl_list% !ydl_format! %ydl_opts% -o %ydl_output_mask%

exit /b 0

::------------------------------------------------------------------------------
:: Downloads youtube-dl and ffmpeg and places them in the current directory
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:update
set "url_7z=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "file_7z=%bin_dir%\ffmpeg-git-full.7z"
"%ydl%" --no-check-certificate --update
"%curl%" -kL %url_7z% -o "%file_7z%"
"%seven_zip%" e -y "%file_7z%" *\bin\ffmpeg.exe
move /y ffmpeg.exe bin
del "%file_7z%"
exit /b

::------------------------------------------------------------------------------
:: Prints FAIL in red letters and opens a browser window to the download page
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:prereq_fail
set "link[7-zip]=https://www.7-zip.org/download.html"
set "link[curl]=https://curl.haxx.se/download.html"
set "link[ffmpeg]=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "link[youtube-dl]=https://ytdl-org.github.io/youtube-dl/download.html"

echo [5D[31mFAIL[0m]
choice /M "%~1 not present. Open a browser to download it "
if "%errorlevel%"=="1" start "" !link[%~1]!
exit /b 1
