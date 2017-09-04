IFNDEF  SKINMAGICTRIAL_INC
SKINMAGICTRIAL_INC equ <1>

;Skinmagic error code
SMEC_OK                                  equ 0
SMEC_REGISTERWINDOW	        equ 1    ;fail to register windows class
SMEC_MESSAGEHOOK                equ 2    ;fail to set message hook    
SMEC_KEYHOOK				                equ 3	;fail to set keyboard hook  
SMEC_FILENOTFOUND                equ 4    ;not find the file
SMEC_DECOMPRESSERROR        equ 5    ;fail to decompress skin file 
SMEC_HEADERERROR                 equ 6    ;skin file header error
SMEC_SKINVERSIONERROR         equ 7    ;skin file version not match 
SMEC_OBJECTNOTFOUND           equ 8    ;obect not found
SMEC_OBJECTTYPEUNMATCH      equ 9    ;Object type not match
SMEC_IMAGESIZEERROR             equ 10   ;Image size error
SMEC_CREATEIMAGELISTFAIL     equ 11   ;fail to create image list object 
SMEC_NOTIMPLEMENT                equ 12   ;The function not implement
SMEC_PARAMETERERROR           equ 13   ;the function parameter error 
SMEC_INITSCROLLBARFAIL          equ 14   ;fail to skin scrollbar
SMEC_LOADRESOURCEFAIL         equ 15   ;fail to load the resource
SMEC_FINDRESOURCEFAIL          equ 16   ;fail to find the resource
SMEC_WINDOWSXPNOTCOMPATIBLE  equ 17   ;not compatible with Windows XP
SMEC_OUTOFMEMORY               equ 18   ;Out of memory
SMEC_LIBARAYNOTINITIALIZED   equ 19   ;Library not initialized

WM_SKINDATACHANGED     equ WM_USER + 1
WM_SETSKIN                     equ WM_APP  + 1000

CPBS_HOVERED     equ 00000000
CPBS_PRESSED     equ 00000001
CPBS_DISABLED    equ 00000002
CPBS_NORMAL		 equ 00000003

MENUIMAGEINFO struct
	itemID DWORD ?
	iImage DWORD ?
MENUIMAGEINFO ends

;Functions List
InitSkinMagicLib PROTO :DWORD,:DWORD,:DWORD,:DWORD
ExitSkinMagicLib PROTO
LoadSkinFile PROTO :DWORD
LoadSkinFromResource PROTO :DWORD,:DWORD,:DWORD
SetWindowSkin PROTO :DWORD,:DWORD
SetShapeWindowSkin PROTO :DWORD,:DWORD
RemoveWindowSkin PROTO :DWORD
SetDialogSkin PROTO :DWORD
SetSingleDialogSkin PROTO :DWORD,:DWORD
RemoveDialogSkin PROTO
EnableWindowScrollbarSkin PROTO :DWORD,:DWORD
DisableWindowScrollbarSkin PROTO :DWORD
TrackSkinPopupMenu PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
EnableCaptionButtons PROTO :DWORD,:DWORD,:DWORD

RegisterSkinWindow PROTO :DWORD,:DWORD
UnregisterSkinWindow PROTO :DWORD

OpenSkinData PROTO :DWORD
CloseSkinData PROTO :DWORD

;stocked property for every custom control
GetSkinControlRect PROTO :DWORD,:DWORD,:DWORD
GetSkinControlID PROTO :DWORD,:DWORD
GetSkinControlFont PROTO :DWORD,:DWORD,:DWORD
GetSkinControlColor PROTO :DWORD,:DWORD
GetSkinControlBkColor PROTO :DWORD,:DWORD
GetSkinTransparentColor PROTO :DWORD,:DWORD

;user customed property                     
GetSkinFont PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetSkinColor PROTO :DWORD,:DWORD,:DWORD
GetSkinBool PROTO :DWORD,:DWORD,:DWORD
GetSkinInt PROTO :DWORD,:DWORD,:DWORD
GetSkinDWORD PROTO :DWORD,:DWORD,:DWORD
GetSkinEnum PROTO :DWORD,:DWORD,:DWORD
GetSkinString PROTO :DWORD,:DWORD,:DWORD,:DWORD

DrawSkinImageRect PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawSkinImageSection PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawSkinImageSectionFrame PROTO :DWORD,:DWORD,:DWORD,:DWORD

GetSkinImageSectionMargins PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateSkinImageRectRegion PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateSkinImageSectionRegion PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawSkinTextEffect PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateImageList PROTO :DWORD

SetWindowMainMenuImage PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TrackSkinPopupMenuEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RedrawCaptionStatic PROTO :DWORD,:DWORD
GetSkinMagicErrorCode PROTO
GetSkinMenu PROTO :DWORD
SetSkinMenu PROTO :DWORD,:DWORD

GetCaptionButtonState PROTO :DWORD,:DWORD,:DWORD
SetCaptionButtonState PROTO :DWORD,:DWORD,:DWORD
SetSkinWindowAccelerator  PROTO :DWORD,:DWORD
SetControlTooltip PROTO :DWORD,:DWORD
SetCaptionButtonTooltip PROTO :DWORD,:DWORD,:DWORD
ShowTooltipPoint PROTO :DWORD,:DWORD,:DWORD
HideTooltip PROTO
SetControlSkin PROTO :DWORD,:DWORD,:DWORD
GetSkinSysColor PROTO :DWORD
GetSkinSysColorBrush PROTO :DWORD

ELSE
echo -----------------------------------------
echo WARNING Duplicate include file skinmagictrial.inc
echo -----------------------------------------
ENDIF