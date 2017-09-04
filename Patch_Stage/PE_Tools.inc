;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 3rd Edition>
; by ���Ʊ�, http://www.win32asm.com.cn
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _CmdLine.asm
; �����в���������ͨ���ӳ���
; ���ܣ�
; _argc ---> �������в�����������ͳ��
; _argv ---> ȡĳ�������в���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CHAR_BLANK	equ	20h	;����ո�
CHAR_DELI	equ	'"'	;����ָ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ȡ�����в������� (arg count)
; ���������ض����ڵ��� 1, ���� 1 Ϊ��ǰִ���ļ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argc		proc
		local	@dwArgc

		pushad
		mov	@dwArgc,0
		invoke	GetCommandLine
		mov	esi,eax
		cld
_argc_loop:
;********************************************************************
; ���Բ���֮��Ŀո�
;********************************************************************
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_BLANK
		jz	_argc_loop
;********************************************************************
; һ��������ʼ
;********************************************************************
		dec	esi
		inc	@dwArgc
_argc_loop1:
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_BLANK
		jz	_argc_loop		;��������
		cmp	al,CHAR_DELI
		jnz	_argc_loop1		;����������������
;********************************************************************
; ���һ�������е�һ�����пո�,���� " " ����
;********************************************************************
		@@:
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_DELI
		jnz	@B
		jmp	_argc_loop1
_argc_end:
		popad
		mov	eax,@dwArgc
		ret

_argc		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ȡָ��λ�õ������в���
;  argv 0 = ִ���ļ���
;  argv 1 = ����1 ...
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argv		proc	_dwArgv,_lpReturn,_dwSize
		local	@dwArgv,@dwFlag

		pushad
		inc	_dwArgv
		mov	@dwArgv,0
		mov	edi,_lpReturn

		invoke	GetCommandLine
		mov	esi,eax
		cld
_argv_loop:
;********************************************************************
; ���Բ���֮��Ŀո�
;********************************************************************
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_BLANK
		jz	_argv_loop
;********************************************************************
; һ��������ʼ
; �����Ҫ��Ĳ�������,��ʼ���Ƶ����ػ�����
;********************************************************************
		dec	esi
		inc	@dwArgv
		mov	@dwFlag,FALSE
		mov	eax,_dwArgv
		cmp	eax,@dwArgv
		jnz	@F
		mov	@dwFlag,TRUE
		@@:
_argv_loop1:
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_BLANK
		jz	_argv_loop		;��������
		cmp	al,CHAR_DELI
		jz	_argv_loop2
		cmp	_dwSize,1
		jle	@F
		cmp	@dwFlag,TRUE
		jne	@F
		stosb
		dec	_dwSize
		@@:
		jmp	_argv_loop1		;����������������

_argv_loop2:
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_DELI
		jz	_argv_loop1
		cmp	_dwSize,1
		jle	@F
		cmp	@dwFlag,TRUE
		jne	@F
		stosb
		dec	_dwSize
		@@:
		jmp	_argv_loop2
_argv_end:
		xor	al,al
		stosb
		popad
		ret

_argv		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 3rd Edition>
; by ���Ʊ�, http://www.win32asm.com.cn
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szNotFound	db	'�޷�����',0
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �� RVA ת����ʵ�ʵ�����λ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RVAToOffset	proc	_lpFileHead,_dwRVA
		local	@dwReturn

		pushad
		mov	esi,_lpFileHead
		assume	esi:ptr IMAGE_DOS_HEADER
		add	esi,[esi].e_lfanew
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	edi,_dwRVA
		mov	edx,esi
		add	edx,sizeof IMAGE_NT_HEADERS
		assume	edx:ptr IMAGE_SECTION_HEADER
		movzx	ecx,[esi].FileHeader.NumberOfSections
;********************************************************************
; ɨ��ÿ���������ж� RVA �Ƿ�λ�����������
;********************************************************************
		.repeat
			mov	eax,[edx].VirtualAddress
			add	eax,[edx].SizeOfRawData		;eax = Section End
			.if	(edi >= [edx].VirtualAddress) && (edi < eax)
				mov	eax,[edx].VirtualAddress ;eax= Section start
				sub	edi,eax			;edi = offset in section
				mov	eax,[edx].PointerToRawData
				add	eax,edi			;eax = file offset
				jmp	@F
			.endif
			add	edx,sizeof IMAGE_SECTION_HEADER
		.untilcxz
		assume	edx:nothing
		assume	esi:nothing
		mov	eax,-1
@@:
		mov	@dwReturn,eax
		popad
		mov	eax,@dwReturn
		ret

_RVAToOffset	endp
