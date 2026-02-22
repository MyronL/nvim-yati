set noswapfile
set directory=""
set display=lastline

set packpath+=./deps
set rtp+=.

set shiftwidth=2
set expandtab

packloadall

lua << EOF
require("nvim-yati").setup({})
-- require("nvim-yati.debug").toggle()
EOF
