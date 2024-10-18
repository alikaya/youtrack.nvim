if exists('g:loaded_youtrack_nvim')
    finish
endif
let g:loaded_youtrack_nvim = 1

command! -nargs=0 YoutrackProjects lua require('youtrack').list_projects()
command! -nargs=0 YoutrackTasks lua require('youtrack').list_tasks()
command! -nargs=0 YoutrackMyTasks lua require('youtrack').list_my_tasks()
command! -nargs=0 YoutrackCreateTask lua require('youtrack').create_task()
command! -nargs=0 YoutrackSearchTasks lua require('youtrack').search_tasks()
command! -nargs=0 YoutrackDashboard lua require('youtrack.ui.dashboard').open()
command! -nargs=0 YoutrackTimeTracker lua require('youtrack.time_tracker').toggle()
command! -nargs=0 YoutrackReport lua require('youtrack.reports').generate()
command! -nargs=1 YoutrackGitBranch lua require('youtrack.integrations.git').create_branch_from_task(<f-args>)
command! -nargs=1 YoutrackCommit lua require('youtrack.integrations.git').commit_with_task_id(<f-args>)
command! -nargs=0 YoutrackGoToTask lua require('youtrack.integrations.lsp').go_to_task()

if !exists('g:youtrack_no_default_mappings') || !g:youtrack_no_default_mappings
    nnoremap <silent> <leader>yp :YoutrackProjects<CR>
    nnoremap <silent> <leader>yt :YoutrackTasks<CR>
    nnoremap <silent> <leader>ym :YoutrackMyTasks<CR>
    nnoremap <silent> <leader>yc :YoutrackCreateTask<CR>
    nnoremap <silent> <leader>ys :YoutrackSearchTasks<CR>
    nnoremap <silent> <leader>yd :YoutrackDashboard<CR>
    nnoremap <silent> <leader>ytt :YoutrackTimeTracker<CR>
    nnoremap <silent> <leader>yr :YoutrackReport<CR>
    nnoremap <silent> <leader>yg :YoutrackGoToTask<CR>
endif

lua require('youtrack').setup()
