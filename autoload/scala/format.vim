" ============================================================================
" scala#format.vim
"
" $Id:$
"
" Target language: Scala
" Format arguments for both function definitions and function calls.
"
" Basically, I got tired to formating arguments (so to speak) by hand,
" so I wrote this.
" When you have method definitions or calls where the argument list
" is longer than you want (longer than your page width), then
" this script can reformat the arguments so that the are all aligned
" with the first argument each on its own line.
" Also, when an argument is a bunch of strings concatenated with
" plus operator, '+', this script will also place each piece of a
" string on its own line.
"
" ============================================================================
" Caveats: 
" Works most of the time, but sometimes when the arguments span multiple
" lines one must first get them all back on the same line again before
" invoking this code .... but not always.
"
" If you have a method call with arguments which are themselves 
" method calls, the arguments to the inner-method are not formated
" within the inner-call.
" ============================================================================

" ============================================================================
" Configuration Options:
"   These help control the behavior of format.vim
"   Remember, if you change these and then upgrade to a later version, 
"   your changes will be lost.
" ============================================================================
" Define these just to make the code a little more readable
"   Remember, these are script local and can not be used in your .vimrc
"   file (but 0 and 1 can be used)
let s:IS_FALSE = 0
let s:IS_TRUE = 1

" Value of the additional indent given to the additional members of a 
" string argument.
"   If an argument is a string concatenated from multiple parts, this
"   option defined the additional indend for the later parts of the string.
"   Recommend setting to 0 or 2.
let g:scala_format_extra_string_arg_offset = 2

" Value of the additional indent given to the additional arguments
" after the first argument.
"   All arguments after the first are indented an additional number
"   of spaces.
"   Recommend setting to 0 
"     (It was easy to add this feature but I would not use it.)
let g:scala_format_extra_arg_offset = 0

" Value of the maximum number of args that can be formatted. 
"   This also limits how many lines are search for the terminating ')'.
let g:scala_format_max_number_args = 15

" Value of the maximum number of lines to search after the start of
" the method for a non-white space character.
let g:scala_format_max_line_search_after_method_start = 2

" ============================================================================
" End of Configuration Options
" ============================================================================

" ============================================================================
" History:
"
" File:          scala/format.vim
" Summary:       Function for formatting Scala methods arguments 
" Author:        Richard Emberson <richard.n.embersonATgmailDOTcom>
" Last Modified: 03/18/2011
" Version:       2.0.1
" Modifications:
"  2.0.1 : Changed name of VAM addon-info file.
"  2.0   : Support for autoloading.
"  1.1   : Maximum number of arguments is now a parameter with default
"          value 10 (the original value). This can now be modified to
"          allow for the formating of more than 10 arguments.
"          Maximum number of lines to search for the first non-white space
"          character is now a parameter with default value 2 (the original
"          value). One is not likely to ever need to increase this value.
"  1.0 : initial public release.
"
" Tested on vim 7.2 on Linux

