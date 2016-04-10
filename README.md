#vim-jsx-utils
Plugin with some utilities to folks who work with **[JSX](https://facebook.github.io/jsx/)** on Vim.

:warning: This plugin only expose a [set of functions](#functions). You need create your own mappings to this, like:

```
nnoremap <leader>ja :call JSXEncloseReturn()<CR>
nnoremap <leader>ji :call JSXEachAttributeInLine()<CR>
nnoremap <leader>je :call JSXExtractPartialPrompt()<CR>
```

:warning: All functions must be invoked on the first component line.

##Installation
You can install this plugin with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/VundleVim/Vundle.vim) and other plugin loaders.

##Functions

###JSXEncloseReturn
![](examples/enclose-vim.gif)

###JSXEachAttributeInLine
![](examples/eachline-vim.gif)

###JSXExtractPartialPrompt
:warning: Only ES6 classes

![](examples/partial-vim.gif)

-------
Samuel Simões ~ [@samuelsimoes](https://twitter.com/samuelsimoes) ~ [Blog](http://blog.samuelsimoes.com/)
