```
_____     ____  ______
\__  \   / ___\/  ___/
 / __ \_/ /_/  >___ \ 
(____  /\___  /____  >
     \//_____/     \/ 
```

# Silver searcher (AG) plugin for Vim
*A Vim plugin for the [silver searcher](https://github.com/ggreer/the_silver_searcher) or [ripgrep](https://github.com/BurntSushi/ripgrep) that focuses on   
clear display and easy navigation of the search results*  

### Installation   
Install via [pathogen](https://github.com/tpope/vim-pathogen), [vundle](https://github.com/gmarik/vundle), [plug](https://github.com/junegunn/vim-plug) or copy to the Vim directory  
The [ag](https://github.com/ggreer/the_silver_searcher) or [rg](https://github.com/BurntSushi/ripgrep) executable must be installed as well.  

### Usage
See the [docs](https://github.com/gabesoft/vim-ags/blob/master/doc/ags.txt) or press `u` (for usage) while in the search results window.  

### Using [ripgrep](https://github.com/BurntSushi/ripgrep) instead of [ag](https://github.com/ggreer/the_silver_searcher)  
Despite the name `vim-ags` works with `ripgrep` as well if configured as below:  
```vim
let g:ags_agexe = 'rg'

let g:ags_agargs = {
  \ '--column'         : ['', ''],
  \ '--line-number'    : ['', ''],
  \ '--context'        : ['g:ags_agcontext', '-C'],
  \ '--max-count'      : ['g:ags_agmaxcount', ''],
  \ '--heading'        : ['',''],
  \ '--smart-case'     : ['','-S'],
  \ '--color'          : ['always',''],
  \ '--colors'         : [['match:fg:green', 'match:bg:black', 'match:style:nobold', 'path:fg:red', 'path:style:bold', 'line:fg:black', 'line:style:bold'] ,''],
  \ }
```

### Sample Shortcut Mappings
```vim
" Search for the word under cursor
nnoremap <Leader>s :Ags<Space><C-R>=expand('<cword>')<CR><CR>
" Search for the visually selected text
vnoremap <Leader>s y:Ags<Space><C-R>='"' . escape(@", '"*?()[]{}.') . '"'<CR><CR>
" Run Ags
nnoremap <Leader>a :Ags<Space>
" Quit Ags
nnoremap <Leader><Leader>a :AgsQuit<CR>
```

### Notes  
Works with ag version >= 0.29.1 or ripgrep >= 11.0.2  

### Screenshots  
Here are a couple of screenshots of the search results window

#### View mode (with [lightline](https://github.com/itchyny/lightline.vim) integration)
<img src="https://github.com/gabesoft/vim-ags/raw/master/assets/screen-shot8.png" />

#### Edit mode
<img src="https://github.com/gabesoft/vim-ags/raw/master/assets/screen-shot6-edit-mode.png" />

### Similar Plugins
[ctrlsf](https://github.com/dyng/ctrlsf.vim)
