;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2017
;
; APISearch.asm
;
;-------------------------------------------------------------------------------------
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

;DEBUG64 EQU 1

IFDEF DEBUG64
    PRESERVEXMMREGS equ 1
    includelib \JWasm\lib\x64\Debug64.lib
    DBG64LIB equ 1
    DEBUGEXE textequ <'\Jwasm\bin\DbgWin.exe'>
    include \JWasm\include\debug64.inc
    .DATA
    RDBG_DbgWin	DB DEBUGEXE,0    
ENDIF


Include x64dbgpluginsdk.inc               ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

Include APISearch.inc                   ; plugin's include file

pluginit	        PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO                   ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
align 01
PLUGIN_NAME         DB "APISearch",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
align 08

PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DQ ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?


;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hInst:HINSTANCE, fdwReason:DWORD, lpvReserved:LPVOID
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov rax, hInst
        mov hInstance, rax
    .ENDIF
    mov rax,TRUE
    ret
DllMain Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp64 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC FRAME USES RBX initStruct:QWORD
    mov rbx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [rbx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [rbx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [rbx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov rbx, initStruct
    mov eax, [rbx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    ; Do any other initialization here

	mov rax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp64 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC FRAME
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC FRAME USES RBX setupStruct:QWORD
    LOCAL hIconData:ICONDATA

    mov rbx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov rax, [rbx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, rax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_GOOGLE, Addr szMenuSearchGoogle
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_MSDN, Addr szMenuSearchMSDN
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_PINVOKE, Addr szMenuSearchPinvoke

    Invoke APISearchLoadMenuIcon, IMG_APISEARCH, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuseticon, hMenuDisasm, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHGOOGLE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_GOOGLE, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHMSDN, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_MSDN, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHPINVOKE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_PINVOKE, Addr hIconData
    .ENDIF
    
    ; register commands for searching google, msdn and pinvoke
    Invoke _plugin_registercommand, pluginHandle, Addr szGoogle, Addr cbSearchGoogle, FALSE
    Invoke _plugin_registercommand, pluginHandle, Addr szMSDN, Addr cbSearchMSDN, FALSE
    Invoke _plugin_registercommand, pluginHandle, Addr szPinvoke, Addr cbSearchPinvoke, FALSE

    Invoke GuiAddLogMessage, Addr szAPISearchInfo        
    mov rax,TRUE
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    mov rbx, cbInfo
    xor rax, rax
    mov eax, [rbx].PLUG_CB_MENUENTRY.hEntry
    
    ;PrintDWORD eax
    
    .IF rax == MENU_SEARCH_GOOGLE
        Invoke SearchForAPIKeyword, 0 ;testDisasm
    
    .ELSEIF rax == MENU_SEARCH_MSDN
        Invoke SearchForAPIKeyword, 1 ;testDisasm
    
    .ELSEIF rax == MENU_SEARCH_PINVOKE
        Invoke SearchForAPIKeyword, 2 ; pinvoke
    .ENDIF    
    mov rax,TRUE
    ret
CBMENUENTRY endp


;=====================================================================================
; Search Google
;-------------------------------------------------------------------------------------
cbSearchGoogle PROC FRAME USES RBX argc:QWORD, argv:QWORD
    LOCAL dwSearchTerm:QWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningGoogle
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleHomeAddress
    .ELSE
        mov rbx, argv
        add rbx, 8d ; argv +1
        mov rax, [rbx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, rax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szGoogleSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov rax,TRUE
    ret
cbSearchGoogle endp


;=====================================================================================
; Search MSDN
;-------------------------------------------------------------------------------------
cbSearchMSDN PROC FRAME USES RBX argc:QWORD, argv:QWORD
    LOCAL dwSearchTerm:QWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningMSDN
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNHomeAddress
    .ELSE
        mov rbx, argv
        add rbx, 8d ; argv +1
        mov rax, [rbx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, rax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szMSDNSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov rax,TRUE
    ret
cbSearchMSDN endp


;=====================================================================================
; Search Pinvoke
;-------------------------------------------------------------------------------------
cbSearchPinvoke PROC FRAME USES RBX argc:QWORD, argv:QWORD
    LOCAL dwSearchTerm:QWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningPinvoke
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeHomeAddress
    .ELSE
        mov rbx, argv
        ;mov rax, [rbx]
        ;Invoke MessageBox, hwndDlg, Addr szMenuPlugin1, rax, MB_OK
        
        add rbx, 8d ; argv +1
        mov rax, [rbx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, rax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szPinvokeSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szPinvokeNamespace
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        Invoke lstrcat, Addr szWebSearchKeyword, Addr szPinvokeNamespace
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov rax,TRUE
    ret
cbSearchPinvoke endp


;=====================================================================================
; Search online for API keyword using specified search provider
;-------------------------------------------------------------------------------------
SearchForAPIKeyword PROC FRAME USES RBX RDI RSI dwSearchProvider:QWORD ; google = 0, msdn = 1, pinvoke = 3
    LOCAL sel:SELECTIONDATA
    LOCAL lenDisasmText:DWORD
    ;LOCAL tester:DWORD
    
    ;PrintText 'SearchForAPIKeyword'
    
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    Invoke GuiGetDisassembly, sel.start, Addr szDisasmText
    
    ;PrintString szDisasmText
    
    ;lea eax, szDisasmText
    ;DumpMem eax, 100
    ;mov eax, 28d
    ;PrintDec eax
    ;mov dwTester1, 27d
    ;PrintDec dwTester1
    ;mov eax, dwTester1
    ;mov DbgVar, eax
    ;PrintDec DbgVar
    ;mov tester, 26d
    ;PrintDec tester
    
    Invoke lstrlen, Addr szDisasmText
    mov lenDisasmText, eax

    lea rbx, szDisasmText
    mov eax, dword ptr [rbx]
    .IF eax == 'llac' ; good to go
        ;PrintDec eax
        ; strip out call and <> brackets and @ param stuff
        
        lea rsi, szDisasmText
        lea rdi, szAPISearchKeyword
        
        movzx eax, byte ptr [rsi]
        .WHILE al != '.' && al != '&' ; 64bit have & in the api calls, so to check for that as well
            .IF al == 0h
                Invoke GuiAddLogMessage, Addr szCouldNotFindAPI
                mov rax, FALSE
                ret
            .ENDIF
            inc rsi
            movzx eax, byte ptr [rsi]
        .ENDW

        inc rsi ; jump over the . and the first _ if its there
        movzx rax, byte ptr [rsi]
        .IF al == '_'
            inc rsi
        .ENDIF
        
        movzx eax, byte ptr [rsi]
        .WHILE al != '@' && al != '>'
            .IF al == 0h
                Invoke GuiAddLogMessage, Addr szCouldNotFindAPI
                mov rax, FALSE
                ret
            .ENDIF
            mov byte ptr [rdi], al
            inc rdi
            inc rsi
            movzx eax, byte ptr [rsi]
        .ENDW
        mov byte ptr [rdi], 0h ; null out string
        
        ; check if 2nd last byte was lowercase, if so if the last byte is 'A' or 'W' we strip that off - ansi/unicode part
        dec rdi
        dec rdi
        movzx eax, byte ptr [rdi]
        .IF al >= 'a' && al <= 'z'
            inc rdi
            movzx eax, byte ptr [rdi]
            .IF al == 'A' || al == 'W'
                mov byte ptr [rdi], 0h ; null out string
            .ENDIF
        .ENDIF 
        
        Invoke lstrcpy, Addr szLogMsg, Addr szSearchingForAPI
        Invoke lstrcat, Addr szLogMsg, Addr szAPISearchKeyword
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        .IF dwSearchProvider == 0
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleSearchUrl
        
        .ELSEIF dwSearchProvider == 1
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNSearchUrl
        
        .ELSEIF dwSearchProvider == 2
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeSearchUrl
        .ENDIF
        Invoke lstrcat, Addr szWebSearchKeyword, Addr szAPISearchKeyword
        
        .IF dwSearchProvider == 2
            Invoke lstrcat, Addr szWebSearchKeyword, Addr szPinvokeNamespace
        .ENDIF
        
        Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
        mov rax, TRUE
    .ELSE
        Invoke GuiAddLogMessage, Addr szCanOnlySearchForAPI
        ret
    .ENDIF
    ret
SearchForAPIKeyword endp


;=====================================================================================
; APISearchLoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
APISearchLoadMenuIcon PROC FRAME USES RBX dqImageResourceID:QWORD, lpIconData:QWORD
    LOCAL hRes:QWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dqImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInstance, hRes
        .IF rax != 0
            mov rbx, lpIconData
            mov [rbx].ICONDATA.size_, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov rbx, lpIconData
                    mov [rbx].ICONDATA.data, rax
                    mov rax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, FALSE
    .ENDIF    
    ret

APISearchLoadMenuIcon ENDP



;;=====================================================================================
;; Plugin Dialog Procedure
;;-------------------------------------------------------------------------------------
;PluginDlgProc PROC FRAME hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
;    
;    mov eax, uMsg
;    .IF eax == WM_INITDIALOG
;        ; Any initialization here
;        
;	.ELSEIF eax == WM_CLOSE
;        Invoke EndDialog, hWin, NULL
;        
;	.ELSEIF eax == WM_COMMAND
;        mov rax, wParam
;        and rax, 0FFFFh
;        .IF rax == IDC_PLUGINDLG_OK
;            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
;        .ENDIF
;    .ELSE
;        mov rax, FALSE
;        ret
;	.ENDIF
;    mov rax, TRUE
;    ret
;PluginDlgProc endp


END DllMain
















