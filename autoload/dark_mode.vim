" Dark Mode
" Attemtps to detect system's darkmode and synchronize it
"
" Version:    0.1
" Maintainer: Fuzen<hello@fuzen.cafe>
"
"
"
" MIT License

" Copyright (c) 2019 Fuzen

" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:

" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.

" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
" s:is_darwin: Check if system is MacOS {{{
let s:is_darwin = (has("unix") && substitute(system("uname -s"), '\n','', 'g') ==? "Darwin")
" }}}
if !s:is_darwin | finish | endif " MacOS is supported for now
" Set Defaults {{{

" }}}
" }}}
" Script Functions {{{
" Base osascript to Change system preference {{{
let s:OSX_BASE_OSASCRIPT = "tell application \"System Events\" to tell appearance preferences to set dark mode to " " }}}
" s:OSX_SetDark(on: bool):  Set MacOS Theme to Dark {{{
function! s:OSX_SetDark(on)
	silent execute("!osascript -e '" . s:OSX_BASE_OSASCRIPT . (a:on ? "true": "false") . "'")
endfunction " }}}
" s:OSX_Get_Color_cmd: Command to get MacOS Theme {{{
let s:OSX_Get_Color_cmd = "osascript -e 'tell app \"System Events\" to tell appearance preferences to return dark mode'" " }}}
function! s:OSX_Detection_Callback(_, data, event)
	if join(a:data,'')==? "false"
		if &background=="dark"
			set background=light
		endif
	else
		if &background=="light"
			set background=dark
		endif
	endif
endfunction
" }}}
" Functions in user space {{{
" dark_mode#set_detected_theme(): Set vim background to match detected system theme {{{
function! dark_mode#set_detected_theme()
	" MacOS Detection {{{
	if s:is_darwin
		let job = jobstart(s:OSX_Get_Color_cmd, {'on_stdout': function('s:OSX_Detection_Callback'), 'stdout_buffered': 1})
	endif " }}}
endfunction



" }}}
" dark_mode#enable_watcher(interval: int) -> bool: Watch system theme for changes at set interval in ms {{{
function! dark_mode#watcher(interval)
	if exists("s:dark_mode_timer")
		let s:dark_mode_timer = timer_start(a:interval, 'dark_mode#set_detected_theme', {'repeat': -1})
		let s:dark_mode_timer_paused = 0
		return 1
	endif
	return 0
endfunction " }}}
" dark_mode#disable_watcher(): Disable System Watcher {{{
function! dark_mode#disable_watcher()
	if !exists("s:dark_mode_timer")
		unlet s:dark_mode_timer
		unlet s:dark_mode_timer_paused
	endif
endfunctio " }}}
" dark_mode#pause_watcher(): Pause/Unpause System Watcher {{{
function! dark_mode#pause_watcher()
	if !exists("s:dark_mode_timer")
		call timer_pause(s:dark_mode_timer)
		let s:dark_mode_timer_paused = 1
	endif
endfunction " }}}
" dark_mode#set_dark(on: bool): Set Theme to dark if on is true {{{
function! dark_mode#set_dark(on)
	" Pause Timer if exists {{{
	if exists('s:dark_mode_timer_paused')
		if !s:dark_mdoe_timer_paused
			call timer_pause(s:dark_mode_timer)
			let s:_set_pause = 1
			let s:dark_mode_timer_paused = 1
		endif
	endif " }}}
	" MacOS {{{
	if s:is_darwin
		call s:OSX_SetDark(a:on)
	endif " }}}
	" ResumeTimer if paused {{{
	if exists('s:_set_pause') && exists('s:dark_mode_timer')
		call timer_pause(s:dark_mode_timer)
		let s:dark_mode_timer = 0
	endif " }}}
endfunction " }}}

" }}}
" Match SystemTheme with Vim if g:dar_mode_sync is true
autocmd ColorScheme * if g:dark_mode_sync | call dark_mode#set_dark((&background=="dark")) |endif
" vim: tabstop=4:shiftwidth=4:softtabstop=4:noexpandtab:foldmethod=marker:
