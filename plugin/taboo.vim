" =============================================================================
" File: taboo.vim
" Description: A little plugin for managing the vim tabline
" Mantainer: Giacomo Comitti (https://github.com/gcmt)
" Url: https://github.com/gcmt/taboo.vim
" License: MIT
" =============================================================================

" Init
" =============================================================================

if exists("g:loaded_taboo") || v:version < 702
    finish
endif
let g:loaded_taboo = 1

let s:save_cpo = &cpo
set cpo&vim

" Settings
" =============================================================================

" This variable is needed to remember custom tab names when a session is
" saved. String format: 'TABNUM\tTABNAME\nTABNUM\tTABNAME\n...'
let g:Taboo_tabs =
    \ get(g:, "Taboo_tabs", "")

let g:taboo_tabline =
    \ get(g:, "taboo_tabline", 1)

let g:taboo_tab_format =
    \ get(g:, "taboo_tab_format", " %f%m ")

let g:taboo_renamed_tab_format =
    \ get(g:, "taboo_renamed_tab_format", " [%l]%m ")

let g:taboo_modified_tab_flag =
    \ get(g:, "taboo_modified_tab_flag", "*")

let g:taboo_close_tabs_label =
    \ get(g:, "taboo_close_tabs_label", "")

let g:taboo_close_tab_label =
    \ get(g:, "taboo_close_tab_label", "x")

let g:taboo_unnamed_tab_label =
    \ get(g:, "taboo_unnamed_tab_label", "[no name]")

" Functions
" =============================================================================

" To construct the tabline string for terminal vim.
fu TabooTabline()
    let tabline = ''
    for i in s:tabs()
        let tabline .= i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
        let title = s:gettabvar(i, "taboo_tab_name")
        let fmt = empty(title) ? g:taboo_tab_format : g:taboo_renamed_tab_format
        let tabline .= '%' . i . 'T'
        let tabline .= s:expand(i, fmt)
    endfor
    let tabline .= '%#TabLineFill#%T'
    let tabline .= '%=%#TabLine#%999X' . g:taboo_close_tabs_label
    return tabline
endfu

" To construct a single tab title for gui vim.
fu TabooGuiTabTitle()
    return TabooTabTitle(tabpagenr())
endfu

" To rename the current tab.
fu s:RenameTab(label)
    cal s:settabvar(tabpagenr(), "taboo_tab_name", a:label)
    cal s:refresh_tabline()
endfu

" To open a new tab with a custom name.
fu s:OpenNewTab(label)
    tabe!
    cal s:RenameTab(a:label)
endfu

" If the tab has been renamed the custom name is removed.
fu s:ResetTabName()
    cal s:settabvar(tabpagenr(), "taboo_tab_name", "")
    cal s:refresh_tabline()
endfu

" Global functions
" =============================================================================

" To return the formatted tab title
fu TabooTabTitle(tabnr)
    let tabname = s:tabname(a:tabnr)
    let fmt = empty(tabname) ? g:taboo_tab_format : g:taboo_renamed_tab_format
    return s:expand(a:tabnr, fmt)
endfu

" To return the name of the current tab, if one has been set
fu TabooTabName(tabnr)
    return s:tabname(a:tabnr)
endfu

" Functions for formatting the tab title
" =============================================================================

fu s:expand(tabnr, fmt)
    let out = a:fmt
    let out = substitute(out, '\C%f', s:bufname(a:tabnr), "")
    let out = substitute(out, '\C%d', s:tabIcon(a:tabnr), "")
    let out = substitute(out, '\C%a', s:bufpath(a:tabnr, 0), "")
    let out = substitute(out, '\C%r', s:bufpath(a:tabnr, 1), "")
    let out = substitute(out, '\C%n', s:tabnum(a:tabnr, 0), "")
    let out = substitute(out, '\C%N', s:tabnum(a:tabnr, 1), "")
    let out = substitute(out, '\C%i', s:tabnumUnicode(a:tabnr, 0), "")
    let out = substitute(out, '\C%I', s:tabnumUnicode(a:tabnr, 1), "")
    let out = substitute(out, '\C%w', s:wincount(a:tabnr, 0), "")
    let out = substitute(out, '\C%W', s:wincount(a:tabnr, 1), "")
    let out = substitute(out, '\C%u', s:wincountUnicode(a:tabnr, 0), "")
    let out = substitute(out, '\C%U', s:wincountUnicode(a:tabnr, 1), "")
    let out = substitute(out, '\C%m', s:modflag(a:tabnr), "")
    let out = substitute(out, '\C%l', s:tabname(a:tabnr), "")
    let out = substitute(out, '\C%p', s:tabpwd(a:tabnr, 0), "")
    let out = substitute(out, '\C%P', s:tabpwd(a:tabnr, 1), "")
    let out = substitute(out, '\C%S', s:tabpwd(a:tabnr, 2), "")
    let out = substitute(out, '\C%x', s:tabclose(a:tabnr), "")
    return out
