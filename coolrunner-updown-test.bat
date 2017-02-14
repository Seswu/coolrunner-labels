@echo off
:START
echo .
echo .
echo _____ Start _____
if "%~1"=="" goto NOPASSWORD
set "password=%1"
if exist .\upload\*.csv (goto UPLOADFILES) else (goto NOFILES)


:UPLOADFILES
::==============
echo .
echo .
echo _____ Upload files _____
set "name=lisbergd6089"
::set "password=xxxxx"
set "server=ftp02.coolrunner.dk"
ping %server% |find /i "TTL=" >nul || (echo server offline, aborting&pause&goto :EOF)
if exist .\ftpUploadScript.txt del /F /Q .\ftpUploadScript.txt

echo open ftp://%name%:%password%@%server%/ >> .\ftpUploadScript.txt
echo CD "/IN" >> .\ftpUploadScript.txt
echo mput -transfer=binary "C:\Users\uw\Lisberg\Clients\Coolrunner\upload\*.csv" >> .\ftpUploadScript.txt
echo close >> .\ftpUploadScript.txt
echo exit >> .\ftpUploadScript.txt

winscp.com /script=.\ftpUploadScript.txt /ini=nul
del /F /Q .\ftpUploadScript.txt
move .\upload\*.csv .\archive
timeout /t 20
::ping 127.0.0.1 -n 20 > nul
GOTO DOWNLOADFILES


:DOWNLOADFILES
::==============
echo .
echo .
echo _____ Download files _____

if exist .\ftpDownloadScript.txt del /F /Q .\ftpDownloadScript.txt

echo open ftp://%name%:%password%@%server%/ >> .\ftpDownloadScript.txt
echo CD "/OUT" >> .\ftpDownloadScript.txt
echo lcd "C:\Users\uw\Lisberg\Clients\Coolrunner\download" >> .\ftpDownloadScript.txt
echo mget -transfer=binary "*.pdf" >> .\ftpDownloadScript.txt
echo mget -transfer=binary "*.csv" >> .\ftpDownloadScript.txt
echo rm "*.pdf" >> .\ftpDownloadScript.txt
echo rm "*.csv" >> .\ftpDownloadScript.txt

echo close >> .\ftpDownloadScript.txt
echo exit >> .\ftpDownloadScript.txt

winscp.com /script=.\ftpDownloadScript.txt /ini=nul
del /F /Q .\ftpDownloadScript.txt
timeout /t 20

::goto DONOTHING
::ping 127.0.0.1 -n 20 > nul
goto PRINTFILES
::goto LOOP


:PRINTFILES
::==============
echo .
echo .
echo _____ Printing files _____

  ::@for /F "delims=" %%p in ('dir /b/a-d /s "C:\newpdf\outgoing\*.pdf" 2^>nul') do (
@for /F "delims=" %%p in ('dir /b /a:-d /o:d  /s .\download\*.pdf 2^>nul') do (
	echo Printing "%%p"
	SumatraPDF -print-to-default "%%p"
	timeout /t 10
	::ping 127.0.0.1 -n 10 > nul
	echo move file: "%%p" to "\download\printed"
	move "%%p" ".\printed"
	)
::goto LOOP
goto DONOTHING


:NOFILES
::==============
goto LOOP


:LOOP
::==============
::repeat with job (endless loop)
timeout /t 20
::t 300
::ping 127.0.0.1 -n 300 > nul
goto START


:NOPASSWORD
::===============
echo No password specified.


:DONOTHING
::===============


:: Direct path to printer
:: SumatraPDF.exe -print-to "ZDesigner GK420d" labeltest.pdf
