" transform this:
"   <p>Hello</p>
" into this:
"   return (
"     <p>Hello</p>
"   );
function! JSXEncloseReturn()
  let l:previous_q_reg = @q
  let l:tab = &expandtab ? repeat(' ', &shiftwidth) : '\t'
  let l:line = getline('.')
  let l:line_number = line('.')
  let l:tag_name = matchstr(matchstr(line, '<\w\+'), '\w\+')

  " put on reg the possible tag content
  exec "normal! 0f<vat\"qy"

  let l:match_tag = matchstr(matchstr(getreg('q'), '</\w\+>*$'), '\w\+')

  let l:self_close_element = (tag_name != match_tag)

  let l:distance = len(matchstr(line, '^[\t|\ ]*'))

  cal cursor(line_number, 1)

  if &expandtab
    let l:distance = (distance / &shiftwidth)
  endif

  if self_close_element
    exec "normal! \<esc>0f<v/\\/>$\<cr>l\"qd"
  else
    exec "normal! \<esc>0f<\"qcat"
  end

  let @q = repeat(tab, distance) . "return (\n" . repeat(tab, distance + 1) . substitute(getreg('q'), '\n', ('\n' . tab), 'g') .  "\n" . repeat(tab, distance) . ");\n"

  exec "normal! dd\"qP"

  let @q = previous_q_reg
endfunction

" extract some JSX component's node to a dedicated render function (only ES6
" class)
function! JSXExtractPartialPrompt()
  let l:func_name = input('Function name: ')
  if !len(func_name)
    return
  endif
  call JSXExtractPartial(func_name)
endfunction

function! JSXExtractPartial(partial_name)
  let previous_q_reg = @q
  let l:line = getline('.')
  let l:line_number = line('.')
  let l:tag_name = matchstr(matchstr(line, '<\w\+'), '\w\+')
  let l:tab = &expandtab ? repeat(' ', &shiftwidth) : '\t'

  " put on reg the possible tag content
  exec "normal! 0f<vat\"qy"

  let l:match_tag = matchstr(matchstr(getreg('q'), '</\w\+>*$'), '\w\+')

  let l:self_close_element = (tag_name != match_tag)

  cal cursor(line_number, 1)

  if self_close_element
    exec "normal! f<v/\\/>$\<cr>l\"qc{this." . a:partial_name . "()}"
  else
    exec 'normal! f<vat"qc{this.' . a:partial_name . '()}'
  end

  " Fix identation
  let l:distance = len(matchstr(line, '^[\t|\ ]*'))

  if &expandtab
    let l:distance = (distance / &shiftwidth)
  endif

  if distance > 3
    let l:distance = (distance - 3)
    let @q = substitute(getreg('q'), ('\n' . repeat(tab, distance)), '\n', 'g')
  endif

  exec '/^[\t|\ ]*}$'

  let @q = "\n" . tab . a:partial_name . " () {\n" . repeat(tab, 2) . "return (\n" . repeat(tab, 3) . getreg('q') . "\n" . repeat(tab, 2) . ");\n" . tab . "}"

  exec "normal! o\<esc>\"qp"

  cal cursor(line_number, 1)

  let @q = previous_q_reg
endfunction

" put each JSX tag's attributes on its on line
function! JSXEachAttributeInLine()
  let l:previous_q_reg = @q
  let l:line = getline(".")
  let l:identation_length = len(matchstr(line, '^[\t|\ ]*'))

  if &expandtab
    let l:padding = repeat(' ', (identation_length + &shiftwidth))
  else
    let l:padding = repeat('\t', identation_length + 1)
  endif

  let @q = substitute(line, "\\w\\+=[{|'|\"]", "\\n" . padding . "&", "g")

  let @q = substitute(getreg("q"), "\ \\n", "\\n", "g")

  execute 'normal! 0d$"qp'

  let @q = previous_q_reg
endfunction
