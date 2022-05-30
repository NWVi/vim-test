if !exists('g:test#csharp#xunit#file_pattern')
  let g:test#csharp#xunit#file_pattern = '\v\.cs$'
endif

function! test#csharp#xunit#test_file(file) abort
  if fnamemodify(a:file, ':t') =~# g:test#csharp#xunit#file_pattern
    if exists('g:test#csharp#runner')
      return g:test#csharp#runner ==# 'xunit'
    endif
    return 1
  endif
endfunction

function! test#csharp#xunit#build_position(type, position) abort
  let file = a:position['file']
  let filename = fnamemodify(file, ':t:r')
  let project_path = test#csharp#get_project_path(file)
  let name = test#base#nearest_test(a:position, g:test#csharp#patterns, { 'namespaces_with_same_indent': 1 })
  let namespace = join(name['namespace'], '.')
  let test_name = join(name['test'], '.')
  let nearest_test = join([namespace, test_name], '.')

  if a:type ==# 'nearest'
    if !empty(test_name)
      return [project_path, '--filter', 'FullyQualifiedName=' . nearest_test]
    else
      if !empty(namespace)
        return [project_path, '--filter', 'FullyQualifiedName~' . namespace]
      else
        return [project_path]
      endif
    endif
  elseif a:type ==# 'file'
    throw 'file tests is not supported for dotnettest'
  elseif a:type ==# 'suite'
    if !empty(project_path)
      return [project_path]
    else
      return []
    endif
  endif
endfunction

function! test#csharp#xunit#build_args(args) abort
  let l:args = a:args
  call insert(l:args, '--nologo --verbosity q')
  return [join(l:args, ' ')]
endfunction

function! test#csharp#xunit#executable() abort
  return 'dotnet test'
endfunction
