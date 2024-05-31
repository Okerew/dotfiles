function! s:run_file()
    let extension = expand('%:e') 
    let command = ''
    if extension ==# 'py'
        let command = 'python3'
    elseif extension ==# 'java'
        let command = 'java'
    elseif extension ==# 'js'
        let command = 'node'
    elseif extension ==# 'rs'
        let command = 'rustc'
    elseif extension ==# 'go'
        let command = 'go run'
    endif

    if !empty(command)
        let command .= ' %'  
        execute '!' . command  
    else
        echo 
    endif
endfunction

command! Run :call s:run_file()
