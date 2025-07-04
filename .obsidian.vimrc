" ~/.obsidian.vimrc

" ========================================
" Базовые настройки Vim
" ========================================
set relativenumber
set number
set ignorecase
set smartcase
set incsearch
set hlsearch
set clipboard=unnamedplus
set wrap

" ========================================
" Конфигурация Leader Hotkeys (важно!)
" ========================================
" 1. Установите плагин Leader Hotkeys через Community Plugins
" 2. В настройках плагина задайте желаемый лидер (например: Ctrl+b)
" 3. Все маппинги ниже используют формат <leader> + [клавиша]

" ========================================
" Основные маппинги через лидер
" ========================================

" Навигация между панелями (базовые, уже встроены в плагин)
" leader+j → фокус на нижнюю панель
" leader+k → фокус на верхнюю панель
" leader+h → фокус на левую панель
" leader+l → фокус на правую панель

" Дополнительные маппинги для навигации
nmap <leader>wh :action FocusLeftPane<CR>  " Аналог <C-w>h
nmap <leader>wl :action FocusRightPane<CR> " Аналог <C-w>l

" ========================================
" Производительные команды
" ========================================

" Поиск и навигация
nmap <leader>ff :action QuickOpen<CR>      " Быстрый поиск файлов
nmap <leader>fg :action OpenGraph<CR>      " Показать граф знаний
nmap <leader>ft :action OpenTags<CR>       " Показать теги
nmap <leader>fb :action OpenBacklinks<CR>  " Показать обратные ссылки

" Работа с текстом
nmap <leader>cc :action ToggleComment<CR>  " Комментирование (требует плагин)
vmap <leader>cc :action ToggleComment<CR>
nmap <leader>tb :action ToggleBold<CR>     " Жирный текст (****)
nmap <leader>ti :action ToggleItalic<CR>   " Курсив (__)

" Ссылки и вложения
nmap <leader>ll :action CreateLink<CR>     " Создать ссылку
nmap <leader>li :action InsertImage<CR>    " Вставить изображение
nmap <leader>lc :action InsertCodeBlock<CR>" Вставить код-блок

" Вкладки
nmap <leader>tn :action NewTab<CR>         " Новая вкладка
nmap <leader>tc :action CloseTab<CR>       " Закрыть вкладку

" ========================================
" Продвинутые workflow
" ========================================

" Git-интеграция (требует плагин Obsidian Git)
nmap <leader>gg :action ObsidianGit:CommitAll<CR>
nmap <leader>gp :action ObsidianGit:Pull<CR>
nmap <leader>gP :action ObsidianGit:Push<CR>

" QuickAdd (требует плагин QuickAdd)
nmap <leader>qa :action QuickAdd:RunQuickAdd<CR>
nmap <leader>qn :action QuickAdd:CaptureNote<CR>

" Шаблоны (требует плагин Templates)
nmap <leader>tt :action Templates:InsertTemplate<CR>

" ========================================
" Кастомные команды
" ========================================

" Переключение темы
nmap <leader>th :action ToggleDarkLight<CR>

" Панель инструментов
nmap <leader>tw :action ToggleSidebars<CR>

" Режим презентации
nmap <leader>pp :action Presentation:Start<CR>

" ========================================
" Выход из Vim-режима
" ========================================
imap jj <Esc>

