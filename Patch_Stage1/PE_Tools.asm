;********************************************************************
;作者：	Cobber
;时间：	初步完成:2013.9.9	 最终完成:2013.12.18
;感谢：	xiaokong，帮我解决了RVA转换功能中的部分代码：_atoh函数
;致谢：	罗云彬老师的部分代码：_RvaToFileOffset.asm及_CmdLine.asm
;********************************************************************
		.386
		.model flat, stdcall
		option casemap :none
;********************************************************************
; Include 文件定义
;********************************************************************
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		gdi32.inc
includelib	gdi32.lib	
include		comdlg32.inc
includelib	comdlg32.lib
include 	shell32.inc	;文件拖放
includelib 	shell32.lib
include  	advapi32.inc	;注册表操作
includelib 	advapi32.lib
include		SkinMagic.inc
includelib	SkinMagic.lib
;********************************************************************
; Equ 等值定义
;********************************************************************
ICO_MAIN	equ		101	;图标
IDC_DIALOGS	equ		100
ListBox1	equ		2000
IDC_BUTTON2	equ		1013
IDC_BUTTON3	equ		1021
IDC_BUTTON1	EQU		1000
IDC_BUTTON20	EQU		2001
IDC_BUTTON4	EQU		1022
CheckBox1	equ		1011
CheckBox2	equ		1012
Text_Name	equ		1001
TextBox_1002	equ		1002
TextBox_1003	equ		1003
TextBox_1004	equ		1004
TextBox_1005	equ		1005
TextBox_1009	equ		1009
TextBox_1010	equ		1010
TextBox_1006	equ		1006
TextBox_1007	equ		1007
TextBox_1008	equ		1008
TextBox_1014	equ		1014
TextBox_1016	equ		1016
TextBox_1017	equ		1017
TextBox_1018	equ		1018
TextBox_1015	equ		1015
TextBox_1019	equ		1019
TextBox_1020	equ		1020	
APPEND_SIZE	EQU		200h
;********************************************************************
; 数据段
;********************************************************************
		.data
szStagedSize	db	'200h',0
szStagedSecName	db	'.reloc',0	
szShellcode	db	'staged.bin',0
lpJmpBuffer	db	5	dup(0)	
regFlag		dd	0
IsPacked	dd	0
flagAttach	dd	0
hMapMemory	dd	0
dwVirtueSize	dd	0
hFile		dd	0
hMap		dd	0
FlagWrongPE	dd	0
szTitle		db	'提示',0
;dwJmpOffset	dd	19Dh
dwJmpCalcOffset dd	0
szWriteFmt	db	'%d',0
szMsgFmt	db	'%s',0
szRegFmt	db	'"%s"',0
szDesFmt	db	'%08d',0
lpDataSecName1	db	'.data',0
lpDataSecName2	db	'.rdata',0
lpCodeSecName1	db	'.text',0
lpCodeSecName2	db	'CODE',0
szSkinFile	db	'corona.smf',0
szIniFileFmt	db	'%s\PE_Tools.ini',0
szLogFmt2	db	'%s\%s_Export_API.txt',0
szLogFmt4	db	'%s\%s.dmp',0
szLogFmt3	db	'%s\%s_Strings.txt',0
szSkinFmt	db	'%s\%s',0
szLogFmt	db	'%s\%s_Import_API.txt',0
szSkinInit	db	'InitSkinMagicLib',0
szSkinExit	db	'ExitSkinMagicLib',0
szSkinLoad	db	'LoadSkinFile',0
szSkinSet	db	'SetDialogSkin',0
szDialog	db	'Dialog' , 0
szLogTextFmt	db	'%s',0dh,0ah,0
szBakFileFmt	db	'%s.bak',0
szCmdFmt	db	'start %s "%s"',0
szOpen		db	'open',0
szTmp		db	' "%1"',0
szStringFmt	db	'字符串已经成功导出至 %s',0
szMsgSection	db	'节名  偏移地址  节区大小  Raw偏移  Raw尺寸  节区属性',0
szFmtSection	db	'%s  %08X  %08X  %08X  %08X  %08X',0dh,0ah,0
szErrorInput	db	'输入有误，请重试',0
szPackedInfo	db	'程序可能被加壳，部分功能不可用',0
szLogSuccFmt	db	'文件已成功导出至  %s',0
szEmptyError	db	'输入不能为空，请重试',0
szErrorFileHandle db	'该文件正在被使用，获取文件句柄失败',0
szErrorFileEmpty db	'该文件为空,不是有效的PE文件',0
szChange0EPSuc	db	'入口点修改成功,请重新打开',0
szErrorPE	db	'不能为自己添加区段',0
addSectionSuccess db	'区段添加成功,程序将重新打开',0
szStringBuffer	db	'字符串导出成功!',0
szInvaild	db	'区段名不得大于8'
szErrrSizeFmt	db	'输入的内存偏移应大于%08X,小于%08X',0
szSkinDll	db	'SkinMagic.dll',0
szRegKey    	db  	'Software\CLASSES\exefile\shell',0
szRegKey2    	db  	'Software\CLASSES\dllfile\shell',0
szRegSubKey	db	'Software\CLASSES\exefile\shell\Open With Patch_Stage',0
szRegSubKey2	db	'Software\CLASSES\dllfile\shell\Open With Patch_Stage',0
szRegName	db	'Open With Patch_Stage',0
szCommand	db	'command',0
szRegPath	db	'Software\CLASSES\exefile\shell\Open With Patch_Stage\command',0
szRegPath2	db	'Software\CLASSES\dllfile\shell\Open With Patch_Stage\command',0
szRegMsgSuc	db	'系统右键添加成功！',0
szRegCancel	db	'系统右键取消成功！',0
szErrorText	db	'不是有效的PE文件，请重新选择',0	
SubSystemType0	db	'未知的子系统',0
SubSystemType1	db	'驱动程序',0
SubSystemType2	db	'Windows GUI',0
SubSystemType3	db	'Windows Console',0
SubSystemType5	db	'OS2 Console',0
SubSystemType7	db	'POSIX Console',0
SubSystemType8	db	'不需子系统',0
SubSystemType9	db	'Windows CE',0
szHexFmt	db	'%08X',0
szExtPe		db	'PE Files(*.exe)',0,'*.exe',0
szDllPe		db	'PE Files(*.dll)',0,'*.dll',0
szAllFile	db	'ALL Files(*.*)',0,'*.*',0
lpShellBuffer	db	200	dup(0)
CurrentDirectory db	100	dup(0)
dataBuffer2	db	10	dup(0)
dataBuffer3	db	10	dup(0)
dataBuffer	db	10	dup(0)
szDataOver	db	1000	dup(0)
szRegBuffer	db	100	dup(0)
lpFileName	db	100	dup(0)
szRegBuffer2	db	100	dup(0)
szFileName	db	100	dup(0)
szAppBuffer	db	100	dup(0)
IniFileBuffer	db	100	dup(0)
szSkinBuffer	db	100	dup(0)
szRegValue	db	100	dup(0)
szErrorBuffer	db	20	dup(0)
bufferFileName	db	100	dup(0)
szShortFileName	db	100	dup(0)
szDumpFileName	db	100	dup(0)
szDataBuffer	db	1000	dup(0)
szBlank		db	10	dup(0)
SectionHeaderSize	dd	sizeof IMAGE_SECTION_HEADER
		
		.data?
stOF		OPENFILENAME	<>
hShellFile	dd	?
hKey		HKEY	?
hKey2		HKEY	?	
hSubKey		HKEY	?
hSubKey3	HKEY	?
hSubKey2	HKEY	?
hSubKey4	HKEY	?
SectionNum	dd	?
dataValue	dd	?
value		dd	?
addrRVA		dd	?	
hInstance	dd	?
hListBox	dd	?
dwSectionSize	dd	?
ddFileSize	dd	?
hSkinExit	dd	?
dwRVA		dd	?
dwImageBase	dd	?
dwImageSize	dd	?
lpLastSection	dd	?
hSkinDll	dd	?
baseCode	dd	?
hIniFile	dd	?
lpFileHead	dd	?
RvaData		dd	?
hDlg2		dd	?
hDlg3		dd	?	
lpPeHeader	dd	?
hButtonString	dd	?
dwValue		dd	?
dwValueTemp	dd	?
;**********************************************************************************************
; 代码段
;**********************************************************************************************
		.code
		include	PE_Tools.inc
		
_ResverValue	proc	
		pushad
		xor	ebx,ebx
		mov	ecx,4
		lea	esi,dwValue
		lea	edi,dwValueTemp
		add	edi,3
	_loop:	
		mov	al,byte ptr[esi]
		mov	byte ptr[edi],al
		inc	esi
		dec	edi
		dec	ecx
		jne	_loop
		popad
		ret

