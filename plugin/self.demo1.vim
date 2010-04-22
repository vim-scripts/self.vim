" ============================================================================
" Test for Self.vim
" Demo1 
"   This create Number objects with methods.
"
" To execute test put the following in your .vimrc file
"  source $HOME/.vim/self.vim
"  source $HOME/.vim/self.demo1.vim
"  map t1 :call Demo1()<CR>
"
" Then start vim with no file and type: 't1'
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

function! s:loadNumberPrototype()
  if s:IN_DEVELOPMENT_MODE
    if exists("s:NumberPrototype")
      unlet s:NumberPrototype
    endif
  endif
  if !exists("s:NumberPrototype")
    let s:NumberPrototype = g:loadObjectPrototype().create()
    let s:NumberPrototype._type = 'NumberPrototype'
    let s:NumberPrototype.__value = 0

    function! s:NumberPrototype.initialize(value) dict
      let self.__value = a:value
    endfunction

    " -------------------
    "  public methods
    " -------------------
    function s:NumberPrototype.setValue(value) dict
      let self.__value = a:value
    endfunction

    function s:NumberPrototype.getValue() dict
      return self.__value
    endfunction

    function s:NumberPrototype.negate() dict
      let self.__value = - self.__value
      return self.__value
    endfunction

   function s:NumberPrototype.add(...) dict
      for n in a:000
        call s:NumberPrototype._add(self, n)
      endfor
      return self
   endfunction

    function s:NumberPrototype.subtract(...) dict
      for n in a:000
        call s:NumberPrototype._subtract(self, n)
      endfor
      return self
    endfunction

    function s:NumberPrototype.multiply(...) dict
      for n in a:000
        call s:NumberPrototype._multiply(self, n)
      endfor
      return self
    endfunction

    function s:NumberPrototype.divide(...) dict
      for n in a:000
        call s:NumberPrototype._divide(self, n)
      endfor
      return self
    endfunction

    function! s:NumberPrototype.toString() dict
      let str = string(self.__value)
      return str
    endfunction

    " -------------------
    "  private methods
    " -------------------
    function s:NumberPrototype._add(prototype, n) dict
      let l:type = type(a:n)
      if type == g:NUMBER_TYPE
        let a:prototype.__value = a:prototype.__value + a:n
      elseif type == g:STRING_TYPE
        let l:n = a:n + 0
        let a:prototype.__value = a:prototype.__value + l:n
      elseif type == g:FUNCREF_TYPE
        throw "add by FuncRef: " . a:n
      elseif type == g:LIST_TYPE
        call a:prototype.add(a:n)
      elseif type == g:DICTIONARY_TYPE
        throw "add by Dictionary: " . a:n
      endif
    endfunction

    function s:NumberPrototype._subtract(prototype, n) dict
      let l:type = type(a:n)
      if type == g:NUMBER_TYPE
        let a:prototype.__value = a:prototype.__value - a:n
      elseif type == g:STRING_TYPE
        let l:n = a:n + 0
        let a:prototype.__value = a:prototype.__value - l:n
      elseif type == g:FUNCREF_TYPE
        throw "subtract by FuncRef: " . a:n
      elseif type == g:LIST_TYPE
        call a:prototype.subtract(a:n)
      elseif type == g:DICTIONARY_TYPE
        throw "subtract by Dictionary: " . a:n
      endif
    endfunction

    function s:NumberPrototype._multiply(prototype, n) dict
      let l:type = type(a:n)
      if type == g:NUMBER_TYPE
        let a:prototype.__value = a:prototype.__value * a:n
      elseif type == g:STRING_TYPE
        let l:n = a:n + 0
        let a:prototype.__value = a:prototype.__value * l:n
      elseif type == g:FUNCREF_TYPE
        throw "multiply by FuncRef: " . a:n
      elseif type == g:LIST_TYPE
        call a:prototype.multiply(a:n)
      elseif type == g:DICTIONARY_TYPE
        throw "multiply by Dictionary: " . a:n
      endif
    endfunction

    function s:NumberPrototype._divide(prototype, n) dict
      let l:type = type(a:n)
      if type == g:NUMBER_TYPE
        if a:n == 0
          throw "divide by zero"
        endif
        let a:prototype.__value = a:prototype.__value / a:n
      elseif type == g:STRING_TYPE
        let l:n = a:n + 0
        if l:n == 0
          throw "divide by zero"
        endif
        let a:prototype.__value = a:prototype.__value / l:n
      elseif type == g:FUNCREF_TYPE
        throw "divide by FuncRef: " . a:n
      elseif type == g:LIST_TYPE
        call a:prototype.divide(a:n)
      elseif type == g:DICTIONARY_TYPE
        throw "divide by Dictionary: " . a:n
      endif
    endfunction

  endif
  return s:NumberPrototype
endfunction
function! s:newNumber(value)
  let l:o = s:loadNumberPrototype().create()
  call l:o.initialize(a:value)
  return l:o
endfunction

function! s:loadMyNumberPrototype()
  if s:IN_DEVELOPMENT_MODE
    if exists("s:MyNumberPrototype")
      unlet s:MyNumberPrototype
    endif
  endif
  if !exists("s:MyNumberPrototype")
    let s:MyNumberPrototype = s:loadNumberPrototype().create()
    let s:MyNumberPrototype._type = 'MyNumberPrototype'
    let s:MyNumberPrototype.__name = ''

    function! s:MyNumberPrototype.initialize(value, name) dict
      let self.__value = a:value
      let self.__name = a:name
    endfunction

    function s:MyNumberPrototype.getName() dict
      return self.__name
    endfunction

    function! s:MyNumberPrototype.toString() dict
      let str = string(self.__value) . ' ' . self.__name
      return str
    endfunction

  endif
  return s:MyNumberPrototype
endfunction
function! s:newMyNumber(value, name)
  let l:o = s:loadMyNumberPrototype().create()
  call l:o.initialize(a:value, a:name)
  return l:o
endfunction






function! Demo1()
  let n = s:newNumber(4.4)
  call s:AppendStr('n should be 4.4: ' . n.toString())

  let n = n.add(10)
  call s:AppendStr('n should be 14.4: ' . n.toString())

  let n = n.subtract(10)
  call s:AppendStr('n should be 4.4: ' . n.toString())

  let n = n.multiply(2)
  call s:AppendStr('n should be 8.8: ' . n.toString())

  let n = n.divide(2, 2)
  call s:AppendStr('n should be 2.2: ' . n.toString())
  
  " m is created from n
  let m = n.create()
  " call g:appendDict(m)

  let m = m.multiply(2)
  call s:AppendStr('m should be 4.4: ' . m.toString())
  call s:AppendStr('n should be 2.2: ' . n.toString())

  let mynum = s:newMyNumber(4, 'MyNumber')
  call s:AppendStr('mynum should be 4 MyNumber: ' . mynum.toString())
  
  function n.double() dict
    let self.__value = 2 * self.__value
    return self
  endfunction

  let n = n.double()
  call s:AppendStr('n should be 4.4: ' . n.toString())

  " Now, m knows nothing about n's double method so for m to call it
  " would be an error:
  " let m = m.double()

endfunction
