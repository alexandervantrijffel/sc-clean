.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \dev\softcentral\_asm\cleaner\string.inc
include \dev\softcentral\_asm\cleaner\resource.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\advapi32.inc
include \masm32\include\shell32.inc
include \masm32\include\ole32.inc
include \masm32\com\include\oaidl.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\ole32.lib

;***********************************************************************************
;							 Function definitions
;***********************************************************************************

ProgressDlgProc PROTO STDCALL :HWND,:UINT,:WPARAM,:LPARAM
CleanUp PROTO STDCALL
EnableAutoStart PROTO STDCALL :BOOL
EmptySpecialFolder PROTO STDCALL :DWORD,:DWORD
EmptyFolder PROTO STDCALL :DWORD,:DWORD
EmptyFolderImpl PROTO STDCALL :DWORD


;***********************************************************************************
;								  macro's
;***********************************************************************************


;---------------------------------------------------------------------
; coinvoke MACRO 
;
; invokes an arbitrary COM interface 
;
; revised 12/29/00 to check for edx as a param and force compilation error
;                   (thanks to Andy Car for a how-to suggestion)
; revised 7/18/00 to pass pointer in edx (not eax) to avoid confusion with
;   parmas passed with ADDR  (Jeremy Collake's excellent suggestion)
; revised 5/4/00 for member function name decoration
; see http://ourworld.compuserve.com/homepages/ernies_world/coinvoke.htm
;
; pInterface    pointer to a specific interface instance
; Interface     the Interface's struct typedef
; Function      which function or method of the interface to perform
; args          all required arguments 
;                   (type, kind and count determined by the function)
;
coinvoke MACRO pInterface:REQ, Interface:REQ, Function:REQ, args:VARARG
    LOCAL istatement, arg
    FOR arg, <args>     ;; run thru args to see if edx is lurking in there
        IFIDNI <&arg>, <edx>
            .ERR <edx is not allowed as a coinvoke parameter>
        ENDIF
    ENDM
    istatement CATSTR <invoke (Interface PTR[edx]).&Interface>,<_>,<&Function, pInterface>
    IFNB <args>     ;; add the list of parameter arguments if any
        istatement CATSTR istatement, <, >, <&args> 
    ENDIF 
    mov edx, pInterface
    mov edx, [edx]
    istatement
ENDM

RGB macro red,green,blue 
    xor    eax,eax 
    mov  ah,blue 
    shl     eax,8 
    mov  ah,green 
    mov  al,red 
endm 


.data
szAppName db "SC-Cleaner",0
szRunKey db "Software\Microsoft\Windows\CurrentVersion\Run",0
szAutoStartFailed db "Unable to register application for autostartup.",0
szCmdLineCleanArg db " -s",0
szSearchAll db "\*.*",0

szfmtFullPath db "\%s",0
szfmtFilesDeleted db "SC-Clean finished. Files deleted: %d",0
szfmtEmptyDesc db "Cleaning %s...",0

szEmptyDescTempPath db "Temporary Files",0
szEmptyDescCookies db "Internet Explorer Cookies",0
szEmptyDescHistory db "Internet Explorer History",0
szEmptyDescIETempPath db "Internet Explorer Temporary Files",0
szEmptyDescRecentFiles db "Shortcuts to Recent Files",0

.data?
hInstance dd ?
lpCmdLine dd ?
hProgressDlg dd ?
FilesDeleted dd ?
szBuf db MAX_PATH+5 dup (?)
szEmptyDesc db MAX_PATH dup (?)
szProgressFile db MAX_PATH dup (?)
Msg dd ?

.code
start:

	invoke Sleep,60000

	invoke GetModuleHandle,NULL
	mov hInstance,eax
	
	invoke GetCommandLine
	mov lpCmdLine,eax
	
	invoke EnableAutoStart,1
	invoke CleanUp
	
@@:	invoke GetMessage,OFFSET Msg,0,0,0
	test eax,eax
	jz @F

	invoke TranslateMessage,OFFSET Msg
	invoke DispatchMessage, OFFSET Msg
	jmp @B

@@:	invoke ExitProcess,0


ProgressDlgProc Proc STDCALL hWndDlg:HWND, nMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL rc:RECT
	LOCAL rc2:RECT

	mov eax,nMsg
	.IF eax == WM_COMMAND
		mov eax,wParam										; wID = LOWORD(wParam)
		.IF ax == IDC_PROGRESS_STOP							; so wID = in ax
			invoke EndDialog,hWndDlg,0
			invoke PostQuitMessage,0
		.ENDIF
	
	.ELSEIF eax == WM_CTLCOLORSTATIC || eax == WM_CTLCOLORDLG
;			invoke GetDlgCtrlID,lParam
;			.IF eax == IDC_MAIN_PATH
;				invoke GetWindowLong,lParam,GWL_STYLE
;				test eax,ES_READONLY						; preserve the gray background
;				jz Return									; if the edit box is disabled
;			.ENDIF
		.IF eax == WM_CTLCOLORSTATIC
			invoke SetBkMode,wParam,TRANSPARENT
			RGB 255,255,255
			invoke SetTextColor,wParam,eax
		.ENDIF

		RGB 132,138,198
		invoke CreateSolidBrush,eax
		ret
	
	.ELSEIF eax == WM_TIMER
		invoke EndDialog,hWndDlg,0
		invoke PostQuitMessage,0

	.ELSEIF eax==WM_LBUTTONDOWN
		call ReleaseCapture
		invoke SendMessage,hWndDlg,WM_NCLBUTTONDOWN, HTCAPTION,0

;	.ELSEIF eax == WM_NCHITTEST
;		invoke DefWindowProc,hWndDlg,eax,wParam,lParam
;		.IF eax==HTCLIENT
;			mov eax, HTCAPTION
;		.ENDIF

	.ELSEIF eax == WM_INITDIALOG
		invoke LoadImage,hInstance,IDI_STOP,IMAGE_ICON,16,16,0
		push eax
		push IMAGE_ICON
		push BM_SETIMAGE
		invoke GetDlgItem,hWndDlg,IDC_PROGRESS_STOP
		push eax
		call SendMessage
				
;		invoke SetWindowPos,hWndDlg,HWND_TOPMOST,hz,vert,0,0,SWP_NOSIZE|SWP_NOZORDER

		mov eax,SWP_NOSIZE
		push eax
		push 0
		push 0
		invoke GetWindowRect,hWndDlg,ADDR rc
		invoke SystemParametersInfo,SPI_GETWORKAREA,0,ADDR rc2,0
		mov ecx,rc2.bottom
		sub ecx,rc.bottom
		add ecx,rc.top
		sub ecx,50
		push ecx
		mov ecx,rc2.right
		sub ecx,rc.right
		add ecx,rc.left
		sub ecx,75
		push ecx
		push HWND_TOPMOST
		push hWndDlg
		call SetWindowPos

;		invoke GetWindowLong,hWndDlg,GWL_EXSTYLE
;		mov ecx,WS_EX_APPWINDOW
;		not ecx
;		and eax,ecx
;		invoke SetWindowLong,hWndDlg,GWL_EXSTYLE,eax
	.ELSE
		xor eax,eax
		ret
	.ENDIF

	xor eax,eax
	ret

ProgressDlgProc endp

CleanUp Proc STDCALL
	mov FilesDeleted,0

	invoke CreateDialogParam,hInstance,IDD_PROGRESS,0,ADDR ProgressDlgProc,0
	mov hProgressDlg,eax

	invoke CoInitialize,0

	invoke EmptySpecialFolder,ADDR szEmptyDescCookies,CSIDL_COOKIES
	invoke EmptySpecialFolder,ADDR szEmptyDescHistory,CSIDL_HISTORY
	invoke EmptySpecialFolder,ADDR szEmptyDescIETempPath,CSIDL_INTERNET_CACHE
	invoke EmptySpecialFolder,ADDR szEmptyDescRecentFiles,CSIDL_RECENT

	invoke GetTempPath,MAX_PATH,ADDR szBuf
	invoke EmptyFolder,ADDR szEmptyDescTempPath,ADDR szBuf
	invoke CoUninitialize
	
	invoke wsprintf,ADDR szBuf,ADDR szfmtFilesDeleted,FilesDeleted
	invoke SetDlgItemText,hProgressDlg,IDC_PROGRESS_TEXT,ADDR szBuf
	
	mov ebx,OFFSET szBuf
	mov BYTE PTR[ebx],0
	invoke SetDlgItemText,hProgressDlg,IDC_PROGRESS_FILE,ebx
	
	invoke SetTimer,hProgressDlg,0,5000,0
;	invoke DestroyWindow,hProgressDlg
	ret
CleanUp endp

EmptySpecialFolder Proc STDCALL lpDesc:DWORD,nFolder:DWORD

	LOCAL lpMalloc:DWORD
	LOCAL pidl:DWORD

	invoke SHGetMalloc,ADDR lpMalloc
	cmp eax,1
	ja @F
	
	invoke SHGetSpecialFolderLocation,0,nFolder,ADDR pidl
	cmp eax,1
	ja @F
	
	invoke SHGetPathFromIDList,pidl,ADDR szBuf
	invoke EmptyFolder,lpDesc,ADDR szBuf

	coinvoke lpMalloc,IMalloc,Free,pidl
	coinvoke lpMalloc,IMalloc,Release
	
@@:	ret

EmptySpecialFolder endp
	
EmptyFolder Proc STDCALL lpDesc:DWORD,lpFolder:DWORD
	invoke wsprintf,ADDR szEmptyDesc, ADDR szfmtEmptyDesc, lpDesc
	invoke SetDlgItemText,hProgressDlg,IDC_PROGRESS_TEXT,ADDR szEmptyDesc
	invoke EmptyFolderImpl,lpFolder
	ret

EmptyFolder endp

EmptyFolderImpl Proc STDCALL lpFolder:DWORD
	LOCAL msg:MSG
	LOCAL fd:WIN32_FIND_DATA
	LOCAL hFind:HANDLE
	
	mov ebx,lpFolder						; search for end of string
@@:	inc ebx									
	cmp BYTE PTR[ebx],0
	jnz @B

	invoke lstrcpy,ebx,ADDR szSearchAll		; append \*.* to folder

	invoke FindFirstFile,lpFolder,ADDR fd
	mov BYTE PTR[ebx],0						; remove \*.*
	mov hFind,eax

	cmp eax,INVALID_HANDLE_VALUE
	jnz @F

	xor eax,eax
	ret
	
@@:	.IF fd.cFileName != '.'
		invoke wsprintf,ebx,ADDR szfmtFullPath,ADDR fd.cFileName
		invoke GetFileAttributes,lpFolder
		mov edx,FILE_ATTRIBUTE_READONLY
		.IF eax & edx
			not edx
			and edx,eax
			invoke SetFileAttributes,lpFolder,edx
			mov eax,edx						; restore fileattributes in eax for next instruction
		.ENDIF	
		
		.IF eax & FILE_ATTRIBUTE_DIRECTORY
			push ebx						; save the pointer to the end of the folderstring
			invoke EmptyFolderImpl,lpFolder		; because EmptyFolder will inc it
			invoke RemoveDirectory,lpFolder
			pop ebx							; retrieve ebx (<>)
		.ELSE
			invoke DeleteFile,lpFolder
			.IF eax != 0
				inc FilesDeleted	
			.ENDIF

			invoke lstrlen,lpFolder
			.IF eax > 50
				push ebx

				mov ecx,lpFolder
				add ecx,eax
				sub ecx,46

				mov ebx,OFFSET szProgressFile
				mov BYTE PTR[ebx],'C'
				inc ebx
				mov BYTE PTR[ebx],':'
				inc ebx
				mov BYTE PTR[ebx],'\'
				inc ebx
				mov BYTE PTR[ebx],'.'
				inc ebx
				mov BYTE PTR[ebx],'.'
				inc ebx
				mov BYTE PTR[ebx],'.'

;				invoke lstrncpy,ebx,lpFolder,6
;				add ebx,6
;				invoke lstrcpy,ebx,ADDR szDots
;				add ebx,3

				invoke lstrcpy,ebx,ecx
				mov eax,OFFSET szProgressFile

				pop ebx
			.ELSE
				mov eax,lpFolder
			.ENDIF
			
			invoke SetDlgItemText,hProgressDlg,IDC_PROGRESS_FILE,eax
		.ENDIF
		 
		 mov BYTE PTR[ebx],0				; (<>) so that we can end lpFolder at the correct pos
	.ENDIF

	invoke FindNextFile,hFind,ADDR fd
	test eax,eax
	jnz @B
	
	invoke FindClose,hFind
	ret
EmptyFolderImpl endp


EnableAutoStart Proc STDCALL bEnable:BOOL
	LOCAL hKey:DWORD
	invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,ADDR szRunKey\
			,0,KEY_WRITE,ADDR hKey
	test eax,eax
	jnz @F

	.IF !bEnable
		invoke RegDeleteValue,hKey,ADDR szAppName
	.ELSE
		invoke GetModuleFileName,0,ADDR szBuf,MAX_PATH
		test eax,eax
		jz @F

		invoke lstrcat,ADDR szBuf,ADDR szCmdLineCleanArg
		invoke StrLen,ADDR szBuf
		inc eax
		mov ebx,eax
		invoke RegSetValueEx,hKey,ADDR szAppName,0,REG_SZ\
				, ADDR szBuf, ebx
		test eax,eax
		jnz @F
	.ENDIF

	invoke RegCloseKey,hKey
	ret

@@:	invoke MessageBox,0,ADDR szAutoStartFailed,ADDR szAppName,MB_ICONEXCLAMATION
	ret

EnableAutoStart endp

end start