_ResverValue endp						
		
;**********************************************************************************************
;根据给定的文件名，获取短文件名
;**********************************************************************************************
_getShortFileName	proc uses esi ebx ecx edx edi lpFileShortName
		mov	esi,lpFileShortName
		invoke lstrlen,esi
 		mov	ecx,eax
 		xor	ebx,ebx
 		inc	ecx
 		dec	ebx
 		xor	edx,edx
		push	esi
 		xor	eax,eax
 	_loop:
 		inc	ebx
 		dec	ecx
;**********************************************************************************************
; 查找最后一个'\'的位置，加1就是短路径文件名的起始地址
;**********************************************************************************************
 		cmp	byte ptr[esi+ebx],5Ch
 		je	_cmp
 		cmp	ecx,0
 		je	_exit
 		jmp	_loop
	_cmp:
		mov	edx,ebx
		cmp	ecx,0
		je	_exit
		jmp	_loop
	_exit:	
		inc	edx
		pop	esi
		add	esi,edx
		xor	eax,eax
		xor	ebx,ebx
	_cpy:	
		lea	edi,szShortFileName
		mov	al,byte ptr[esi+ebx]
		mov	byte ptr[edi+ebx],al
		inc	ebx
		test	eax,eax
		jne	_cpy
		ret
_getShortFileName endp

;**********************************************************************************************
;加载皮肤
;**********************************************************************************************
_LoadSkin	proc	_hWnd

		invoke	InitSkinMagicLib,hInstance,NULL , NULL , NULL
		invoke	LoadSkinFile,addr szSkinBuffer
		invoke	SetWindowSkin,_hWnd ,addr szDialog
		ret
_LoadSkin	endp

;**********************************************************************************************
;判断是否是系统右键附加(命令行参数是否大于1)，并修正文件名称	
;**********************************************************************************************
_Check	proc
		invoke	_argc
		.if	eax>1
			invoke	_argv,0,addr lpFileName,sizeof lpFileName
			invoke 	lstrlen,addr lpFileName
 			mov	ecx,eax
 			xor	ebx,ebx
 			inc	ecx
 			dec	ebx
 			xor	edx,edx
 			lea	esi,lpFileName
 			xor	eax,eax
 		_loop:
 			inc	ebx
 			dec	ecx
 			cmp	byte ptr[esi+ebx],5Ch
 			je	_cmp
 			cmp	ecx,0
 			je	_exit
 			jmp	_loop
		_cmp:
			mov	edx,ebx
			cmp	ecx,0
			je	_exit
			jmp	_loop
		_exit:	
			mov	byte ptr[esi+edx],0h
			invoke	wsprintf,addr IniFileBuffer,addr szIniFileFmt,esi
			invoke	wsprintf,addr szSkinBuffer,addr szSkinFmt,esi,addr szSkinFile
		.elseif	eax==1
			invoke	GetCurrentDirectory,sizeof CurrentDirectory,addr CurrentDirectory
			invoke	wsprintf,addr IniFileBuffer,addr szIniFileFmt,addr CurrentDirectory
			invoke	wsprintf,addr szSkinBuffer,addr szSkinFmt,addr CurrentDirectory,addr szSkinFile
		.endif	
		
	ret

_Check endp

;**********************************************************************************************
;获取字符串，显示到ListView	
;**********************************************************************************************
_getStringView	proc	_lpPeHeader,_hListBox
			LOCAL   @SectionNum
			local 	@lpDataAddr,@dwDataSize,@dwMaxDataAddr
			pushad
			push	SectionNum
			pop	@SectionNum
			mov	edi,_lpPeHeader
			assume	edi:ptr IMAGE_NT_HEADERS
			add	edi,sizeof IMAGE_NT_HEADERS
			assume	edi:ptr IMAGE_SECTION_HEADER
		_loop1:
			push	edi
			invoke	lstrcmp,edi,addr lpDataSecName1
			.if	!eax
				push	[edi].PointerToRawData
				pop	@lpDataAddr
				push	[edi].SizeOfRawData
				pop	@dwDataSize
				mov	eax,@lpDataAddr
				add	eax,@dwDataSize
				mov	@dwMaxDataAddr,eax
			.endif
			pop	edi
			add	edi,SectionHeaderSize
			dec	@SectionNum
			jne	_loop1
			mov	eax,dwVirtueSize
			add	@dwMaxDataAddr,eax
			push	dword ptr @lpDataAddr
			pop	edi
			add	edi,eax
			mov	ecx,@dwDataSize

		_loop2:	
			invoke	RtlZeroMemory,addr szDataBuffer,sizeof szDataBuffer
			cld
			mov	ecx,@dwDataSize
			repe	scasb
			dec	edi
			cmp	edi,@dwMaxDataAddr
			jg	_end
			mov	esi,edi
			invoke	lstrlen,esi
			mov	ecx,eax
			add	edi,ecx
			push	edi
			lea	edi,szDataBuffer
			cld
			rep	movsb
			invoke	SendMessage,_hListBox,LB_ADDSTRING,0,addr szDataBuffer
			pop	edi
			inc	edi
			cmp	edi,@dwMaxDataAddr
			jb	_loop2
		_end:	
			push	SectionNum
			pop	@SectionNum
			mov	edi,_lpPeHeader
			assume	edi:ptr IMAGE_NT_HEADERS
			add	edi,sizeof IMAGE_NT_HEADERS
			assume	edi:ptr IMAGE_SECTION_HEADER
		_loop3:
			push	edi
			invoke	lstrcmp,edi,addr lpDataSecName2
			.if	!eax
				push	[edi].PointerToRawData
				pop	@lpDataAddr
				push	[edi].SizeOfRawData
				pop	@dwDataSize
				mov	eax,@lpDataAddr
				add	eax,@dwDataSize
				mov	@dwMaxDataAddr,eax
			.endif
			pop	edi
			add	edi,SectionHeaderSize
			dec	@SectionNum
			jne	_loop3
			mov	eax,dwVirtueSize
			add	@dwMaxDataAddr,eax
			push	dword ptr @lpDataAddr
			pop	edi
			add	edi,eax
			mov	ecx,@dwDataSize
		_loop4:	
			invoke	RtlZeroMemory,addr szDataBuffer,sizeof szDataBuffer
			cld
			mov	ecx,@dwDataSize
			repe	scasb
			dec	edi
			cmp	edi,@dwMaxDataAddr
			jg	_end1
			mov	esi,edi
			invoke	lstrlen,esi
			mov	ecx,eax
			add	edi,ecx
			push	edi
			lea	edi,szDataBuffer
			cld
			rep	movsb
			invoke	SendMessage,_hListBox,LB_ADDSTRING,0,addr szDataBuffer
			pop	edi
			inc	edi
			cmp	edi,@dwMaxDataAddr
			jb	_loop4
		_end1:	
			popad
		ret
_getStringView endp

;**********************************************************************************************
;Dump文件
;**********************************************************************************************
_dumpFile	proc	_hWnd,_lpDumpAddr,_dwDumpSize
		LOCAL	@lpDumpAddr,@dwDumpSize
		LOCAL	@nBytes[40]:byte
		LOCAL	@buffer[100]:byte
		LOCAL	@temp1[100]:byte
		LOCAL	@temp2[100]:byte
		LOCAL	@temp5[100]:byte
		LOCAL	@hFile
		pushad
		invoke	_RVAToOffset,lpFileHead,_lpDumpAddr
		mov	@lpDumpAddr,eax
		push	_dwDumpSize
		pop	@dwDumpSize
		invoke	lstrcpy,addr @temp5,addr bufferFileName
		invoke lstrlen,addr @temp5
 		mov	ecx,eax
 		xor	ebx,ebx
 		inc	ecx
 		dec	ebx
 		xor	edx,edx
 		lea	esi,@temp5
 		xor	eax,eax
 	_loop:
 		inc	ebx
 		dec	ecx
 		cmp	byte ptr[esi+ebx],5Ch
 		je	_cmp
 		cmp	ecx,0
 		je	_exit
 		jmp	_loop
	_cmp:
		mov	edx,ebx
		cmp	ecx,0
		je	_exit
		jmp	_loop
	_exit:	
		mov	byte ptr[esi+edx],0h
		invoke	_getShortFileName,addr bufferFileName
		invoke	wsprintf,addr @temp2,addr szLogFmt4,addr @temp5,addr szShortFileName
		
		invoke	CreateFile,addr @temp2,GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov	@hFile,eax
		mov	esi,dwVirtueSize
		add	esi,@lpDumpAddr
		invoke	WriteFile,@hFile,esi,@dwDumpSize,addr @nBytes,NULL
	_cpy:
		invoke	wsprintf,addr @buffer,addr szLogSuccFmt,addr @temp2
		invoke	MessageBox,_hWnd,addr @buffer,addr szTitle,MB_OK
		invoke	CloseHandle,@hFile
		popad
		ret

