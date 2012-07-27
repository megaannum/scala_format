
" Options
" let g:scala_format_extra_string_arg_offset = 2
" let g:scala_format_extra_arg_offset = 0
" let s:scala_format_max_number_args = 15
" let g:scala_format_max_line_search_after_method_start = 2

autocmd FileType scala map <Leader>fa :call scala#format#Args()<CR>
autocmd FileType scala map <Leader>fc :call scala#format#MethodChain()<CR>
autocmd FileType scala map <Leader>fs :call scala#format#String()<CR>

