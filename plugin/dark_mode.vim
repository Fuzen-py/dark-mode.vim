" Dark Mode
" Attemtps to detect system's darkmode and synchronize it
"
" Version:    0.1
" Maintainer: Fuzen<hello@fuzen.cafe>
"
" NOTE: Currently only supports MacOS Mojave +
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
" Plugin load script {{{
if exists('g:loaded_dark_mode')
	finish
endif
let g:loaded_dark_mode='yes'
" }}}
" g:dark_mode_sync: Set System theme to match vim's Background (Disabled By Default)
if !exists('g:dark_mode#sync')
	let g:dark_mode#sync = 0
endif
" g:dark_mode_day: When day time begins [hours, minutes, seconds]
" If g:dark_mode#night is set and day is not, sets to g:dark_mode#night - 5h
" Otherwise defaults to [09,30,0]
if !exists("g:dark_mode#day")
	if exists("g:dark_mode#night")
		let g:dark_mode#day = g:dark_mode#night
		let g:dark_mdoe#day[0] -= (g:dark_mode#day[0] => 5 ) ? 5 : -5
	else
		let g:dark_mode#day = [09,30,0]
	endif
endif

" g:dark_mode#night: When the night begins [hours, minutes, seconds]
" Defaults to g:dark_mode#day + 5h
if !exists("g:dark_mode#night")
	let g:dark_mode#night = g:dark_mode#day
	let g:dark_mode#night[0] += (g:dark_mode#night[0] <= 18) ? 5 : -5
endif
" Math system theme to vim background
autocmd ColorScheme * if g:dark_mode#sync | call dark_mode#set_dark((&background=="dark")) | endif
" vim: tabstop=4:shiftwidth=4:softtabstop=4:noexpandtab:foldmethod=indent:
