" Dark Mode
" Attemtps to detect system's darkmode and synchronize it
" Also supports changes by time of day
"
" Version:    0.2
" Maintainer: Fuzen<hello@fuzen.cafe>
" File: autoload/dark_mode.vim

" NOTE: OS theme dectection is currently only supports MacOS Mojave or newer
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
"
" TODO: Add Day/Night colorscheme
" TODO: Set optionally time base as fallback for dark_mode#enable_watcher
" TODO: Write docs
" TODO: Add support for GTK/QT/Windows
"
" s:is_darwin: Check if system is MacOS {{{
let s:is_darwin = executable("xcode-select")
" }}}
" Core Script Definitions {{{
let s:new_day_offset = 86400000 " 24H in mills
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
	if exists("s:dark_mode#timer")
		let s:dark_mode#timer = timer_start(a:interval, 'dark_mode#set_detected_theme', {'repeat': -1})
		let s:dark_mode#timer_paused = 0
		return 1
	endif
	return 0
endfunction " }}}
" dark_mode#disable_watcher(): Disable System Watcher {{{
function! dark_mode#disable_watcher()
	if !exists("s:dark_mode#timer")
		unlet s:dark_mode#timer
		unlet s:dark_mode#timer_paused
	endif
endfunctio " }}}
" dark_mode#pause_watcher(): Pause/Unpause System Watcher {{{
function! dark_mode#pause_watcher()
	if !exists("s:dark_mode#timer")
		call timer_pause(s:dark_mode#timer)
		let s:dark#mode_timer_paused = 1
	endif
endfunction " }}}
" dark_mode#set_dark(on: bool): Set Theme to dark if on is true {{{
function! dark_mode#set_dark(on)
	" Pause Timer if exists {{{
	if exists('s:dark_mode#timer_paused')
		if !s:dark_mdoe_timer_paused
			call timer_pause(s:dark_mode#timer)
			let set_pause = 1
			let s:dark_mode#timer_paused = 1
		endif
	endif " }}}
	" MacOS {{{
	if s:is_darwin
		call s:OSX_SetDark(a:on)
	endif " }}}
	" Vim ColorScheme {{{
	if &bg=="dark" && !empty("g:dark_mode#dark_colorscheme")
		colorscheme g:dark_mode#dark_colorscheme
	elseif &bg=="light" && !empty("g:dark_mode#light_colorscheme")
		colorscheme g:dark_mode#light_colorscheme
	endif " }}}
	" ResumeTimer if paused {{{
	if exists('set_pause') && exists('s:dark_mode#timer')
		call timer_pause(s:dark_mode#timer)
		let s:dark_mode#timer = 0
	endif " }}}
endfunction " }}}
" dark_mode#set_by_time() - Sets day / night by time of day {{{
function! dark_mode#set_by_time()
	let current = dark_mode#time_in_mills('','','')
	let day = dark_mode#time_in_mills(g:dark_mode#day[0], g:dark_mode#day[1], g:dark_mode#day[2])
	let night = dark_mode#time_in_mills(g:dark_mode#night[0], g:dark_mode#night[1], g:dark_mode#night[2])
	let &background = (current < night && current > day ) ? 'light' : 'dark'
endfunction " }}}
" dark_mode#daylight_watcher("on"/"off") - Enable / Disable daylight watcher {{{
function! dark_mode#daylight_watcher(set_state)
	if !exists('s:daylight_timer')
		if (a:set_state !=? "on")
			return 0
		endif
	elseif a:set_state ==? "off"
		return timer_stop(s:daylight_timer)
	elseif type(a:set_state) != type(0)
		echoerr "Invalid argument for dark_mode#daylight_watcher, valid options are [\"on\", \"off\"]"
		return 0
	endif
	let current = dark_mode#time_in_mills('','','')
	let day = dark_mode#time_in_mills(g:dark_mode#day[0], g:dark_mode#day[1], g:dark_mode#day[2])
	let night = dark_mode#time_in_mills(g:dark_mode#night[0], g:dark_mode#night[1], g:dark_mode#night[2])

	let is_day = (current < night && current > day )
	let next = dark_mode#time_difference(current, (is_day) ? night : day)
	let &background = (is_day) ? 'light' : 'dark'
	let s:daylight_timer = timer_start(next, 'dark_mode#daylight_watcher')
endfunction


" }}}
" dark_mode#time_in_mills(hours, mintues, seconds) -> time_in_mills {{{
function! dark_mode#time_in_mills(hours, minutes, seconds)
	" Defaults to strftime fields {{{
	let hours =   empty(a:hours)   ? strftime('%H') : a:hours
	let minutes = empty(a:minutes) ? strftime('%M') : a:minutes
	let seconds = empty(a:seconds) ? strftime('%S') : a:seconds
	"}}}
	return (hours * 3600 + minutes * 60 + seconds) * 1000
endfunction " }}}
" dark_mode#time_difference(current, future) -> difference_in_mills {{{
function! dark_mode#time_difference(current, future)
	return (current-future) + (current > future) ? 0: s:new_day_offset
endfunction
" }}}
" vim: tabstop=4:shiftwidth=4:softtabstop=4:noexpandtab:foldmethod=marker:
