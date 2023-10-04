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

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

Plug 'neovim/nvim-lspconfig'
Plug 'vim-syntastic/syntastic'

Plug 'tmhedberg/SimpylFold'
Plug 'mesonbuild/meson', { 'rtp': 'data/syntax-highlighting/vim' }
Plug 'rust-lang/rust.vim'
Plug 'Matt-Deacalion/vim-systemd-syntax'
Plug 'sloboste/vim-groovy-syntax'
Plug 'chrisbra/vim-kconfig'
Plug 'thomafred/kermitSyntax', { 'rtp': 'vim' }
Plug 'kergoth/vim-bitbake'
Plug 'tomlion/vim-solidity'

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

" Tell ctags to look for tags file in directories above if not found in current.
set tags=tags;/

" Let modified buffers stay around in the background
set hidden

" Solarized color scheme
set termguicolors
set background=dark
colorscheme solarized
nnoremap <C-C><C-C> <cmd>let &background = ( &background == "dark"? "light" : "dark" )<cr>

" Indentline is stupid and conceals quotes
autocmd filetype dockerfile let g:indentLine_setConceal=0

" Force newstyle comments. Not sure what plugin is reverting this.
autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s

" No Syntastic on these filetypes
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["c", "cc", "cpp", "h", "hpp", "cuda", "python", "rs", "rust"]}

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

" SimpylFold better Python code folding
let g:SimpylFold_fold_import = 0
let g:SimpylFold_fold_docstring = 0
let g:SimpylFold_docstring_preview = 1

" Rust
let g:rust_recommended_style = 1

" Language Server syntax checking
lua << EOF
    -- Mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    local opts = { noremap=true, silent=true }
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        -- vim.keymap.set(
        --     'n',
        --     '<space>wl',
        --     function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        --     bufopts
        -- )
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
    end

    local lsp_flags = {
        -- This is the default in Nvim 0.7+
        debounce_text_changes = 150,
    }
    require('lspconfig')['clangd'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require('lspconfig')['rust_analyzer'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        -- Server-specific settings...
        settings = {
            ["rust-analyzer"] = {}
        }
    }
    require('lspconfig')['pyright'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    -- Install: https://solang.readthedocs.io/en/latest/installing.html#option-2-download-release-binaries
    require('lspconfig').solang.setup{
        on_attach = on_attach,
        flags = lsp_flags,
        cmd = {
            "solang",
            "language-server",
            "--target", -- FIXME dynamically change target?
            "evm",
        },
    }
    -- Install: `npm install -g typescript typescript-language-server`
    require('lspconfig').tsserver.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
EOF

" Pickers
lua << EOF
    local default_picker_opts = {
        theme = "ivy",
        -- TODO Define a custom layout strategy that is bounded by the buffer window size not the
        -- overall window size, i.e., if we have a vertical split, keep the picker confined to the
        -- window from which it was opened.
        layout_strategy = "vertical",
        layout_config = {
            anchor = "CENTER",
            height = { padding = 0 },
            mirror = false,
            width = { padding = 0 },
        },
    }

    require('telescope').setup{
        defaults = {
            mappings = {
                i = {
                    -- actions.which_key shows the mappings for your picker.
                    ["<C-h>"] = "which_key"
                }
            }
        },
        pickers = {
            buffers = default_picker_opts,
            current_buffer_fuzzy_find = default_picker_opts,
            find_files = default_picker_opts,
            grep_string = default_picker_opts,
            help_tags = default_picker_opts,
            live_grep = default_picker_opts,
            man_pages = default_picker_opts,
        },
        extensions = {}
    }
EOF
" TODO move this config to lua
" Note that <C-_> is control plus forward slash.
nnoremap <C-_>b <cmd>Telescope buffers<cr>
nnoremap <C-_>/ <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <C-_>f <cmd>Telescope find_files<cr>
nnoremap <C-_>g* <cmd>Telescope grep_string<cr>
nnoremap <C-_>h <cmd>Telescope help_tags<cr>
nnoremap <C-_>gg <cmd>Telescope live_grep<cr>
nnoremap <C-_>m <cmd>Telescope man_pages<cr>