_dumpFile endp

;********************************************************************************************************
;判断是否存在.data区段，作为是否显示字符串按钮的依据；判断是否存在.text/code区段，作为判断是否被加壳依据
;********************************************************************************************************
_IsDataSection	proc	_lpPeHeader
		LOCAL	@SectionName[10]:byte
		push	esi
		mov	esi,_lpPeHeader
		assume	esi:ptr IMAGE_NT_HEADERS
		add	esi,sizeof IMAGE_NT_HEADERS
		assume	esi:ptr IMAGE_SECTION_HEADER
	_loop:	
		push	esi
		lea	edi,@SectionName
		mov	ecx,8
		cld
		rep	movsb
		invoke	lstrcmp,addr lpDataSecName1,addr @SectionName
		.if	!eax
			mov	eax,1
			pop	esi
			jmp	_endLoop
		.endif
		invoke	lstrcmp,addr lpCodeSecName1,addr @SectionName
		.if	!eax
			mov	IsPacked,1
		.endif
		invoke	lstrcmp,addr lpCodeSecName2,addr @SectionName
		.if	!eax
			mov	IsPacked,1
		.endif
		pop	esi
		add	esi,sizeof IMAGE_SECTION_HEADER
		mov	al,byte ptr[esi]
		movzx	eax,al
		.if	eax
			jmp	_loop
		.endif
		xor	eax,eax
		
	_endLoop:
		pop	esi
		ret
_IsDataSection endp

;**********************************************************************************************
;从文本框中获取十六进制到eax中
;**********************************************************************************************
_atoh 	proc 	lpbuffer:DWORD	
		LOCAL	@dwRet
		pushad
		xor 	ebx,ebx
		xor 	ecx,ecx
		mov 	edi,lpbuffer
	@@:	mov 	al,byte ptr [edi+ecx]
		.if 	(al>2fh )&&(al<3ah)
		sub 	al,30h
		add 	bl,al
		.elseif (al>40h)&&(al<48h)
		sub 	al,37h
		add 	bl,al
		.elseif (al>60h)&&(al<68h)
		sub 	al,57h
		add 	bl,al
		.else 
		mov 	eax,ebx
		shr 	eax,4
		mov	@dwRet,eax
		popad
		mov	eax,@dwRet
		ret
		.endif
		shl 	ebx,4
		inc 	ecx
		jmp 	@b	
_atoh 	endp

;**********************************************************************************************
;设置按钮为可用
;**********************************************************************************************
_EnableText	proc	_hWnd
		LOCAL	@temp[10]:byte
		invoke	GetDlgItem,_hWnd,1022
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1021
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1023
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1025
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1029
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1030
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1006
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1026
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1027
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1024
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,_hWnd,1019
		invoke	EnableWindow,eax,TRUE
		invoke	RtlZeroMemory,addr @temp,sizeof @temp
		invoke	SetDlgItemText,_hWnd,TextBox_1019,addr @temp
		invoke	SetDlgItemText,_hWnd,1030,addr @temp
		invoke	SetDlgItemText,_hWnd,1029,addr @temp
		invoke	SetDlgItemText,_hWnd,TextBox_1006,addr @temp
		ret
_EnableText endp

;**********************************************************************************************
;设置按钮为不可用
;**********************************************************************************************
_disableButton 	proc _hWnd
		LOCAL	@temp[10]:byte
		invoke	RtlZeroMemory,addr @temp,sizeof @temp
		invoke	GetDlgItem,_hWnd,1022
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1021
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1023
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1024
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1025
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1026
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1027
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1028
		invoke	EnableWindow,eax,FALSE	
		invoke	SetDlgItemText,_hWnd,1029,addr @temp
		invoke	SetDlgItemText,_hWnd,1030,addr @temp
		invoke	SetDlgItemText,_hWnd,1019,addr @temp
		invoke	SetDlgItemText,_hWnd,1006,addr @temp
		ret

_disableButton endp

;**********************************************************************************************
;设置所有按钮为不可用
;**********************************************************************************************
_disableAll	proc	_hWnd
		LOCAL	@temp[10]:byte
		invoke	RtlZeroMemory,addr @temp,sizeof @temp
		invoke	SetDlgItemText,_hWnd,1002,addr @temp
		invoke	SetDlgItemText,_hWnd,1003,addr @temp
		invoke	SetDlgItemText,_hWnd,1004,addr @temp
		invoke	SetDlgItemText,_hWnd,1005,addr @temp
		invoke	SetDlgItemText,_hWnd,1009,addr @temp
		invoke	SetDlgItemText,_hWnd,1010,addr @temp
		invoke	SetDlgItemText,_hWnd,1006,addr @temp
		invoke	SetDlgItemText,_hWnd,1015,addr @temp
		invoke	SetDlgItemText,_hWnd,1007,addr @temp
		invoke	SetDlgItemText,_hWnd,1008,addr @temp
		invoke	SetDlgItemText,_hWnd,1014,addr @temp
		invoke	SetDlgItemText,_hWnd,1016,addr @temp
		invoke	SetDlgItemText,_hWnd,1017,addr @temp
		invoke	SetDlgItemText,_hWnd,1018,addr @temp
		invoke	SetDlgItemText,_hWnd,1029,addr @temp
		invoke	SetDlgItemText,_hWnd,1030,addr @temp
		invoke	SetDlgItemText,_hWnd,1019,addr @temp
		invoke	SetDlgItemText,_hWnd,1020,addr @temp
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1022
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1021
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1023
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1024
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1025
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1026
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1027
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,_hWnd,1028
		invoke	EnableWindow,eax,FALSE	
		ret
_disableAll endp

;**********************************************************************************************
;设置文件/内存对齐
;**********************************************************************************************
_Align	proc	uses edx _dwAlignSize,_dwFileSize
		mov	eax,_dwFileSize
		xor	edx,edx
		div	_dwAlignSize
		.if	edx
			inc	eax
		.endif
		mul	_dwAlignSize
		ret
_Align endp

;**********************************************************************************************
;获取导入表信息
;**********************************************************************************************
_getImportTable	proc	_hWnd,@hListBox1,@hListBox2
		LOCAL	@tempBuffer[100]:byte
		pushad	
		mov	esi,lpFileHead	
		assume esi:ptr IMAGE_DOS_HEADER
		add	esi,[esi].e_lfanew	;指向PE文件头
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	eax,[esi].OptionalHeader.DataDirectory[8].VirtualAddress
		invoke	_RVAToOffset,lpFileHead,eax
		add	eax,lpFileHead
		mov	edi,eax
		push	edi
		assume	edi:ptr IMAGE_IMPORT_DESCRIPTOR
		.while	[edi].Name1
			invoke	_RVAToOffset,lpFileHead,[edi].Name1
			add	eax,lpFileHead
			invoke	SendMessage,@hListBox1,LB_ADDSTRING,0,eax
			add	edi,sizeof IMAGE_IMPORT_DESCRIPTOR
		.endw
		pop	esi
		
		assume	esi:ptr IMAGE_IMPORT_DESCRIPTOR
		.while	[esi].Name1
			.if	[esi].OriginalFirstThunk
				mov	eax,[esi].OriginalFirstThunk
			.else
			mov	eax,[esi].FirstThunk
			.endif	
			invoke	_RVAToOffset,lpFileHead,eax
			add	eax,lpFileHead
			mov	ebx,eax
			.while	dword ptr [ebx]
				invoke	_RVAToOffset,lpFileHead,dword ptr[ebx]
				add	eax,lpFileHead
				assume	eax:ptr IMAGE_IMPORT_BY_NAME
				invoke	SendMessage,@hListBox2,LB_ADDSTRING,0,addr [eax].Name1
				add	ebx,4
			.endw
			add	esi,sizeof IMAGE_IMPORT_DESCRIPTOR
		.endw
		popad
		ret

_getImportTable endp

;**********************************************************************************************
;获取导出表信息
;**********************************************************************************************
_getExportTable	proc	_hWnd,@hListBox1,@hListBox2
		LOCAL	@tempBuffer[100]:byte
		LOCAL	@nNum
		LOCAL	@tmp
		pushad	
		mov	esi,lpFileHead	
		assume esi:ptr IMAGE_DOS_HEADER
		add	esi,[esi].e_lfanew	;指向PE文件头
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	eax,[esi].OptionalHeader.DataDirectory[0].VirtualAddress
		invoke	_RVAToOffset,lpFileHead,eax
		add	eax,lpFileHead
		mov	edi,eax
		assume	edi:ptr IMAGE_EXPORT_DIRECTORY
		.if	[edi].nName
			invoke	_RVAToOffset,lpFileHead,[edi].nName
			add	eax,lpFileHead
			mov	@tmp,eax
			invoke	SendMessage,@hListBox1,LB_ADDSTRING,0,eax
		.endif
		push	[edi].NumberOfNames
		pop	@nNum
		.while	@nNum
			invoke	lstrlen,@tmp
			add	@tmp,eax
			inc	@tmp
			invoke	SendMessage,@hListBox2,LB_ADDSTRING,0,@tmp
			dec	@nNum
		.endw	
		popad
		ret
_getExportTable endp

;**********************************************************************************************
;将区段信息在listBox中显示出来
;**********************************************************************************************
_getSectionView	proc	_hWnd
		LOCAL	@szSectionName[10]:byte
		LOCAL	@szBuffer[100]:byte
		LOCAL   @temp
			pushad
			push SectionNum
			pop	 @temp
			mov	edi,lpPeHeader
			assume	edi:ptr IMAGE_NT_HEADERS
			movzx	ecx,[edi].FileHeader.NumberOfSections
			add	edi,sizeof IMAGE_NT_HEADERS
			assume	edi:ptr IMAGE_SECTION_HEADER
			invoke	SendMessage,hListBox,LB_ADDSTRING,0,addr szMsgSection
		_loop:
			invoke	RtlZeroMemory,addr @szBuffer,sizeof @szBuffer
			invoke	RtlZeroMemory,addr @szSectionName,sizeof @szSectionName
			mov	esi,edi
			push	edi
			lea	edi,@szSectionName
			mov	ecx,8
			cld
			rep	movsb
			pop	edi
			invoke	wsprintf,addr @szBuffer,addr szFmtSection,\
				addr @szSectionName,[edi].VirtualAddress,\
				[edi].Misc.VirtualSize,[edi].PointerToRawData,\
				[edi].SizeOfRawData,[edi].Characteristics
			invoke	SendMessage,hListBox,LB_ADDSTRING,0,addr @szBuffer
			add	edi,SectionHeaderSize
			dec	@temp
			jne	_loop
			popad
		ret
_getSectionView endp

;**********************************************************************************************
;获取最后一个节区偏移地址，返回到eax
;**********************************************************************************************
_getSectionVaddr	proc	
			LOCAL	@temp
			push	esi
			mov	esi,lpPeHeader
			assume	esi:ptr IMAGE_NT_HEADERS
			mov	cx,[esi].FileHeader.NumberOfSections
			movzx	ecx,cx
			add	esi,sizeof IMAGE_NT_HEADERS
			assume	esi:ptr IMAGE_SECTION_HEADER
			push	[esi].VirtualAddress
			pop	baseCode
			mov	eax,sizeof IMAGE_SECTION_HEADER
			dec	ecx
			mul	ecx
			add	esi,eax
			mov	eax,[esi].VirtualAddress
			add	eax,[esi].Misc.VirtualSize
			mov	lpLastSection,eax
			assume 	esi:nothing 
			pop	esi
			
		ret
_getSectionVaddr endp

;**********************************************************************************************
;添加新的区段
;**********************************************************************************************
_addNewSection	proc	_lpFileName,_lpSectionName
			LOCAL	@hfile,@filesize,@hfileMap
			LOCAL	_dwFileAlign,_dwSectionAlign
			LOCAL 	@dwSec,@dwFile,@dwFileTemp,@dwNTHeader,@dwOEP,@dwShellSize  	
			pushad
			invoke	CreateFile,_lpFileName,GENERIC_WRITE+GENERIC_READ,FILE_SHARE_WRITE+FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
			mov	@hfile,eax
			invoke	GetFileSize,@hfile,NULL
			mov	@filesize,eax
			add	eax,APPEND_SIZE
			invoke	CreateFileMapping,@hfile,NULL,PAGE_READWRITE,0,eax,0
			mov	@hfileMap,eax
			invoke	MapViewOfFile,eax,FILE_MAP_WRITE+FILE_MAP_COPY,0,0,0
			mov	esi,eax
			assume	esi:ptr IMAGE_DOS_HEADER
			add	esi,[esi].e_lfanew
			assume	esi:ptr IMAGE_NT_HEADERS
			push	esi			
			pop 	@dwNTHeader
			push 	[esi].OptionalHeader.AddressOfEntryPoint	;OEP
			pop	@dwOEP
			xor	ecx,ecx
			mov	cx,word ptr[esi].FileHeader.NumberOfSections	;区段数目
			movzx	ecx,cx
			push	esi
			inc	word ptr[esi].FileHeader.NumberOfSections
			push	[esi].OptionalHeader.FileAlignment		;文件偏移大小
			pop	_dwFileAlign
			push	[esi].OptionalHeader.SectionAlignment		;内存偏移大小
			pop	_dwSectionAlign
			;;mov	eax, 1c0h
			;;add	eax, dword ptr[esi].OptionalHeader.SizeOfCode
			;;push 	eax
			;;pop	dword ptr[esi].OptionalHeader.SizeOfCode
			
			
			add	esi,sizeof IMAGE_NT_HEADERS
			assume	esi:ptr IMAGE_SECTION_HEADER
			mov	eax,sizeof IMAGE_SECTION_HEADER
			dec	ecx
			mul	ecx
			add	esi,eax
			assume	esi:ptr IMAGE_SECTION_HEADER
			invoke	_Align,_dwSectionAlign,[esi].Misc.VirtualSize	;虚拟内存大小
			add	eax,[esi].VirtualAddress			;虚拟内存偏移
			mov	@dwSec,eax
			push 	esi
			mov	esi,@dwNTHeader	
			assume	esi:ptr IMAGE_NT_HEADERS
			mov	dword ptr[esi].OptionalHeader.AddressOfEntryPoint,eax	
			pop	esi
			assume	esi:ptr IMAGE_SECTION_HEADER					
			mov	edx,[esi].PointerToRawData			;物理内存偏移
			add	edx,[esi].SizeOfRawData				;物理内存大小
			mov	@dwFile,edx
			add	esi,sizeof IMAGE_SECTION_HEADER
			assume	esi:ptr IMAGE_SECTION_HEADER
			push	0E0000020h					;可读可写可执行属性
			pop	[esi].Characteristics
			push	@dwSec
			pop	[esi].VirtualAddress
			mov	[esi].PointerToRawData,edx
			invoke	_Align,_dwFileAlign,dwSectionSize		;按文件偏移大小对齐文件			
			push	eax
			pop	[esi].SizeOfRawData
			mov	[esi].Misc.VirtualSize,eax
			lea	edi,[esi].Name1					;区段名
			mov	esi,_lpSectionName
			invoke	lstrlen,esi
			mov	ecx,eax
			cld
			rep	movsb
			pop	esi
			assume	esi:ptr IMAGE_NT_HEADERS
			mov	eax,_dwSectionAlign			
			add	eax,@dwSec
			mov	[esi].OptionalHeader.SizeOfImage,eax		;修改镜像大小
			assume	esi:nothing
			invoke	CloseHandle,@hfileMap			
			invoke	CreateFile,addr szShellcode,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
			mov	hShellFile,eax
			nop
			;mov	edx,dwJmpOffset
			invoke	GetFileSize,hShellFile,NULL
			mov	@dwShellSize,eax
			
			invoke	ReadFile,hShellFile,addr lpShellBuffer,@dwShellSize,addr @dwFileTemp,NULL
			mov	ecx,@dwShellSize			
			mov	eax,90909090h
			cld
			lea	edi,lpShellBuffer
			push	edi
			repne	scasd
			pop	esi
			sub	edi,esi
			mov	dwJmpCalcOffset,edi
			nop
			invoke	SetFilePointer,hFile,@dwFile,NULL,FILE_BEGIN
			invoke	WriteFile,hFile,addr lpShellBuffer,dwJmpCalcOffset,addr @dwFileTemp,NULL
			;invoke	SetFilePointer,hFile,@dwFile+dwJmpOffset-1,NULL,FILE_BEGIN
			mov	eax,@dwOEP
			add	eax,dwImageBase
			mov	dwValue,eax	
			;mov	edx,@dwSec
			;add	edx,dwJmpOffset
			;invoke	_ResverValue
			lea	esi,dwValue
			lea	edi,lpJmpBuffer
			mov	byte ptr[edi],68h
			mov	byte ptr[edi+5],0c3h
			mov	ecx,4
			xor	ebx,ebx
		_lop:	
			mov	al,byte ptr[esi+ebx]
			mov	byte ptr[edi+ebx+1],al
			inc	ebx
			dec	ecx		
			jne	_lop			
			invoke	WriteFile,hFile,addr lpJmpBuffer,6,addr @dwFileTemp,NULL
			invoke	CloseHandle,@hfile
			popad
		ret
