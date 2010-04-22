" ============================================================================
" self.vim
"
" $Id: self.vim 310 2010-04-21 19:15:45Z  $
"
" Vim Self Object Prototype System allows developer to create 
"   object-base scripts (named after the David Ungar's Self language). 
"
" This code to be used by script developers, not for direct use by
"   end users (by itself, it does nothing).
"
" When Vim version 7.0 with dictionary variables and function references
"   came out, I created this object prototype support script. At that time 
"   I was planning to write a text-base windowing system on top of Vim which
"   would allow script to create such things as forms. During script
"   installation having per-script driven forms allowing for the tailoring
"   of the script environment might have been a good thing.
"
" Anyway, time pasted and I moved onto other projects without really
"   finishing this script. Then I wanted to create a Scala language
"   comment generation script much like the jcommenter.Vim script for
"   Java. My first cut, version 1.0, was all imperative: enumerations for
"   the different entity types (class, object, 
"   method, etc.); with functions for different behaviors and 
"   switch-case statements (i.e., if-elseif-endif) using the enumeration 
"   to determine which block of Vim script to execute. This worked
"   but each entity's behavior was scattered throughout the script file.
"
" I then thought to dust off my old object system and re-casting my
"   Scala comment generator using it. While the code size is the same,
"   now behavior is near the data (or in an object's prototype chain).
"
" So, here is the code. Along with this file there are some simple usage
"   example files also in the download. None of the examples, though, are
"   as complex as what is done in the scalacommenter.vim script.
"
" ============================================================================
" Caveats:
" Without deeper native VimScript support for object prototypes, I suspect
"   that there is a performance penalty when using objects rather than
"   imperative functions and switch-case statements.
" Method lookup is static, a child object knows its parent (prototype) 
"   object's method at its creation. Post-creation if the parent adds 
"   a new method, the child can not access it.
"   Method dispatch does not dynamically walk up the parent chain attempting
"   to find a given method, if the child does not have the method (if
"   the child, which is a dictionary, does not have the method as a key,
"   then an error occurs - no chance to walk up the parent hierarchy.
" When an object has a type name (the '_type' key) that ends with the string 
"   'Prototype', then children of the object have the object as their parent 
"   (their prototype) and the child's type name will be parent's type
"   name with the 'Prototype' part removed.
"   On the other hand, when an object does not have the string 
"   'Prototype' in its type name, then children of the object have 
"   the object's parent as their parent and have the same type name as
"   the object. If this is not done, then when the child objects call
"   a method a recursion error occurs. The Vim "call()" mechanism is
"   not powerful enough to support passing the object, 'self', as well
"   as chaining up the prototype hierarchy with self._prototype, 
"   self._prototype._prototype, self._prototype._prototype._prototype
"   and so on. Bram Moolenaar if you want to discuss this, contact me.
" All of the object methods are anonymous functions that make debugging
"   really hard; for a stack trace all you get are a bunch of numbers
"   as function names. Now, if you print out the keys of an object you
"   get both the function name and its number. Its too bad that stack
"   trace print the function's number rather than the function's name.
"
" ============================================================================
" Configuration Options:
"   These help control the behavior of Self.vim
"   Remember, if you change these and then upgrade to a later version, 
"   your changes will be lost.
" ============================================================================
" Define these just to make the code a little more readable
" Remember, these are script local and can not be used in your .vimrc
" file (but 0 and 1 can be used)
let s:IS_FALSE = 0
let s:IS_TRUE = 1


" ============================================================================
" History:
" File:          self.vim
" Summary:       Vim Self Object Prototype System
" Author:        Richard Emberson <richard.n.embersonATgmailDOTcom>
" Last Modified: 04/20/2010
" Version:       1.0
" Modifications:
"  1.0 : initial public release.
"
" Tested on vim 7.2 on Linux
"
" ============================================================================
" Description:
"
" Base Object Prototype for creating a prototype-base object inheritance
"   hierarchy. 
"
" This is not a class-base Object-Orient system, rather it is 
"   prototype-base. The Self language was, I believe, the first such
"   language. One of the more popular language today is prototype-base
"   (Do you know which language I am referring to?).
"
" With prototype-base OO language, child objects are created by making
"   a copy of another, the parent or prototype, object. Additional 
"   instance variables and methods can be added to the child object. Also,
"   methods of the child's parent (again, its prototype) can also 
"   be redefined.
"
" By convention, the names of public methods and values should not start
"   with an underscore. Private methods and values have names starting
"   with a single leading '_'. Methods and values with names starting 
"   with multiple '_'s are protected. 
"   Public and protected methods and values are copied into child
"   objects during creation. Private methods and values are not copied
"   during object creation.
"
" ============================================================================
" Installation:
"
" 1. If needed, edit the configuration section. Any configuration options
"   are commented, so I won't explain the options here.
"
" 2. Put something like this in your .vimrc file:
"
"      source $VIM/macros/self.vim
"      source $VIM/macros/some_scrip.vim
"
"   or wherever you put your Vim scripts.
"   Here, some_scrip.vim a script that requires the self.vim script
"   
"   An alternative is for developers to embed the self.vim script in
"     their script as I did with my scalacommenter.vim script. This
"     makes it easier for the ultimate end-user to install your script.
"
" ============================================================================
" Usage:
"
" For the end-user there is no particular usage information.
"
" ============================================================================
" Comments:
"
"   Send any comments or bugreports to:
"       Richard Emberson <richard.n.embersonATgmailDOTcom>
"
" ============================================================================
" THE SCRIPT
" ============================================================================
" If set to true, then when re-sourcing this file during a vim session
"   static/global objects may be initialized again before use.
let s:IN_DEVELOPMENT_MODE = s:IS_TRUE


