" Automatically install Vim Plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/bundle')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-obsession'

Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'

Plug 'neovim/nvim-lspconfig'
Plug 'vim-syntastic/syntastic'

Plug 'tmhedberg/SimpylFold'
Plug 'mesonbuild/meson', { 'rtp': 'data/syntax-highlighting/vim' }
Plug 'rust-lang/rust.vim'
Plug 'Matt-Deacalion/vim-systemd-syntax'
Plug 'sloboste/vim-groovy-syntax'
Plug 'chrisbra/vim-kconfig'
Plug 'thomafred/kermitSyntax', { 'rtp': 'vim' }

call plug#end()

" Normal vim options
set mouse=a
set splitright
set relativenumber
set number
set colorcolumn=100
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set textwidth=100
set fo+=t  " Autowrap at 80+ chars
syntax on
filetype plugin indent on
set updatetime=100

set wildmode=longest,list

" No ex mode
nnoremap Q <Nop>

" Don't tab complete on these files
set wildignore+=*.o,*.a,*.pyc,*.su
set wildignore+=*.swp,*~,*.tmp
set wildignore+=*.zip,*.tar.gz
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
set wildignore+=.git,.svn,.hg

" FIXME check if language server is sufficient
" Tell ctags to look for tags file in directories above if not found in current
set tags=tags;/
" autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/
" autocmd BufWrite *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" <bar> redraw!
" autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi

" Let modified buffers stay around in the background
set hidden

" Solarized color scheme
set termguicolors
set background=dark
colorscheme solarized

" FIXME investigate python language server and disable syntastic
" NO Syntastic on these filetypes
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["c", "cc", "cpp", "h", "hpp", "rs", "rust"]}

" Syntastic status line
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Syntastic Python
let g:syntastic_python_pylint_exec = 'pylint'
" let g:syntastic_python_pylint_args = ['--rc-file=.pylintrc']
let g:syntastic_python_checkers = ['pylint']

" Syntastic TCL
let g:syntastic_tcl_nagelfar_exec = 'nagelfar.tcl'
let g:syntastic_tcl_checkers = ['nagelfar']

" Syntastic Markdown
let s:mdl_style_path = join(
    \ [fnamemodify(expand('<sfile>:p'), ':p:h'),
    \  "mdl-style.rb"],
    \ '/')
let g:syntastic_markdown_mdl_args = ["--style", s:mdl_style_path]

" Syntastic shell
let g:syntastic_sh_checkers = ['shellcheck']
let g:syntastic_bash_checkers = ['shellcheck']
let g:syntastic_sh_shellcheck_args = '-x'
let g:syntastic_bash_shellcheck_args = '-x'

" Airline
set noshowmode
set laststatus=2  " Always show status line
let g:airline_extensions = ['branch', 'tabline', 'syntastic', 'wordcount', 'whitespace']
let g:airline_powerline_fonts = 1
let g:airline_exclude_preview = 1
let airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
function GetVirtualEnv()
    return '('.fnamemodify($VIRTUAL_ENV, ':t').')'
endfunction
call airline#parts#define_condition('virtualenv', '&filetype =~# "python"')
call airline#parts#define_function('virtualenv', 'GetVirtualEnv')
let g:airline_section_c = airline#section#create_left([
    \ '%{ObsessionStatus(''Session active'', ''No session'')}',
    \ 'virtualenv'])
let g:airline_section_z = airline#section#create_right(['C:%2c', '%3.5p%%'])
let g:airline#extensions#default#layout = [
    \ [ 'a', 'b', 'c' ],
    \ [ 'z', 'error', 'warning' ]
    \ ]

" IndentLine color
let g:indentLine_color_term = 0
let g:indentLine_fileTypeExclude = ['markdown']
let g:vim_json_syntax_conceal = 0

" Language Server syntax checking
lua << EOF
    require'lspconfig'.clangd.setup{}
EOF

" Don't start the language client if we see a special file.
let g:LanguageClient_autoStart = empty(glob(".disable_neovim_language_client"))

" FIXME?
" nnoremap <silent> <C-]> :call LanguageClient_textDocument_definition()<CR>

" SimpylFold better Python code folding
let g:SimpylFold_fold_import = 0
let g:SimpylFold_fold_docstring = 0
let g:SimpylFold_docstring_preview = 1

" Rust
let g:rust_recommended_style = 1