" ============================================================================
" Description: 
" ============================================================================
"
" Installation:
" 
" The {Format} autoload 'format.vim' code file should be in the 'autoload/scala'
" directory, the 'format.txt' in the 'doc/scala' directory and the plugin
" 'format.vim' code in the 'plugin/scala' directory.
"
" Usage:
"
" Place the cursor on any character in the method name or on the
" methods left paren, '(', and then invoke this script. If you 
" use the binding above, you would enter <Leader>f.
"
" The script finds the first non-white-space character after the
" method's left paren and uses that as the character position for
" aligning all arguments. 
"
" Examples of method calls:
"
"    m1(thisIsArgOne, thisIsArgTwo, thisIsArgThree(), thisIsArgFour): Sometype = {
"      ....
"    }
"
" becomes
"
"    m1(thisIsArgOne, 
"       thisIsArgTwo, 
"       thisIsArgThree(), 
"       thisIsArgFour): Sometype = {
"      ....
"    }
"
" and the following (note first argument position):
"
"    aVeryLongMethodNameAsAnExampleUsage(
"                            thisIsArgOne, thisIsArgTwo, thisIsArgThree, thisIsArgFour): Sometype = {
"      ....
"    }
"
" becomes
"
"    aVeryLongMethodNameAsAnExampleUsage(
"                            thisIsArgOne, 
"                            thisIsArgTwo, 
"                            thisIsArgThree, 
"                            thisIsArgFour): Sometype = {
"      ....
"    }
"
" becomes (with g:scala_format_extra_arg_offset = 2)
"
"    aVeryLongMethodNameAsAnExampleUsage(
"                            thisIsArgOne, 
"                              thisIsArgTwo, 
"                              thisIsArgThree, 
"                              thisIsArgFour): Sometype = {
"      ....
"    }
"
" Generally, in this case you can change the location of the first
" method argument and reformat and it works (the rest of the arguments
" are aligned under the first argument).
"
" Examples of method calls with string arguments:
"
"    m1(thisIsArgOne, "this is" + somestring + "a \"foo()\" test", thisIsArgThree): Sometype = {
"      ....
"    }
"
" becomes (with let g:scala_format_extra_string_arg_offset = 0)
"
"    m1(thisIsArgOne, 
"       "this is" + 
"       somestring + 
"       "a \"foo()\" test", 
"       thisIsArgThree): Sometype = {
"      ....
"    }
"
" or becomes (with let g:scala_format_extra_string_arg_offset = 2)
"
"    m1(thisIsArgOne, 
"       "this is" + 
"         somestring + 
"         "a \"foo()\" test", 
"       thisIsArgThree): Sometype = {
"      ....
"    }
"
" Yea, it can actually do this. 
"
" One more example of a method where an argument is itself a method call:
"
"    m1(thisIsArgOne, thisIsArgTwo(innerOne, innerTwo), thisIsArgThree()): Sometype = {
"      ....
"    }
"
" placing cursor on "m1(" and invoking this script becomes
"
"    m1(thisIsArgOne, 
"       thisIsArgTwo(innerOne, innerTwo), 
"       thisIsArgThree()): Sometype = {
"      ....
"    }
"
" then placing cursor on "thisIsArgTwo(" and invoking this script becomes
"
"    m1(thisIsArgOne, 
"       thisIsArgTwo(innerOne, 
"                    innerTwo), 
"       thisIsArgThree()): Sometype = {
"      ....
"    }
"
"
"
" Examples of method definitions:
"
"    def m1(thisIsArgOne: String, thisIsArgTwo: Int, thisIsArgThree: Float): Sometype = {
"      ....
"    }
"
" becomes
"
"    def m1(thisIsArgOne: String, 
"           thisIsArgTwo: Int, 
"           thisIsArgThree: Float): Sometype = {
"      ....
"    }
"
" and the following (note first argument position):
"
"    def aVeryLongMethodNameAsAnExampleUsage(
"                            thisIsArgOne: String, thisIsArgTwo: Int, thisIsArgThree: Float): Sometype = {
"      ....
"    }
"
" becomes
"
"    def aVeryLongMethodNameAsAnExampleUsage(
"                            thisIsArgOne: String, 
"                            thisIsArgTwo: Int, 
"                            thisIsArgThree: Float): Sometype = {
"      ....
"    }
"
" Array definition:
" As an unplanned extra, this can be used to format the arguments to an
" array:
"
"    val a = Array[Int] ( 1, 3, 4, 5, 4)
"
" becomes
"
"    val a = Array[Int] ( 1, 
"                         3, 
"                         4, 
"                         5, 
"                         4)
" and
"
"    val a = Array[Int] ( 
"              1, 3, 4, 5, 4)
"
" becomes
"
"    val a = Array[Int] ( 
"              1, 
"              3, 
"              4, 
"              5, 
"              4)
"
" Ok, so formating an array does not do too much.
"
" Comments:
"
"   Send any comments and/or bug reports/fixes to:
"       Richard Emberson <richard.n.embersonATgmailDOTcom>
" ============================================================================
" THE SCRIPT
" ============================================================================

" --------------------------------------------------------
" Entry point for this script
" --------------------------------------------------------
function! scala#format#Args()
    let l:save_cursor = getpos(".")
    let l:pos = col(".")
    set noautoindent
    set indentexpr=

" echo "FormatArgs: " . l:pos
" let x = input("p=")

    try        
      " get left paren
      let l:leftParenColLine = s:FindLeftParen()
      let l:leftparen = l:leftParenColLine[0]
      let l:line = l:leftParenColLine[1]
      if l:leftparen == -1
          call s:PrintErrorMsg("Could not find left paren")
          return
      endif
" echo "leftparen: " . l:leftparen
" echo "line: " . l:line

      " get first non-WS char after left paren
      let l:firstCharColLine = s:FindFirstChar(l:leftparen, l:line)
      let l:firstChar = l:firstCharColLine[0]
      let l:line = l:firstCharColLine[1]
      if l:firstChar == -1
          call s:PrintErrorMsg("Could not find first non-WS char")
          return
      endif

" echo "firstChar: " . l:firstChar
" echo "line: " . l:line
" let x = input("p=")

      let l:entrylist = s:BuildParenList(l:firstChar, l:line)
      
      if len(l:entrylist) > 0
        " call s:PrintParenList(l:entrylist)

        let entry = l:entrylist[0]
        let offset = entry['start'] - 1
        call s:FormatParenList(offset, l:entrylist)
      endif

    catch /.*/
      echohl WarningMsg
      echo v:exception
      echohl None
    endtry                                         
    call setpos('.', l:save_cursor)

endfunction

"
" format: a.b.c.d
"
function! scala#format#MethodChain()
    let l:save_cursor = getpos(".")
    let l:pos = col(".")
    set noautoindent
    set indentexpr=

    try        
      " get period
      let l:dotColLine = s:FindDot()
      let l:pos = l:dotColLine[0]
      let l:line = l:dotColLine[1]
      if l:pos == -1
          call s:PrintErrorMsg("Could not find chain method period")
          return
      endif

      let l:dotList = s:BuildDotList(l:pos, l:line)
      
" echo "len(dotList)=" . len(l:dotList)
" let x = input("p=")
      if len(l:dotList) > 0
" call s:PrintParenList(l:dotList)
" let x = input("p=")
        let entry = l:dotList[0]
        let offset = entry['start'] - 1
        call s:FormatParenList(offset, l:dotList)
      endif

    catch /.*/
      echohl WarningMsg
      echo v:exception
      echohl None
    endtry                                         
    call setpos('.', l:save_cursor)
endfunction

"
" format: "a" + "b" + "c" + "d"
"
function! scala#format#String()
    let l:save_cursor = getpos(".")
    let l:pos = col(".")
    set noautoindent
    set indentexpr=

" echo "FormatString: " . l:pos
" let x = input("p=")

    try        
      " get left paren
      let l:dqColLine = s:FindDQuote()
      let l:pos = l:dqColLine[0]
      let l:line = l:dqColLine[1]
      if l:pos == -1
          call s:PrintErrorMsg("Could not find left paren")
          return
      endif
" echo "pos: " . l:pos
" echo "line: " . l:line
" let x = input("p=")


      let l:slist = s:BuildStringList(l:pos, l:line)
" let x = input("p=")
      
      if len(l:slist) > 0
        " call s:PrintParenList(l:slist)

        let entry = l:slist[0]
        let offset = entry['start'] - 1
        call s:FormatParenList(offset, l:slist)
      endif

    catch /.*/
      echohl WarningMsg
      echo v:exception
      echohl None
    endtry                                         
    call setpos('.', l:save_cursor)

endfunction



" --------------------------------------------------------
" list of entries
" each entry is:
"        type, isnewline, line, start, end,
" each entry type is:
"        arg
"        argdef
"        textstart 
"        textmiddle
"        textend
" 
" list of length 0 is failure
" --------------------------------------------------------
function! s:BuildParenList(initialPos, lineNos)
    let currentPos = a:initialPos
    let currentLine = a:lineNos
    let maxLine = currentLine + g:scala_format_max_number_args
    let isnewline = s:IS_FALSE

    let parenDepth = 0
    let type = 'arg'
    let isSTR = s:IS_FALSE
    let inSTR = s:IS_FALSE
    let nonWS = s:IS_FALSE
    let bracketDepth = 0

    let emptylist = []

    let entrylist = []

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      " consume start-of-line WS
      let c = strpart(text, currentPos, 1)
      while c == ' ' && currentPos <= textLen
        let currentPos = currentPos + 1
        let c = strpart(text, currentPos, 1)
      endwhile
      let start = currentPos

" echo 'currentLine: ' . currentLine
" echo 'text: ' . text

      while currentPos <= textLen
        let c = strpart(text, currentPos - 1, 1)
" echo 'c: ' . c

        if bracketDepth > 0
          if c == ']' 
            let bracketDepth = bracketDepth - 1
          endif
        elseif c == '[' && isSTR == s:IS_FALSE
            let bracketDepth = bracketDepth + 1

        elseif isSTR == s:IS_TRUE
" echo 'IS_STR'
          if inSTR == s:IS_TRUE
            if c == '\' 
              let cc = strpart(text, currentPos, 1)
" echo 'cc: ' . cc
              if cc == '"' 
                let currentPos = currentPos + 1
              endif
            elseif c == '"' 
              let inSTR = s:IS_FALSE
            endif

          else
            if c == ','
              " type, line, start, end,
              let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
              call add(entrylist, entry)
" echo 'add entry 1'
              let start = currentPos + 1
              let nonWS = s:IS_FALSE
              let isSTR = s:IS_FALSE
              let type = 'arg'
              let isnewline = s:IS_FALSE

            elseif c == '('
              let parenDepth = parenDepth + 1

            elseif c == ')' && parenDepth > 0
              let parenDepth = parenDepth - 1

            elseif c == '"' 
              let inSTR = s:IS_TRUE

            elseif c == '+'
              let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
              call add(entrylist, entry)
" echo 'add entry 2'

              let c = strpart(text, currentPos, 1)
              while c == ' ' && currentPos <= textLen
                let currentPos = currentPos + 1
                let c = strpart(text, currentPos, 1)
              endwhile

              let start = currentPos + 1
              let nonWS = s:IS_FALSE
              let type = 'textmiddle'
              let isnewline = s:IS_FALSE

            elseif c == ')'
              if type != 'textstart'
                let type = 'textend'
              endif
              let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
              call add(entrylist, entry)
" echo 'add entry 3'
              return entrylist

            elseif c == ' ' && nonWS == s:IS_FALSE && isnewline == s:IS_TRUE
              " let start = start + 1

            else
              let nonWS = s:IS_TRUE

            endif
          endif

        else
" echo 'NORMAL'
          if c == ',' && parenDepth == 0
            " type, isnewline, line, start, end,
            let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
            call add(entrylist, entry)
" echo 'add entry 4'

            let start = currentPos + 1
            let nonWS = s:IS_FALSE
            let type = 'arg'
            let isnewline = s:IS_FALSE

          elseif c == '"' && isSTR == s:IS_FALSE && parenDepth == 0
            let inSTR = s:IS_TRUE
            let isSTR = s:IS_TRUE
            let type = 'textstart'

          elseif c == ':'
            let type = 'argdef'

          elseif c == '('
            let parenDepth = parenDepth + 1

          elseif c == ')' && parenDepth > 0
            let parenDepth = parenDepth - 1

          elseif c == ')'
            let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
            call add(entrylist, entry)
" echo 'add entry 5'
            return entrylist

          elseif c == ' ' && nonWS == s:IS_FALSE
            let start = start + 1

          else
            let nonWS = s:IS_TRUE

          endif
        endif

        let currentPos = currentPos + 1
      endwhile

      let currentLine = currentLine + 1
      let currentPos = 1
      let isnewline = s:IS_TRUE
    endwhile

    return emptylist 
endfunction

" --------------------------------------------------------
" list of entries
" each entry is:
"        type, isnewline, line, start, end,
" each entry type is:
"        arg
"        argdef
"        textstart 
"        textmiddle
"        textend
" 
" list of length 0 is failure
" --------------------------------------------------------
function! s:BuildDotList(initialPos, lineNos)
    let currentPos = a:initialPos
    let currentLine = a:lineNos
    let maxLine = currentLine + g:scala_format_max_number_args
    let isnewline = s:IS_FALSE

    let type = 'arg'
    let isSTR = s:IS_FALSE
    let inSTR = s:IS_FALSE
    let nonWS = s:IS_FALSE
    let parenDepth = 0
    let bracketDepth = 0

    let endentry = {}
    let emptylist = []

    let entrylist = []


    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      " consume start-of-line WS
      let c = strpart(text, currentPos, 1)
      while c == ' ' && currentPos <= textLen
        let currentPos = currentPos + 1
        let c = strpart(text, currentPos, 1)
      endwhile
      let start = currentPos

" echo 'currentLine: ' . currentLine
" echo 'text: ' . text
" echo 'c: ' . c

      if c != '.'
        call add(entrylist, endentry)
" echo 'add entry 0'
        return entrylist
      endif

      while currentPos <= textLen
        let c = strpart(text, currentPos, 1)
" echo 'c: ' . c

        if c == ']' && bracketDepth > 0 && isSTR == s:IS_FALSE
          let bracketDepth = bracketDepth - 1
        elseif c == '[' && isSTR == s:IS_FALSE
          let bracketDepth = bracketDepth + 1
        elseif c == ')' && parenDepth > 0 && isSTR == s:IS_FALSE
          let parenDepth = parenDepth - 1
        elseif c == '(' && isSTR == s:IS_FALSE
          let parenDepth = parenDepth + 1

        elseif isSTR == s:IS_TRUE
" echo 'IS_STR'
          if inSTR == s:IS_TRUE
            if c == '\' 
              let cc = strpart(text, currentPos, 1)
" echo 'cc: ' . cc
              if cc == '"' 
                let currentPos = currentPos + 1
              endif
            elseif c == '"' 
              let inSTR = s:IS_FALSE
            endif

          else
            " inSTR == FALSE
            " TODO correct
            if c == '.'
              " type, line, start, end,
              let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
              call add(entrylist, entry)
" echo 'add entry 1'
              let start = currentPos + 1
              let nonWS = s:IS_FALSE
              let isSTR = s:IS_FALSE
              let type = 'arg'
              let isnewline = s:IS_FALSE

            elseif c == '"' 
              let inSTR = s:IS_TRUE

            elseif c == ' ' && nonWS == s:IS_FALSE && isnewline == s:IS_TRUE
              " let start = start + 1

            else
              let nonWS = s:IS_TRUE

            endif
          endif

        else
" echo 'NORMAL'
          if c == '.' && parenDepth == 0
            " type, isnewline, line, start, end,
            let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
            call add(entrylist, entry)
" echo 'add entry 4'

            let start = currentPos + 1
            let nonWS = s:IS_FALSE
            let type = 'arg'
            let isnewline = s:IS_FALSE

          elseif c == '"' && isSTR == s:IS_FALSE && parenDepth == 0
            let inSTR = s:IS_TRUE
            let isSTR = s:IS_TRUE
            let type = 'textstart'

          elseif c == ' ' && nonWS == s:IS_FALSE
            let start = start + 1

          else
            let nonWS = s:IS_TRUE

          endif
        endif

        let currentPos = currentPos + 1
      endwhile
      let endentry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}

      let currentLine = currentLine + 1
      let currentPos = 0
      let isnewline = s:IS_TRUE
    endwhile

    return emptylist 
endfunction

" --------------------------------------------------------
" list of entries
" each entry is:
"        type, isnewline, line, start, end,
" each entry type is:
"        arg
"        argdef
"        textstart 
"        textmiddle
"        textend
" 
" list of length 0 is failure
" --------------------------------------------------------
function! s:BuildStringList(initialPos, lineNos)
    let currentPos = a:initialPos
    let currentLine = a:lineNos
    let maxLine = currentLine + g:scala_format_max_number_args
    let isnewline = s:IS_FALSE

    let type = 'textstart'
    let isSTR = s:IS_FALSE
    let inSTR = s:IS_FALSE
    let nonWS = s:IS_FALSE
    let continue = s:IS_FALSE

    let emptylist = []

    let entrylist = []

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      let continue = s:IS_FALSE

      " consume start-of-line WS
      let c = strpart(text, currentPos, 1)
      while c == ' ' && currentPos <= textLen
        let currentPos = currentPos + 1
        let c = strpart(text, currentPos, 1)
      endwhile
      let start = currentPos

" echo 'currentLine: ' . currentLine
" echo 'text: ' . text

      while currentPos <= textLen
        let c = strpart(text, currentPos - 1, 1)
" echo 'c: ' . c

        if inSTR == s:IS_TRUE
          let continue = s:IS_FALSE
          if c == '\' 
            let cc = strpart(text, currentPos, 1)
" echo 'cc: ' . cc
            if cc == '"' 
              let currentPos = currentPos + 1
            endif
          elseif c == '"' 
            let inSTR = s:IS_FALSE
          endif

        else
          if c == '"' 
            let inSTR = s:IS_TRUE

          elseif c == '+'
            let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
            call add(entrylist, entry)
" echo 'add entry 1'

            let c = strpart(text, currentPos, 1)
            while c == ' ' && currentPos <= textLen
              let currentPos = currentPos + 1
              let c = strpart(text, currentPos, 1)
            endwhile

            let start = currentPos + 1
            let nonWS = s:IS_FALSE
            let type = 'textmiddle'
            let isnewline = s:IS_FALSE

            let continue = s:IS_TRUE

          elseif c == ' ' && nonWS == s:IS_FALSE && isnewline == s:IS_TRUE
            " let start = start + 1

          else
            let nonWS = s:IS_TRUE
            let continue = s:IS_FALSE

          endif
        endif

        let currentPos = currentPos + 1
      endwhile

      if continue == s:IS_FALSE
        if type != 'textstart'
          let type = 'textend'
        endif
        let entry = {'type': type, 'isnewline': isnewline, 'line': currentLine, 'start': start, 'end': currentPos - 1}
        call add(entrylist, entry)
        return entrylist
      endif

      let currentLine = currentLine + 1
      let currentPos = 1
      let isnewline = s:IS_TRUE
    endwhile

    return emptylist 
endfunction

" --------------------------------------------------------
" Finds first non-white-space character after the 
" methods starting, left paren 
"   returns a list 
"     where first element is position
"     and second element is line
" --------------------------------------------------------
function! s:FindFirstChar(leftparen, line)
    let currentPos = a:leftparen + 1
    let currentLine = a:line
    let maxLine = currentLine + g:scala_format_max_line_search_after_method_start

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      while currentPos <= textLen
        let c = strpart(text, currentPos - 1, 1)
        if c != ' '
            return [currentPos, currentLine]
        endif

        let currentPos = currentPos + 1
      endwhile

      let currentLine = currentLine + 1
      let currentPos = 1
    endwhile

    return [-1, currentLine]
endfunction


" --------------------------------------------------------
" Finds the methods starting, left paren 
"   returns a list 
"     where first element is position
"     and second element is line
" --------------------------------------------------------
function! s:FindLeftParen()
    let currentPos = col(".")
    let currentLine = line(".")
    let maxLine = currentLine + g:scala_format_max_line_search_after_method_start

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      while currentPos <= textLen 
        let c = strpart(text, currentPos - 1, 1)
" echo "char: " . c
" let x = input("p=")
        if c == '('
          return [currentPos, currentLine]
        endif
        let currentPos = currentPos + 1
      endwhile

      let currentLine = currentLine + 1
      let currentPos = 1
    endwhile


    return [-1, currentLine]
endfunction

" --------------------------------------------------------
" Finds the first comma
"   returns a list 
"     where first element is position
"     and second element is line
" --------------------------------------------------------
function! s:FindDot()
    let currentPos = col(".")
    let currentLine = line(".")
    let maxLine = currentLine + g:scala_format_max_line_search_after_method_start

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      while currentPos <= textLen 
        let c = strpart(text, currentPos - 1, 1)
        if c == '.'
          return [currentPos -1, currentLine]
        endif
        let currentPos = currentPos + 1
      endwhile

      let currentLine = currentLine + 1
      let currentPos = 1
    endwhile

    return [-1, currentLine]
endfunction

" --------------------------------------------------------
" Finds the first DoubleQuote 
"   returns a list 
"     where first element is position
"     and second element is line
" --------------------------------------------------------
function! s:FindDQuote()
    let currentPos = col(".")
    let currentLine = line(".")
    let maxLine = currentLine + g:scala_format_max_line_search_after_method_start

    while currentLine < maxLine
      let text = getline(currentLine)
      let textLen = len(text)

      while currentPos <= textLen 
        let c = strpart(text, currentPos - 1, 1)
" echo "char: " . c
" let x = input("p=")
        if c == '"'
          return [currentPos, currentLine]
        endif
        let currentPos = currentPos + 1
      endwhile

      let currentLine = currentLine + 1
      let currentPos = 1
    endwhile

    return [-1, currentLine]
endfunction

" --------------------------------------------------------
" Format the method arguments
" --------------------------------------------------------
function! s:FormatParenList(offset, entrylist)
    let index = len(a:entrylist) - 1
    while index > 0
      let entry = a:entrylist[index]

      let type = entry['type']
      let start = entry['start']
      let isnewline = entry['isnewline']
      let line = entry['line']

      if type == 'arg'
        let offset = a:offset
      elseif type == 'argdef'
        let offset = a:offset
      elseif type == 'textstart'
        let offset = a:offset
      elseif type == 'textmiddle'
        let offset = a:offset + g:scala_format_extra_string_arg_offset
      elseif type == 'textend'
        let offset = a:offset + g:scala_format_extra_string_arg_offset
      else
        throw "Unknown argument type: " . type
      endif
      if index == 1
        let offset = offset + g:scala_format_extra_arg_offset
      endif

      if isnewline == s:IS_TRUE
        execute ":normal ". line . "G"
        execute ":normal 0"
        if start > 1
          execute ":normal dw"
        endif
        execute ":normal " . offset . "i "
      else
        let start = start - 1

        execute ":normal ". line . "G"
        execute ":normal 0"
        execute ":normal ". start . "l"
        execute ":normal i"
        execute ":normal " . offset . "i "
      endif

      let index = index - 1
    endwhile 
endfunction


function! s:Trim(string)
  return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:PrintParenList(entrylist)
    let index = 0
    while index < len(a:entrylist)
      let entry = a:entrylist[index]

      echo 'type: ' . entry['type']
      echo 'isnewline: ' . entry['isnewline']
      echo 'line: ' . entry['line']
      echo 'start: ' . entry['start']
      echo 'end: ' . entry['end']

      let index = index + 1 
    endwhile 
endfunction

function! s:PrintErrorMsg(msg)
    echohl WarningMsg
    echo "Error: " . a:msg
    echohl None
endfunction