" ============================================================================
" Public functions
" ============================================================================

" ++++++++++++++++++++++++++++++++++++++++++++
" Vim type enumerations.
" ++++++++++++++++++++++++++++++++++++++++++++
let g:NUMBER_TYPE     = type(0)
let g:STRING_TYPE     = type("")
let g:FUNCREF_TYPE    = type(function("tr"))
let g:LIST_TYPE       = type([])
let g:DICTIONARY_TYPE = type({})
let g:FLOAT_TYPE      = type(0.0)

" ++++++++++++++++++++++++++++++++++++++++++++
" Print a dictionary item to standard output
" ++++++++++++++++++++++++++++++++++++++++++++
function! g:printDict(item) 
  for key in keys(a:item)
   echo key . ': ' . string(a:item[key])
  endfor
endfunction


" ++++++++++++++++++++++++++++++++++++++++++++
" SELF.VIM ObjectPrototype
" ++++++++++++++++++++++++++++++++++++++++++++
function! g:loadObjectPrototype()
  if s:IN_DEVELOPMENT_MODE
    if exists("g:ObjectPrototype")
      unlet g:ObjectPrototype
    endif
  endif
  if !exists("g:ObjectPrototype")
    "-----------------------------------------------
    " private variables
    "-----------------------------------------------
    let g:ObjectPrototype = { '_type': 'ObjectPrototype' , '_prototype': '' }

    "-----------------------------------------------
    " public methods
    "-----------------------------------------------
    function g:ObjectPrototype.getType() dict
      return g:ObjectPrototype._getType(self)
    endfunction

    function g:ObjectPrototype.getPrototype() dict
      return g:ObjectPrototype._getPrototype(self)
    endfunction

    function g:ObjectPrototype.instanceOf(prototype) dict
      let type = a:prototype._type
      let parent = self._prototype
      while type(parent) == g:DICTIONARY_TYPE
        if parent._type == type
          return 1
        endif
        if type(parent._prototype) == g:DICTIONARY_TYPE
          let parent = parent._prototype
        else
          break
        endif
      endwhile
      return 0
    endfunction

    function g:ObjectPrototype.equals(obj) dict
      return self == a:obj
    endfunction

    function g:ObjectPrototype.create() dict
      return g:ObjectPrototype._create(self)
    endfunction

    function g:ObjectPrototype.delete() dict
      return g:ObjectPrototype._delete(self)
    endfunction


    "-----------------------------------------------
    " private methods
    "-----------------------------------------------

    function g:ObjectPrototype._getType(prototype) dict
      return a:prototype._type
    endfunction

    function g:ObjectPrototype._getPrototype(prototype) dict
      return a:prototype._prototype
    endfunction

    " --------------------------------------------
    " Creates a copy of a Prototype or an object 
    "   which is itself a copy of a Prototype.
    "   Private values and methods, those that
    "   start with a single '_' are not copied.
    "   Methods and values with no leading '_' or
    "   with more than one leading '_' are copied.
    " --------------------------------------------
    function g:ObjectPrototype._create(prototype) dict
      let l:i = stridx(a:prototype._type, "Prototype")   
      if l:i == -1
        let l:t = a:prototype._type
        let pt = a:prototype._prototype
      else
        let l:t = strpart(a:prototype._type, 0, l:i)
        let pt = a:prototype
      endif
      let l:o = { '_type': l:t, '_prototype': pt }

      for key in keys(a:prototype)
        " If its a function, then arrange that a function is defined
        " that calls the parent function. This allows one later to
        " either redefine a derived object's function only 
        " effecting its behavior (and all of its children) or
        " redefine the base object's funciton effecting all
        " children. If we simply copied the function reference
        " we would lose this flexibility - it would not be 'vim.self'. 
        " Curiously, there is just enough reflective power around to
        " allow this to happen.
        " If you get a function calling recursion error, it maybe 
        " because there is some edge case the following code fails
        " to address. Find the fix and tell me about it :-).
        if type(a:prototype[key]) == g:FUNCREF_TYPE
          if key[0] == '_' && key[1] != '_'
            " Private methods are not copied
          else
            " Public methods are copied so that they call the parent's copy
            let l:type = a:prototype._type
            let l:scope = 's:'
            if exists('s:' . l:type)
              let l:scope = 's:'
            elseif exists('g:' . l:type)
              let l:scope = 'g:'
            elseif exists('w:' . l:type)
              let l:scope = 'w:'
            elseif exists('t:' . l:type)
              let l:scope = 't:'
            elseif exists('b:' . l:type)
              let l:scope = 'b:'
            else
              let l:scope = ''
            endif

            let l:fd = "function! l:o." . key . "(...) dict\n"

            if l:scope != ''
              let l:fd = l:fd . "return call(" . l:scope . type . "." . key . ", a:000, self)\n"
            else
              let l:fd = l:fd . "return call(self._prototype." . key . ", a:000, self)\n"
            endif

            let l:fd = l:fd . "endfunction"
            execute l:fd
          endif
        else
          " Data
          if key[0] != '_'
            " Public data
            let l:o[key] = a:prototype[key]
          elseif len(key) > 1 && key[0] == '_' && key[1] == '_'
            " Protected data
            let l:o[key] = deepcopy(a:prototype[key])
          endif
        endif
      endfor
      return l:o
    endfunction

    function g:ObjectPrototype._delete(prototype) dict
      let l:i = stridx(a:prototype._type, "Prototype")   
      if l:i != -1
        throw "Can not delete a prototype: " . a:prototype.getType()
      endif
      for key in keys(a:prototype)
        unlet a:prototype[key]
      endfor
    endfunction

  endif
  return g:ObjectPrototype
endfunction



