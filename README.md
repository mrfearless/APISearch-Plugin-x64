# APISearch Plugin (x64) - A Plugin For x64dbg

![](https://github.com/mrfearless/APISearch-Plugin-x64/blob/master/images/APISearch.png) [Current version: 1.0.0.3 - Last updated: 26/06/2016](https://github.com/mrfearless/APISearch-Plugin-x64/releases/latest) For the x86 version of this plugin, visit [here](https://github.com/mrfearless/APISearch-Plugin-x86)

## Overview

A plugin to allow searching for API calls and/or searching online from command bar

## Features

* Search online for API calls in the dissassembly window (lines that begin with 'call')
* Search from the command bar using google, msdn or pinvoke, ie: 'google <searchterm>'
* Open web browser to google, msdn or pinvoke, ie: 'msdn' opens browser at msdn.microsoft.com

## How to install

* If x64dbg (x64dbg 64bit) is currently running, stop and exit.
* Copy the `APISearch.dp64` to your `x64dbg\x64\plugins` folder.
* Start x64dbg

## Information

* Written by [fearless](https://github.com/mrfearless)  - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x64 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* The x64 version of this plugin uses [JWasm64](http://masm32.com/board/index.php?topic=3795.0)
* The [JWasm for RadASM package](http://masm32.com/board/index.php?topic=4162.0) is also required to build this x64 version.

## x64dbg
* [x64dbg website](http://x64dbg.com)
* [x64dbg github](https://github.com/x64dbg/x64dbg)
* [x64dbg gitter](https://gitter.im/x64dbg/x64dbg)
