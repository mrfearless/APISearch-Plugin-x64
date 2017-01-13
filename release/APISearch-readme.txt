;=====================================================================================
;
; APISearch-readme.txt
;
; v1.0.0.4 - Last updated: 13/01/2017
;
;-------------------------------------------------------------------------------------

About
-----

APISearch Plugin (x64) For x64dbg (64bit plugin)
by fearless - www.LetTheLight.in

Created with the x64dbg Plugin SDK For x64 Assembler
https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler


Overview
--------

A plugin to allow searching for API calls and/or searching online from command bar


Features
--------

- Search online for API calls in the dissassembly window (lines that begin with 'call')
- Search from the command bar using google, msdn or pinvoke, ie: 'google <searchterm>'
- Open web browser to google, msdn or pinvoke, ie: 'msdn' opens browser at msdn.microsoft.com


Notes
-----

- 13/01/2017 fixed a bug with PLUG_MENUENTRY structure in the SDK and recompiled
- 26/06/2016 Updated x64dbg SDK for masm to version 1.0.0.3 and recompiled plugin.
- 01/03/2016 Updated x64dbg SDK for masm to version 1.0.0.2 and recompiled plugin.
- Added function APISearchLoadMenuIcon to load png resource image as raw bytes 
- Added menu icon for plugin (uses _plugin_menuseticon)
- Added menu entry icons for google, msdn and pinvoke (uses _plugin_menuentryseticon) 