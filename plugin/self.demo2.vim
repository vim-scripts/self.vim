" ============================================================================
" Test for Self.vim
" Demo2 
"   This create String objects with methods.
"
" To execute test put the following in your .vimrc file
"  source $HOME/.vim/self.vim
"  source $HOME/.vim/self.demo2.vim
"  map t2 :call Demo2()<CR>
"
" Then start vim with no file and type: 't2'
"
" ============================================================================

let s:IS_FALSE = 0
let s:IS_TRUE = 1
let s:IN_DEVELOPMENT_MODE = s:IS_TRUE

let s:appendPos = 1
function! s:AppendStr(string)
  call append(s:appendPos, a:string)
  let s:appendPos = s:appendPos + 1
endfunction

function! s:appendDict(item)
  for key in keys(a:item)
   call s:AppendStr(key . ': ' . string(a:item[key]))
  endfor
endfunction

function! s:loadStringPrototype()
  if s:IN_DEVELOPMENT_MODE
    if exists("s:StringPrototype")
      unlet s:StringPrototype
    endif
  endif
  if !exists("s:StringPrototype")
    let s:StringPrototype = g:loadObjectPrototype().create()
    let s:StringPrototype._type = 'StringPrototype'
    let s:StringPrototype.__value = ''

    function! s:StringPrototype.initialize(value) dict
      let self.__value = a:value
    endfunction

    " -------------------
    "  public methods
    " -------------------
    function s:StringPrototype.setValue(value) dict
      let self.__value = a:value
    endfunction

    function s:StringPrototype.getValue() dict
      return self.__value
    endfunction

    function s:StringPrototype.length() dict
      return strlen(self.__value)
    endfunction

    " start: where to start the substring 
    " len: how many charcters. if not present, the remaining string
    function s:StringPrototype.substring(start, ...) dict
      if a:0 == 0
        return s:newString(strpart(self.__value, a:start))
      else
        return s:newString(strpart(self.__value, a:start, a:1))
      endif
    endfunction

   function s:StringPrototype.add(...) dict
      for n in a:000
        call s:StringPrototype._add(self, n)
      endfor
      return self
   endfunction

    function! s:StringPrototype.toString() dict
      let str = string(self.__value)
      return str
    endfunction

    " -------------------
    "  private methods
    " -------------------
    function s:StringPrototype._add(prototype, n) dict
      let l:type = type(a:n)
      if type == g:NUMBER_TYPE
        let a:prototype.__value = a:prototype.__value . string(a:n)
      elseif type == g:STRING_TYPE
        let a:prototype.__value = a:prototype.__value . a:n
      elseif type == g:FUNCREF_TYPE
        throw "add by FuncRef: " . a:n
      elseif type == g:LIST_TYPE
        call a:prototype.add(a:n)
      elseif type == g:DICTIONARY_TYPE
        throw "add by Dictionary: " . a:n
      endif
    endfunction

  endif
  return s:StringPrototype
endfunction
function! s:newString(value)
  let l:o = s:loadStringPrototype().create()
  call l:o.initialize(a:value)
  return l:o
endfunction


function! Demo2()
  let n = s:newString("This is a string.")
  call s:AppendStr('n should be "This is a string.": ' . n.toString())

  let len = n.length()
  call s:AppendStr('n len "16": ' . string(len))

  let n = n.add(' ').add("A second string.")
  call s:AppendStr('n should be "This is a string. A second string.": ' . n.toString())

  let sub = n.substring(18)
  call s:AppendStr('sub should be "A second string.": ' . sub.toString())

  let sub = n.substring(18, 9).add('STRING')
  call s:AppendStr('sub should be "A second STRING.": ' . sub.toString())

endfunction