endfu

fu s:tabpwd(tabnr, last_component)
  if a:tabnr == tabpagenr()
    cal s:settabvar(a:tabnr, "taboo_tab_wd", getcwd())
  endif

  let tabcwd = s:gettabvar(a:tabnr, "taboo_tab_wd")

  if a:last_component == 1
    return get(split(tabcwd, "/"), -1, "")
  endif

  if a:last_component == 2
    return pathshorten(fnamemodify(tabcwd, ":~"))
  endif

  return tabcwd
endfu

fu s:tabname(tabnr)
    return s:gettabvar(a:tabnr, "taboo_tab_name")
endfu

fu s:tabnum(tabnr, ubiquitous)
    if a:ubiquitous
        return a:tabnr
    endif

    return a:tabnr == tabpagenr() ? a:tabnr : ''
endfu

fu s:tabnumUnicode(tabnr, ubiquitous)
    let number_to_show = s:numberToUnicode(a:tabnr)

    if a:ubiquitous
        return number_to_show
    endif

    return a:tabnr == tabpagenr() ? number_to_show : ''
endfu

fu s:tabIcon(tabnr)
  if exists("*WebDevIconsGetFileTypeSymbol")
    return WebDevIconsGetFileTypeSymbol(s:bufname(a:tabnr))
  endif
endfu

fu s:wincount(tabnr, ubiquitous)
    let windows = tabpagewinnr(a:tabnr, '$')
    if a:ubiquitous
        return windows
    endif
    return a:tabnr == tabpagenr() ? windows : ''
endfu

fu s:wincountUnicode(tabnr, ubiquitous)
    let buffers_number = tabpagewinnr(a:tabnr, '$')
    let number_to_show = s:numberToUnicode(buffers_number)

    if a:ubiquitous
        return number_to_show
    endif

    return a:tabnr == tabpagenr() ? number_to_show : ''
endfu

" Adapted from Vim-CtrlSpace (https://github.com/szw/vim-ctrlspace)
fu s:numberToUnicode(number)
    let unicode_number = ""

    let small_numbers = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
    let number_str    = string(a:number)

    for i in range(0, len(number_str) - 1)
        let unicode_number .= small_numbers[str2nr(number_str[i])]
    endfor

    return unicode_number
endfu


fu s:modflag(tabnr)
    let flag = g:taboo_modified_tab_flag
    for buf in tabpagebuflist(a:tabnr)
        if getbufvar(buf, "&mod")
            if g:taboo_tabline
                if a:tabnr == tabpagenr()
                    return "%#TabModifiedSelected#" . flag . "%#TabLineSel#"
                else
                    return "%#TabModified#" . flag . "%#TabLine#"
                endif
            else
                return flag
            endif
        endif
    endfor
    return ""
endfu

fu s:tabclose(tabnr)
  return '%' . a:tabnr . 'X' . g:taboo_close_tab_label . '%X'
endfu

fu s:bufname(tabnr)
    let buffers = tabpagebuflist(a:tabnr)
    let buf = s:first_normal_buffer(buffers)
    let bname = bufname(buf > -1 ? buf : buffers[0])
    if !empty(bname)
        return s:basename(bname)
    endif
    return g:taboo_unnamed_tab_label
endfu

fu s:bufpath(tabnr, relative)
    let buffers = tabpagebuflist(a:tabnr)
    let buf = s:first_normal_buffer(buffers)
    let bname = bufname(buf > -1 ? buf : buffers[0])
    if !empty(bname)
        if a:relative
            return bname
        else
            return s:fullpath(bname, 1)
        endif
    endif
    return g:taboo_unnamed_tab_label
endfu

" Helpers
" =============================================================================

fu s:tabs()
    return range(1, tabpagenr('$'))
endfu

fu s:windows(tabnr)
    return range(1, tabpagewinnr(a:tabnr, '$'))
endfu

fu s:basename(bufname)
    return fnamemodify(a:bufname, ':p:t')
endfu

fu s:fullpath(bufname, pretty)
    let path = fnamemodify(a:bufname, ':p')
    return a:pretty ? substitute(path, $HOME, '~', '') : path
endfu

fu s:first_normal_buffer(buffers)
    for buf in a:buffers
        if buflisted(buf) && getbufvar(buf, "&bt") != 'nofile'
            return buf
        end
    endfor
    return -1
endfu


" To refresh the tabline.
" This function also ensures that g:Taboo_tabs stays updated.
fu s:refresh_tabline()
    cal s:settabvar(tabpagenr(), "taboo_tab_wd", getcwd())
    if exists("g:SessionLoad")
        return
    endif
    let g:Taboo_tabs = ""
    for i in s:tabs()
        if !empty(s:gettabvar(i, "taboo_tab_name"))
            let g:Taboo_tabs .= i."\t".s:gettabvar(i, "taboo_tab_name")."\n"
        endif
    endfor
    exe "set stal=" . &showtabline
endfu

" To restore tab names after a session has been restored.
fu s:restore_tabs()
    for [tabnum, tabname] in s:load_tabs("Taboo_tabs")
        cal s:settabvar(tabnum, "taboo_tab_name", tabname)
    endfor
endfu

fu s:load_tabs(var)
    return map(split(get(g:, a:var, ""), "\n"), "split(v:val, '\t')")
endfu

" Backward compatibility functions
" =============================================================================

" 7.2: Set the tab variable in each window in the tab.
fu s:settabvar(tabnr, var, value)
    if v:version > 702
        cal settabvar(a:tabnr, a:var, a:value)
    else
        for winnr in s:windows(a:tabnr)
            cal settabwinvar(a:tabnr, winnr, a:var, a:value)
        endfor
    endif
endfu

" 7.2: Each window in a tab should have the pseudo tab variable requested.
fu s:gettabvar(tabnr, var)
    if v:version > 702
        return gettabvar(a:tabnr, a:var)
    endif
    for winnr in s:windows(a:tabnr)
        let value = gettabwinvar(a:tabnr, winnr, a:var)
        if !empty(value)
            return value
        endif
    endfor
    return ""
endfu

" To make sure all windows in the tab have the 'taboo_tab_name' pseudo tab variable.
fu s:sync_tab_name()
    let tabnr = tabpagenr()
    call s:settabvar(tabnr, 'taboo_tab_name', s:gettabvar(tabnr, 'taboo_tab_name'))
endfu

" Commands
" =============================================================================

command! -nargs=1 TabooRename call s:RenameTab(<q-args>)
command! -nargs=1 TabooOpen call s:OpenNewTab(<q-args>)
command! -nargs=0 TabooReset call s:ResetTabName()

" Autocommands
" =============================================================================

augroup taboo
    au!
    au VimEnter * if g:taboo_tabline | set tabline=%!TabooTabline() | endif
    au VimEnter * if g:taboo_tabline && has('gui') && has('windows') | set guitablabel=%!TabooGuiTabTitle() | endif
    au SessionLoadPost * cal s:restore_tabs()
    au TabLeave,TabEnter * cal s:refresh_tabline()
    au WinLeave,WinEnter * if v:version < 703 | cal s:sync_tab_name() | endif
    au BufCreate,BufLeave,BufEnter * if v:version < 703 | cal s:sync_tab_name() | endif
augroup END

" =============================================================================


" Highlight Groups
" =============================================================================
" Link new highlight groups to reasonable/expected defaults
highlight default link TabModified TabLine
highlight default link TabModifiedSelected TabLineSel

let &cpo = s:save_cpo
unlet s:save_cpo
