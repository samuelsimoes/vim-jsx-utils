function! JSXIsSelfCloseTag()
  let l:line_number = line(".")
  let l:line = getline(".")
  let l:tag_name = matchstr(matchstr(line, "<\\w\\+"), "\\w\\+")

  exec "normal! 0f<vat\<esc>"

  cal cursor(line_number, 1)

  let l:selected_text = join(getline(getpos("'<")[1], getpos("'>")[1]))

  let l:match_tag = matchstr(matchstr(selected_text, "</\\w\\+>*$"), "\\w\\+")

  return tag_name != match_tag
endfunction

function! JSXSelectTag()
  if JSXIsSelfCloseTag()
    exec "normal! \<esc>0f<v/\\/>$\<cr>l"
  else
    exec "normal! \<esc>0f<vat"
  end
endfunction

" transform this:
"   <p>Hello</p>
" into this:
"   return (
"     <p>Hello</p>
"   );
function! JSXEncloseReturn()
  let l:previous_q_reg = @q
  let l:tab = &expandtab ? repeat(" ", &shiftwidth) : "\t"
  let l:line = getline(".")
  let l:line_number = line(".")
  let l:distance = len(matchstr(line, "^\[\\t|\\ \]*"))
  if &expandtab
    let l:distance = (distance / &shiftwidth)
  endif

  call JSXSelectTag()
  exec "normal! \"qc"

  let @q = repeat(tab, distance) . "return (\n" . repeat(tab, distance + 1) . substitute(getreg("q"), "\\n", ("\\n" . tab), "g") .  "\n" . repeat(tab, distance) . ");\n"

  exec "normal! dd\"qP"

  let @q = previous_q_reg
endfunction

" extract some JSX component's node to a dedicated render function (only ES6
" class)
function! JSXExtractPartialPrompt()
  let l:func_name = input("Function name: ")
  if !len(func_name)
    return
  endif
  call JSXExtractPartial(func_name)
endfunction

function! JSXExtractPartial(partial_name)
  let l:previous_q_reg = @q
  let l:line = getline(".")
  let l:line_number = line(".")
  let l:tab = &expandtab ? repeat(" ", &shiftwidth) : "\t"
  let l:distance = len(matchstr(line, "^\[\\t|\\ \]*"))
  if &expandtab
    let l:distance = (distance / &shiftwidth)
  endif

  call JSXSelectTag()
  exec "normal! \"qc{this." . a:partial_name . "()}"

  " Fix identation
  if distance > 3
    let l:distance = (distance - 3)
    let @q = substitute(getreg("q"), ("\\n" . repeat(tab, distance)), "\\n", "g")
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
  let l:identation_length = len(matchstr(line, "^\[\\t|\\ \]*"))

  if &expandtab
    let l:padding = repeat(" ", (identation_length + &shiftwidth))
  else
    let l:padding = repeat("\t", identation_length + 1)
  endif

  let @q = substitute(line, "\\w\\+=[{|'|\"]", "\\n" . padding . "&", "g")

  let @q = substitute(getreg("q"), "\ \\n", "\\n", "g")

  execute "normal! 0d$\"qp"

  let @q = previous_q_reg
endfunction

function! JSXChangeTag(new_tag)
  let l:previous_q_reg = @q
  let l:self_close_tag = JSXIsSelfCloseTag()

  call JSXSelectTag()

  normal! "qd

  if self_close_tag
    let @q = substitute(getreg("q"), "^<\\w\\+", ("<" . a:new_tag), "g")
  else
    let @q = substitute(getreg("q"), "^<\\w\\+", ('<' . a:new_tag), "g")
    let @q = substitute(getreg("q"), "\\w\\+>$", (a:new_tag . '>'), "g")
  end

  normal "qp

  let @q = previous_q_reg
endfunction

function! JSXChangeTagPrompt()
  let l:tag_name = input("New tag name: ")
  if !len(tag_name)
    return
  endif
  call JSXChangeTag(tag_name)
endfunction
