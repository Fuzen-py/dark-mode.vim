# Vim Dark Mode

Attempts to detect system preference for white/black background and set vim accordingly

Note : OS Detection is currently OSX Only

Development is done on [Gitlab](https://gitlab.com/Fuzen-py/dark-mode.vim).

## Usage

### Day/Night Timer
```vim
" Set the time for day (H:M:S)
" Defaults to 09:30:00
let g:dark_mode#day = [09,30,0]
" Set time for night (H:M:S
" If not set, defaults to day + 5h
let g:dark_mode#night = [14,30,0]

" Set current background by system clock
call dark_mode#set_by_time()

" Time based watcher
" Acepted values are "on" or "off"
call dark_mode#daylight_watcher("on")
" Disable with
call dark_mode#daylight_watcher("off")
```

### By System Theme
```vim
" Note: Currently only supports MacOS Mojave or later
" Note: No errors should occur on other systems by calling these

" Set vim backgroun by current system theme
MacOS dark = backgroun=dark
MacOS light = background=light
dark_mode#set_detected_theme()

" Watch the system theme for changes
" Takes called time in ms
" EX: Every 10 seconds
call dark_mode#enable_watcher(1000)

" Pause/Resume watcher
call dark_mode#pause_watcher()

" Disable watcher
call dark_mode#disable_watcher()

" Set system theme
" 1 = Dark
" 0 = Light
call dark_mode#set_dark(1)

" Synchronize System theme with vim background
" EX: background=dark sets macos to dark
" Disabled by default
let g:dark_mode#sync = 1
```