_addNewSection endp


;**********************************************************************************************
;判断路径中是否存在空格
;**********************************************************************************************
_IsPathWithBlanks proc uses esi ecx ebx lpFilePath
		mov	esi,lpFilePath
		invoke	lstrlen,esi
		xor	ebx,ebx
		mov	ecx,eax
	_loop:
		mov	al,byte ptr[esi+ebx]
		.if	al==20h
			mov	eax,1
			jmp	_exit
		.endif
		dec	ecx
		inc	ebx
		jne	_loop
		xor	eax,eax
	_exit:	
		ret

_IsPathWithBlanks endp


_RandomSecName	proc lpResult	
	pushad
	
	
	popad
	ret

_RandomSecName endp


_ProcDlgAddSection	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@SectionName[10]:byte
		LOCAL	@SectionSize[10]:byte
		LOCAL	@newFile[100]:byte
		LOCAL	fileName[100]:byte
		LOCAL	cmd1[100]:byte
		LOCAL	cmd2[100]:byte
		LOCAL	tempBuffer[100]:byte
		LOCAL	temp[100]:byte
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			invoke	CheckDlgButton,hWnd,3005,BST_CHECKED	
			invoke	SetDlgItemText,hWnd,3004, addr szStagedSize
			invoke	SetDlgItemText,hWnd,3003, addr szStagedSecName
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==3002
					invoke	EndDialog,hWnd,NULL
					
				.elseif	ax==3001
				
					invoke	GetDlgItemText,hWnd,3004,addr @SectionSize,sizeof @SectionSize
					.if	!eax
						invoke	MessageBox,hWnd,addr szEmptyError,addr szTitle,MB_OK
						jmp	_retry
					
					.elseif	eax>8
						invoke	MessageBox,hWnd,addr szInvaild,addr szTitle,MB_OK
						jmp	_retry
					.endif	
					invoke	IsDlgButtonChecked,hWnd,3005
					.if	eax==BST_CHECKED
						invoke	wsprintf,addr @newFile,addr szBakFileFmt,addr bufferFileName
						invoke	CopyFile,addr bufferFileName,addr @newFile,FALSE
					.endif
					invoke	_atoh,addr @SectionSize
					mov	dwSectionSize,eax
					invoke	GetDlgItemText,hWnd,3003,addr @SectionName,sizeof @SectionName
					invoke	_addNewSection,addr bufferFileName,addr @SectionName
					invoke	MessageBox,hWnd,addr addSectionSuccess,addr szTitle,MB_OK	
					invoke	EndDialog,hWnd,NULL
					
					invoke	GetModuleFileName,NULL,addr fileName,sizeof fileName
					invoke	_IsPathWithBlanks,addr fileName
					mov	ebx,eax
					invoke	_IsPathWithBlanks,addr szAppBuffer
					.if	(eax==1||ebx==1)
						invoke	GetShortPathName,addr fileName,addr cmd1,addr temp
						invoke	GetShortPathName,addr szAppBuffer,addr cmd2,addr temp
						invoke	ShellExecute,NULL,addr szOpen,addr cmd1,addr cmd2,NULL,SW_SHOWNORMAL
						invoke	ExitProcess,0
					.else
						invoke	ShellExecute,NULL,addr szOpen,addr fileName,addr szAppBuffer,NULL,SW_SHOWNORMAL
						invoke	ExitProcess,0
					.endif
				_retry:	
				
				.endif
			
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgAddSection	endp

_ProcDlgSectionView	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			invoke	GetDlgItem,hWnd,ListBox1
			mov	hListBox,eax		
			invoke	_getSectionView,hWnd
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==2001
				invoke	EndDialog,hWnd,NULL
				.elseif	ax==2003
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,300
				mov	hDlg3,eax
				invoke	DialogBoxParam,eax,300,NULL,offset _ProcDlgAddSection,NULL
				invoke	EndDialog,hWnd,NULL
				.endif
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret
_ProcDlgSectionView	endp

_ProcDlgImport	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@buffer[1000]:byte
		LOCAL	@temp[100]:byte
		LOCAL	@nBytes[40]:byte
		LOCAL	@temp2[100]:byte
		LOCAL	@temp3[100]:byte
		LOCAL	@temp4[100]:byte
		LOCAL	@temp5[100]:byte
		LOCAL	@hlistbox
		LOCAL	@tmp
		LOCAL	@hFile
		LOCAL	@nAPI
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
			
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			invoke	GetDlgItem,hWnd,4001
			mov	ebx,eax
			invoke	GetDlgItem,hWnd,4002
			invoke	_getImportTable,hWnd,ebx,eax
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==4000
					invoke	EndDialog,hWnd,NULL
					
				.elseif	ax==4003
					invoke	lstrcpy,addr @temp5,addr bufferFileName
					invoke lstrlen,addr @temp5
 					mov	ecx,eax
 					xor	ebx,ebx
 					inc	ecx
 					dec	ebx
 					xor	edx,edx
 					lea	esi,@temp5
 					xor	eax,eax
 				_loop:
 					inc	ebx
 					dec	ecx
 					cmp	byte ptr[esi+ebx],5Ch
 					je	_cmp
 					cmp	ecx,0
 					je	_exit
 					jmp	_loop
				_cmp:
					mov	edx,ebx
					cmp	ecx,0
					je	_exit
					jmp	_loop
				_exit:	
					mov	byte ptr[esi+edx],0h
					invoke	_getShortFileName,addr bufferFileName
					invoke	wsprintf,addr @temp2,addr szLogFmt,addr @temp5,addr szShortFileName
					invoke	CreateFile,addr @temp2,GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
					mov	@hFile,eax
					invoke	GetDlgItem,hWnd,4002
					mov	@hlistbox,eax
					invoke	SendMessage,eax,LB_GETCOUNT,0,0
					mov	@nAPI,eax
					xor	ebx,ebx
				_loop2:
					invoke	SendMessage,@hlistbox,LB_GETTEXT,ebx,addr @temp3
					invoke	lstrlen,addr @temp3
					mov	ecx,eax
					add	eax,2
					mov	@tmp,eax
					lea	esi,@temp3
					lea	edi,@temp4
					cld
					rep	movsb
					mov	byte ptr[edi],0dh
					mov	byte ptr[edi+1],0ah
					invoke	WriteFile,@hFile,addr @temp4,@tmp,addr @nBytes,NULL
					inc	ebx
					dec	@nAPI
					jne	_loop2
					invoke	wsprintf,addr @buffer,addr szLogSuccFmt,addr @temp2
					invoke	MessageBox,hWnd,addr @buffer,addr szTitle,MB_OK
					invoke	EndDialog,hWnd,NULL
					invoke	CloseHandle,@hFile			
				.endif
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret
_ProcDlgImport	endp


_ProcDlgExport	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@buffer[1000]:byte
		LOCAL	@temp[100]:byte
		LOCAL	@nBytes[40]:byte
		LOCAL	@temp2[100]:byte
		LOCAL	@temp3[100]:byte
		LOCAL	@temp4[100]:byte
		LOCAL	@temp5[100]:byte
		LOCAL	@hlistbox
		LOCAL	@tmp
		LOCAL	@hFile
		LOCAL	@nAPI
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
	
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			invoke	GetDlgItem,hWnd,5001
			mov	ebx,eax
			invoke	GetDlgItem,hWnd,5002
			invoke	_getExportTable,hWnd,ebx,eax
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==5004
					invoke	EndDialog,hWnd,NULL
					
				.elseif	ax==5003
					invoke	lstrcpy,addr @temp5,addr bufferFileName
					invoke lstrlen,addr @temp5
 					mov	ecx,eax
 					xor	ebx,ebx
 					inc	ecx
 					dec	ebx
 					xor	edx,edx
 					lea	esi,@temp5
 					xor	eax,eax
 				_loop:
 					inc	ebx
 					dec	ecx
 					cmp	byte ptr[esi+ebx],5Ch
 					je	_cmp
 					cmp	ecx,0
 					je	_exit
 					jmp	_loop
				_cmp:
					mov	edx,ebx
					cmp	ecx,0
					je	_exit
					jmp	_loop
				_exit:	
					mov	byte ptr[esi+edx],0h
					invoke	_getShortFileName,addr bufferFileName
					invoke	wsprintf,addr @temp2,addr szLogFmt2,addr @temp5,addr szShortFileName
					invoke	CreateFile,addr @temp2,GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
					mov	@hFile,eax
					invoke	GetDlgItem,hWnd,5002
					mov	@hlistbox,eax
					invoke	SendMessage,eax,LB_GETCOUNT,0,0
					mov	@nAPI,eax
					xor	ebx,ebx
				_loop2:
					invoke	SendMessage,@hlistbox,LB_GETTEXT,ebx,addr @temp3
					invoke	lstrlen,addr @temp3
					mov	ecx,eax
					add	eax,2
					mov	@tmp,eax
					lea	esi,@temp3
					lea	edi,@temp4
					cld
					rep	movsb
					mov	byte ptr[edi],0dh
					mov	byte ptr[edi+1],0ah
					invoke	WriteFile,@hFile,addr @temp4,@tmp,addr @nBytes,NULL
					inc	ebx
					dec	@nAPI
					jne	_loop2
					invoke	wsprintf,addr @buffer,addr szLogSuccFmt,addr @temp2
					invoke	MessageBox,hWnd,addr @buffer,addr szTitle,MB_OK
					invoke	EndDialog,hWnd,NULL
					invoke	CloseHandle,@hFile				
				.endif
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgExport	endp

_ProcDlgAbout	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
			
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==6002
				invoke	EndDialog,hWnd,NULL
				.endif
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgAbout	endp

_ProcDlgStringView	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@buffer[1000]:byte
		LOCAL	@temp[1000]:byte
		LOCAL	@nBytes[40]:byte
		LOCAL	@temp2[1000]:byte
		LOCAL	@temp3[1000]:byte
		LOCAL	@temp4[1000]:byte
		LOCAL	@temp5[1000]:byte
		LOCAL	@hlistbox
		LOCAL	@tmp
		LOCAL	@hFile
		LOCAL	@nStrings
		mov	eax,wMsg
		.if	eax == WM_CLOSE			
			invoke	EndDialog,hWnd,NULL
	
		.elseif	eax == WM_INITDIALOG
			invoke	_LoadSkin,hWnd
			invoke	GetDlgItem,hWnd,7001
			invoke	_getStringView,lpPeHeader,eax
			
			.elseif	eax == WM_COMMAND
			mov	eax,wParam
				.if	ax==7003
				invoke	EndDialog,hWnd,NULL
				.elseif	ax==7002
					invoke	lstrcpy,addr @temp5,addr bufferFileName
					invoke lstrlen,addr @temp5
 					mov	ecx,eax
 					xor	ebx,ebx
 					inc	ecx
 					dec	ebx
 					xor	edx,edx
 					lea	esi,@temp5
 					xor	eax,eax
 				_loop:
 					inc	ebx
 					dec	ecx
 					cmp	byte ptr[esi+ebx],5Ch
 					je	_cmp
 					cmp	ecx,0
 					je	_exit
 					jmp	_loop
				_cmp:
					mov	edx,ebx
					cmp	ecx,0
					je	_exit
					jmp	_loop
				_exit:	
					mov	byte ptr[esi+edx],0h
					invoke	_getShortFileName,addr bufferFileName
					invoke	wsprintf,addr @temp2,addr szLogFmt3,addr @temp5,addr szShortFileName
					invoke	lstrlen,addr @temp2
					mov	ecx,eax
					lea	esi,@temp2
					lea	edi,szDataOver
					cld
					rep	movsb
					invoke	CreateFile,addr @temp2,GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
					mov	@hFile,eax
					invoke	GetDlgItem,hWnd,7001
					mov	@hlistbox,eax
					invoke	SendMessage,eax,LB_GETCOUNT,0,0
					mov	@nStrings,eax
					xor	ebx,ebx
				_loop2:
					invoke	SendMessage,@hlistbox,LB_GETTEXT,ebx,addr @temp3
					invoke	lstrlen,addr @temp3
					mov	ecx,eax
					add	eax,2
					mov	@tmp,eax
					lea	esi,@temp3
					lea	edi,@temp4
					cld
					rep	movsb
					mov	byte ptr[edi],0dh
					mov	byte ptr[edi+1],0ah
					invoke	WriteFile,@hFile,addr @temp4,@tmp,addr @nBytes,NULL
					inc	ebx
					dec	@nStrings
					jne	_loop2
					invoke	wsprintf,addr @temp,addr szStringFmt,addr szDataOver
					invoke	MessageBox,hWnd,addr @temp,addr szTitle,MB_OK
					invoke	EndDialog,hWnd,NULL
					invoke	CloseHandle,@hFile				
				.endif
			.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret
_ProcDlgStringView	endp

_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		LOCAL	@dwDisp,@dwDisp2
		local	@dwFileSize,@hMapFile,@lpMemory
		LOCAL	@lpDumpAddr,@dwDumpSize
		LOCAL	@buffer[10]:byte
		LOCAL	@SectionName[16]:byte
		LOCAL	tempBuffer[40]:byte
		LOCAL	temp[20]:byte
		LOCAL	szIniFileBuffer[100]:byte
		LOCAL	lpDump[10]:byte
		LOCAL	lpOepBuffer[10]:byte
		LOCAL	lpDumpSize[10]:byte
		mov	eax,wMsg
				
		.if eax == WM_DROPFILES
			invoke SetForegroundWindow, hWnd
			invoke SendDlgItemMessage, hWnd, Text_Name, WM_SETTEXT, NULL, NULL	
			invoke DragQueryFile, wParam, 0, addr szAppBuffer, sizeof szAppBuffer
			invoke SetDlgItemText,hWnd,Text_Name,addr szAppBuffer
			invoke DragFinish, wParam
			lea	ebx,szAppBuffer
			jmp	_drag
			
		.elseif	eax == WM_CLOSE
			invoke	_Check
			invoke	CreateFile,addr IniFileBuffer,GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
			mov	hIniFile,eax
			invoke	IsDlgButtonChecked,hWnd,CheckBox1
			.if	eax==BST_CHECKED
			
				;**********************************************************************************************
				;设置总在最前	
				;**********************************************************************************************
				invoke	IsDlgButtonChecked,hWnd,CheckBox2
				.if	eax==BST_CHECKED	
					invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,5
					invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
				.elseif	eax==BST_UNCHECKED
					invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,1
					invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0	
				.endif
			.elseif	eax==BST_UNCHECKED
				invoke	IsDlgButtonChecked,hWnd,CheckBox2
				.if	eax==BST_CHECKED
					invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,3
					invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
				.elseif	eax==BST_UNCHECKED
					invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,6
					invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
				.endif
			.endif		
			invoke	CloseHandle,hIniFile
			invoke	ExitProcess,NULL
			
		.elseif	eax == WM_INITDIALOG
			;**********************************************************************************************
			;窗体初始化	
			;**********************************************************************************************
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_SMALL,eax
			invoke	_Check
			invoke	_LoadSkin,hWnd
			invoke	GetModuleFileName,NULL,addr lpFileName,sizeof lpFileName			
			invoke	CreateFile,addr IniFileBuffer,GENERIC_READ,FILE_SHARE_READ,0,OPEN_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
			mov	hIniFile,eax
			invoke	ReadFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
			xor	eax,eax
			lea	esi,szIniFileBuffer
			mov	al,byte ptr[esi]
			movzx	eax,al
			sub	eax,30h
			.if	eax==1
				invoke	CheckDlgButton,hWnd,CheckBox1,BST_CHECKED
			.elseif	eax==2
				invoke	CheckDlgButton,hWnd,CheckBox1,BST_UNCHECKED
			.elseif	eax==3
				invoke	CheckDlgButton,hWnd,CheckBox2,BST_CHECKED	
			.elseif	eax==4
				invoke	CheckDlgButton,hWnd,CheckBox2,BST_UNCHECKED
			.elseif	eax==5
				invoke	CheckDlgButton,hWnd,CheckBox1,BST_CHECKED
				invoke	CheckDlgButton,hWnd,CheckBox2,BST_CHECKED
				invoke	IsDlgButtonChecked,hWnd,CheckBox1
				.if	eax==BST_CHECKED
					invoke	SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.elseif	eax==BST_UNCHECKED
					invoke	SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.endif
			.elseif	eax==6
				invoke	CheckDlgButton,hWnd,CheckBox1,BST_UNCHECKED
				invoke	CheckDlgButton,hWnd,CheckBox2,BST_UNCHECKED	
				invoke	IsDlgButtonChecked,hWnd,CheckBox1
				.if	eax==BST_CHECKED
					invoke	SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.elseif	eax==BST_UNCHECKED
					invoke	SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.endif
			.endif
			invoke	CloseHandle,hIniFile
			invoke	_argc
			.if	eax>1
				invoke	_argv,1,addr szAppBuffer,sizeof szAppBuffer
				lea	ebx,szAppBuffer
				mov	flagAttach,1
				jmp	_drag
			.endif
	
		.elseif eax == WM_ACTIVATEAPP
			invoke SendDlgItemMessage, hWnd, Text_Name, EM_SETSEL, -1, 0	
			
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax==IDC_BUTTON2
				invoke	_Check
				invoke	CreateFile,addr IniFileBuffer,GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
				mov	hIniFile,eax
				invoke	IsDlgButtonChecked,hWnd,CheckBox1
				.if	eax==BST_CHECKED
					invoke	IsDlgButtonChecked,hWnd,CheckBox2
						.if	eax==BST_CHECKED	
						invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,5
						invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
					.elseif	eax==BST_UNCHECKED
					invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,1
					invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0	
					.endif
				.elseif	eax==BST_UNCHECKED
					invoke	IsDlgButtonChecked,hWnd,CheckBox2
					.if	eax==BST_CHECKED
						invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,3
						invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
					.elseif	eax==BST_UNCHECKED
						invoke	wsprintf,addr szIniFileBuffer,addr szWriteFmt,6
						invoke	WriteFile,hIniFile,addr szIniFileBuffer,1,addr tempBuffer,0
					.endif
				.endif		
			invoke	CloseHandle,hIniFile
			invoke	ExitProcess,NULL
		
			.elseif	ax==IDC_BUTTON4
				invoke	GetDlgItemText,hWnd,1006,addr lpOepBuffer,sizeof lpOepBuffer
				invoke	_atoh,addr lpOepBuffer
				.if	(eax>=baseCode)&&(eax<=lpLastSection)
					push	edi
					mov	edi,lpPeHeader
					assume	edi:ptr IMAGE_NT_HEADERS
					mov	[edi].OptionalHeader.AddressOfEntryPoint,eax
					assume	edi:nothing
					pop	edi
					invoke	MessageBox,hWnd,addr szChange0EPSuc,addr szTitle,MB_OK
				.elseif	(eax<baseCode)||(eax>lpLastSection)
					invoke	wsprintf,addr temp,addr szErrrSizeFmt,baseCode,lpLastSection
					invoke	MessageBox,hWnd,addr temp,addr szTitle,MB_OK
				.endif
				
			.elseif	ax==1023
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,200
				mov	hDlg2,eax
				invoke	DialogBoxParam,eax,200,NULL,offset _ProcDlgSectionView,NULL
			.elseif	ax==1024
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,300
				mov	hDlg3,eax
				invoke	DialogBoxParam,eax,300,NULL,offset _ProcDlgAddSection,NULL
					
			.elseif	ax==1025
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,500
				invoke	DialogBoxParam,eax,500,NULL,offset _ProcDlgExport,NULL	
				
			.elseif	ax==1027
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,400
				invoke	DialogBoxParam,eax,400,NULL,offset _ProcDlgImport,NULL
				
			.elseif	ax==1040
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,600
				invoke	DialogBoxParam,eax,600,NULL,offset _ProcDlgAbout,NULL	
			
			.elseif	ax==1026
				
				invoke	GetDlgItemText,hWnd,1029,addr lpDump,sizeof lpDump
				invoke	_atoh,addr lpDump
				mov	@lpDumpAddr,eax
				.if	(eax<baseCode)||(eax>lpLastSection)
					invoke	wsprintf,addr temp,addr szErrrSizeFmt,baseCode,lpLastSection
					invoke	MessageBox,hWnd,addr temp,addr szTitle,MB_OK
					jmp	_errorInput
				.endif
				invoke	GetDlgItemText,hWnd,1030,addr lpDumpSize,sizeof lpDumpSize
				.if	!eax
					invoke	MessageBox,hWnd,addr szErrorInput,addr szTitle,MB_ICONERROR
					jmp	_errorInput
				.endif
				invoke	_atoh,addr lpDumpSize
				mov	@dwDumpSize,eax
				invoke	_dumpFile,hWnd,@lpDumpAddr,@dwDumpSize
			
		_errorInput:
			.elseif	ax==1028
				invoke	GetModuleHandle,NULL
				invoke	GetDlgItem,eax,700
				invoke	DialogBoxParam,eax,700,NULL,offset _ProcDlgStringView,NULL		
				
			.elseif	ax==IDC_BUTTON3
				invoke	GetDlgItemText,hWnd,1019,addr dataBuffer3,sizeof dataBuffer3
				invoke	RtlZeroMemory,addr dataBuffer2,sizeof dataBuffer2
				invoke	_atoh,addr dataBuffer3
				mov	value,eax
				.if	(eax<baseCode)||(eax>lpLastSection)
					invoke	wsprintf,addr temp,addr szErrrSizeFmt,baseCode,lpLastSection
					invoke	MessageBox,hWnd,addr temp,addr szTitle,MB_OK
				.elseif	(eax>=baseCode)&&(eax<=lpLastSection)
					invoke	_RVAToOffset,lpFileHead,value
					invoke	wsprintf,addr temp,addr szHexFmt,eax
					invoke	SetDlgItemText,hWnd,TextBox_1020,addr temp
				.endif		
				
			.elseif	ax==CheckBox1
				invoke	IsDlgButtonChecked,hWnd,CheckBox1
				.if	eax==BST_CHECKED
					invoke	SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.elseif	eax==BST_UNCHECKED
					invoke	SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE
				.endif
				
			.elseif	ax==CheckBox2
				invoke	IsDlgButtonChecked,hWnd,CheckBox2
				.if	eax==BST_CHECKED
					;**********************************************************************************************
					;添加到系统右键菜单	
					;**********************************************************************************************
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegKey,NULL,KEY_CREATE_SUB_KEY,addr hKey
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegKey2,NULL,KEY_CREATE_SUB_KEY,addr hKey2
					invoke	RegCreateKeyEx,hKey,addr szRegName,NULL,NULL,NULL,NULL,NULL,addr hSubKey,addr @dwDisp
					invoke	RegCreateKeyEx,hKey2,addr szRegName,NULL,NULL,NULL,NULL,NULL,addr hSubKey3,addr @dwDisp2
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegSubKey,NULL,KEY_ALL_ACCESS, addr hSubKey
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegSubKey2,NULL,KEY_ALL_ACCESS, addr hSubKey3
					invoke	RegCreateKeyEx,hSubKey,addr szCommand,NULL,NULL,NULL,NULL,NULL,addr hSubKey2,addr @dwDisp
					invoke	RegCreateKeyEx,hSubKey3,addr szCommand,NULL,NULL,NULL,NULL,NULL,addr hSubKey4,addr @dwDisp2
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegPath,NULL,KEY_ALL_ACCESS, addr hSubKey2
					invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szRegPath2,NULL,KEY_ALL_ACCESS, addr hSubKey4
					invoke	wsprintf,addr szRegBuffer,addr szRegFmt,addr lpFileName
					invoke	wsprintf,addr szRegBuffer2,addr szRegFmt,addr lpFileName
					invoke	lstrcat,addr szRegBuffer,addr szTmp
					invoke	lstrcat,addr szRegBuffer2,addr szTmp
					invoke 	RegSetValueEx,hSubKey2,NULL,0,REG_SZ,addr szRegBuffer,sizeof szRegBuffer
					invoke 	RegSetValueEx,hSubKey4,NULL,0,REG_SZ,addr szRegBuffer2,sizeof szRegBuffer2
					invoke	MessageBox,hWnd,addr szRegMsgSuc,addr szTitle,MB_OK
					invoke 	RegCloseKey,hKey
					invoke 	RegCloseKey,hKey2
					invoke 	RegCloseKey,hSubKey
					invoke 	RegCloseKey,hSubKey3
					invoke 	RegCloseKey,hSubKey2
					invoke 	RegCloseKey,hSubKey4
				.elseif	eax==BST_UNCHECKED
					;**********************************************************************************************
					;从系统右键菜单取消	
					;**********************************************************************************************
					invoke 	RegDeleteKey,HKEY_LOCAL_MACHINE,addr szRegPath
					invoke 	RegDeleteKey,HKEY_LOCAL_MACHINE,addr szRegPath2
					invoke 	RegDeleteKey,HKEY_LOCAL_MACHINE,addr szRegSubKey
					invoke 	RegDeleteKey,HKEY_LOCAL_MACHINE,addr szRegSubKey2
					invoke	MessageBox,hWnd,addr szRegCancel,addr szTitle,MB_OK
				.endif	
			.elseif	ax==IDC_BUTTON1
		invoke	RtlZeroMemory,addr stOF,sizeof stOF
		mov	stOF.lStructSize,sizeof stOF
		push	hWnd
		pop	stOF.hwndOwner
		mov	stOF.lpstrFilter,offset szExtPe
		mov	ebx,offset szFileName
		mov	stOF.lpstrFile,ebx
		mov	stOF.nMaxFile,MAX_PATH
		mov	stOF.Flags,OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
		invoke	GetOpenFileName,addr stOF
		.if 	!eax
			invoke	MessageBox,hWnd,addr szErrorText,addr szTitle,MB_ICONERROR
			invoke	_disableButton,hWnd
			jmp 	@f
		.endif
		lea 	ebx,szFileName
	_drag:	
		invoke SetDlgItemText,hWnd,Text_Name,ebx
		mov	esi,ebx
		lea	edi,bufferFileName
		invoke	lstrlen,ebx
		mov	ecx,eax
		cld
		rep	movsb
		;**********************************************************************************************
		;判断是否有未关闭的文件句柄，是则关闭文件句柄
		;**********************************************************************************************
		.if	hFile
			invoke	UnmapViewOfFile,hMapMemory
			invoke	CloseHandle,hMap
			invoke	CloseHandle,hFile
		.endif
		invoke CreateFile,ebx,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
		.if 	eax==INVALID_HANDLE_VALUE
			invoke	MessageBox,hWnd,addr szErrorFileHandle,addr szTitle,MB_ICONERROR
			invoke	_disableAll,hWnd
			jmp 	_InvaidHandle
		.endif
		mov 	hFile,eax
		invoke	GetFileSize,hFile,NULL
		.if	!eax
			invoke	MessageBox,hWnd,addr szErrorFileEmpty,addr szTitle,MB_ICONERROR
			invoke	_disableAll,hWnd
			inc	FlagWrongPE
			jmp	@f
			
		.endif
		mov	ddFileSize,eax
		invoke 	CreateFileMapping,hFile,NULL,PAGE_READWRITE,0,0,NULL
		mov	@hMapFile,eax
		mov	hMap,eax
		invoke	MapViewOfFile,@hMapFile,FILE_MAP_ALL_ACCESS,0,0,0
		mov	@lpMemory,eax
		mov	hMapMemory,eax
		mov	dwVirtueSize,eax
		mov	esi,@lpMemory
		mov	lpFileHead,esi
		
		;**********************************************************************************************
		;判断PE文件是否正确	
		;**********************************************************************************************
		assume esi:ptr IMAGE_DOS_HEADER
		.if	([esi].e_magic)!=IMAGE_DOS_SIGNATURE
			invoke	MessageBox,hWnd,addr szErrorText,addr szTitle,MB_ICONERROR
			invoke	_disableAll,hWnd
			inc	FlagWrongPE
			jmp	@f
		.endif
		add	esi,[esi].e_lfanew	;指向PE文件头
		mov	lpPeHeader,esi
		assume	esi:ptr IMAGE_NT_HEADERS
		.if	([esi].Signature)!=IMAGE_NT_SIGNATURE
			invoke	MessageBox,hWnd,addr szErrorText,addr szTitle,MB_ICONERROR
			invoke	_disableAll,hWnd
			inc	FlagWrongPE
			jmp	@f
		.endif
		and	IsPacked,0
		invoke	_EnableText,hWnd
		invoke	_IsDataSection,lpPeHeader
		.if	IsPacked!=1
			invoke	MessageBox,hWnd,addr szPackedInfo,addr szTitle,MB_ICONWARNING
			invoke	_disableButton,hWnd
			invoke	GetDlgItem,hWnd,1023
			invoke	EnableWindow,eax,TRUE
			invoke	GetDlgItem,hWnd,1024
			invoke	EnableWindow,eax,TRUE
		.endif
		.if	eax==1
			invoke	GetDlgItem,hWnd,1028
			invoke	EnableWindow,eax,TRUE
		
		.elseif	eax==0
			invoke	GetDlgItem,hWnd,1028
			invoke	EnableWindow,eax,FALSE
		.endif
		invoke	_getSectionVaddr
		;**********************************************************************************************
		;获取基地址	ImageBase
		;**********************************************************************************************
		mov	eax,[esi].OptionalHeader.ImageBase
		mov	dwImageBase,eax
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1004,addr tempBuffer
		
		;**********************************************************************************************
		;获取文件大小		
		;**********************************************************************************************
		mov	eax,[esi].OptionalHeader.SizeOfImage
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1015,addr tempBuffer
		
		;**********************************************************************************************
		;获取数据目录表		
		;**********************************************************************************************
		mov	eax,[esi].OptionalHeader.DataDirectory.isize
		.if	!eax
			invoke	GetDlgItem,hWnd,1025
			invoke	EnableWindow,eax,FALSE
		.endif
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1008,addr tempBuffer
		mov	ebx,[esi].OptionalHeader.DataDirectory.VirtualAddress
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,ebx
		invoke	SetDlgItemText,hWnd,TextBox_1007,addr tempBuffer
		mov	eax,[esi+8].OptionalHeader.DataDirectory.isize
		.if	!eax
			invoke	GetDlgItem,hWnd,1027
			invoke	EnableWindow,eax,FALSE
		.endif
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1016,addr tempBuffer
		mov	ebx,[esi+8].OptionalHeader.DataDirectory.VirtualAddress
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,ebx
		invoke	SetDlgItemText,hWnd,TextBox_1014,addr tempBuffer
		mov	eax,[esi+16].OptionalHeader.DataDirectory.isize
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1018,addr tempBuffer
		mov	ebx,[esi+16].OptionalHeader.DataDirectory.VirtualAddress
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,ebx
		invoke	SetDlgItemText,hWnd,TextBox_1017,addr tempBuffer
		;**********************************************************************************************
		;获取代码入口点		AddressOfEntryPoint
		;**********************************************************************************************
		mov	eax,[esi].OptionalHeader.AddressOfEntryPoint
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1002,addr tempBuffer
		mov	eax,[esi].OptionalHeader.SizeOfImage
		mov	dwImageSize,eax
		;**********************************************************************************************
		;获取子系统	SUBSYSTEM
		;**********************************************************************************************
		movzx	eax,[esi].OptionalHeader.Subsystem
		.if	eax==0
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType0
		.elseif	eax==1
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType1
		.elseif	eax==2
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType2
		.elseif	eax==3
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType3
		.elseif	eax==5
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType5
		.elseif	eax==7
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType7
		.elseif	eax==8
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType8
		.elseif	eax==9
			invoke	SetDlgItemText,hWnd,TextBox_1010,addr SubSystemType9	
		.endif
		
		;**********************************************************************************************
		;获取节数目	SectionNumber
		;**********************************************************************************************
		movzx	ecx,[esi].FileHeader.NumberOfSections
		mov	SectionNum,ecx
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,ecx
		invoke	SetDlgItemText,hWnd,TextBox_1005,addr tempBuffer
		
		;**********************************************************************************************
		;获取节名称	SectionName
		;**********************************************************************************************

		add	esi,sizeof IMAGE_NT_HEADERS
		assume	esi:ptr IMAGE_SECTION_HEADER
		push	esi
		lea	edi,@SectionName
		cld	
		invoke	lstrlen,esi
		mov	ecx,eax
		rep	movsb
		mov	byte ptr[edi+ecx],0h
		invoke	SetDlgItemText,hWnd,TextBox_1009,addr @SectionName
	
		;**********************************************************************************************
		;获取代码实际大小		SIZEOF CODE
		;**********************************************************************************************
		pop	esi
		mov	eax,[esi].SizeOfRawData
		invoke	wsprintf,addr tempBuffer,addr szHexFmt,eax
		invoke	SetDlgItemText,hWnd,TextBox_1003,addr tempBuffer
		
		;**********************************************************************************************
		;结束前扫尾工作
		;**********************************************************************************************
	@@:	
		;**********************************************************************************************
		;判断是否是无效的PE文件，是则关闭文件句柄
		;**********************************************************************************************
		.if	FlagWrongPE
			invoke	UnmapViewOfFile,hMapMemory
			invoke	CloseHandle,hMap
			invoke	CloseHandle,hFile
			and	hFile,0
		.endif
_InvaidHandle:	
			.endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret
_ProcDlgMain	endp

;**********************************************************************************************
;主程序
;**********************************************************************************************
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,100,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
		end	start
