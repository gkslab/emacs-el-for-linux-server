;;; Emacs設定管理

;;;;---- Leafのインストール ----
(prog1 "prepare leaf"
  (prog1 "package"
    (custom-set-variables
     '(package-archives '(("org"   . "https://orgmode.org/elpa/")
                          ("melpa" . "https://melpa.org/packages/")
			              ("melpa-stable" . "https://stable.melpa.org/packages/")
                          ("gnu"   . "https://elpa.gnu.org/packages/"))))
    (package-initialize))

  (prog1 "leaf"
    (unless (package-installed-p 'leaf)
      (unless (assoc 'leaf package-archive-contents)
        (package-refresh-contents))
      (condition-case err
          (package-install 'leaf)
        (error
         (package-refresh-contents)       ; renew local melpa cache if fail
         (package-install 'leaf))))

    (leaf leaf-keywords
      :ensure t
      :config (leaf-keywords-init)))

  (prog1 "optional packages for leaf-keywords"
    ;; optional packages if you want to use :hydra, :el-get,,,
    (leaf hydra :ensure t)
    (leaf blackout :ensure t)
    (leaf el-get :ensure t
      :custom ((el-get-git-shallow-clone  . t)))))

;;; Leaf設定用の設定読み込み
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom
    `((imenu-list-size . 30)
      (imenu-list-position . 'left))))

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory "~/.emacs.d/")
    (setq self-emacs-script-directory (concat user-emacs-directory "self-elisp/"))
    (setq template-directory (concat user-emacs-directory "auto-insert-templates/"))
    ))


;;;;;------ ここから設定 ------;;;

;;;;---- 基本の設定 ----

;;; SHELL変数の読み込み
(leaf shell-sync
  :preface
  (leaf exec-path-from-shell
    :ensure t
    :defun (exec-path-from-shell-initialize)
    :custom
    ((exec-path-from-shell-check-startup-files . nil)
     (exec-path-from-shell-arguments . nil))
    :config
    (exec-path-from-shell-initialize))
  (defun set-exec-path-from-shell-path ()
    (interactive)
    (let ((path-from-shell
           (replace-regexp-in-string "[ \t\n]*$" ""
                                     (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
      (setenv "PATH" path-from-shell)
      (setq exec-path (split-string path-from-shell path-separator))))
  (defun eshell-mode-hook-func ()
    (setq eshell-path-env (concat "/usr/local/bin:" eshell-path-env))
    (setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH"))))
  :config
  (set-exec-path-from-shell-path)
  :hook
  (eshell-mode-hook . 'eshell-mode-hook-func))



;;; カスタム変数の設定
(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom
  `(
    ;; カスタムバリアブルの設定を別ファイルに書き出して、それを無視する
    (custom-file . ,(locate-user-emacs-file "custom.el"))

    ;; 表示
    (ring-bell-function     . 'ignore)   ; ベル無効化
    (tab-width              . 4)    ;; tab 幅 4
    (indent-tabs-mode       . nil)  ;; tab ではインデントしない
    (save-abbrevs           . 'silent)
    (auto-fill-mode         . nil)
    (next-line-add-newlines . nil)  ;; バッファ終端で newline を入れない
    (read-file-name-completion-ignore-case . t)  ; 大文字小文字区別無し

    ;;; auto save
    (auto-save-default       . nil)
    (auto-save-timeout       . 15)
    (auto-save-interval      . 60)

    (history-length          . t)

    ;;; ゴミ箱あり？
    (delete-by-moving-to-trash . t)
    (trash-directory . "~/.Trash")

    ;;; ediff設定
    ;; コントロール用のバッファを同一フレーム内に表示
    (ediff-window-setup-function . 'ediff-setup-windows-plain)
    ;; diffのバッファを上下ではなく左右に並べる
    (ediff-split-window-function . 'split-window-horizontally)

    )
    :config
    (when (boundp 'load-prefer-newer)
      (setq load-prefer-newer t))
    ;; yes or no を y or n に
    (fset 'yes-or-no-p 'y-or-n-p)

    ;; スクロールやツールバーなどのCUIに不要なインタフェースを消す
    (scroll-bar-mode -1)
    (tool-bar-mode -1)
    (menu-bar-mode -1)
    )


;;; copy & paste
(leaf cus-edit
  :preface
  ;; コピーペースト
  ;; (defun copy-from-linux ()
  ;;   (shell-command-to-string "/usr/bin/xclip -selection clipboard -o"))
  ;; (defun paste-to-linux (text &optional push)
  ;;   (let ((process-connection-type nil))
  ;;     (let ((proc (start-process "/usr/bin/xclip -selection clipboard" "*Messages*" "/usr/bin/xclip -selection clipboard")))
  ;;       (process-send-string proc text)
  ;;       (process-send-eof proc))))
  (setq x-select-enable-clipboard t)
  :custom
  ;; コピーペーストをOSのクリップボードと同期
  ;; (interprogram-cut-function . 'paste-to-linux)
  ;; (interprogram-paste-function 'copy-from-linux)
  (x-select-enable-clipboard . t)
  )




;;; 起動時設定
(leaf startup
  :custom
  `((inhibit-startup-screen            . t)
    (inhibit-startup-message           . t)
    (inhibit-startup-echo-area-message . t)
    (initial-scratch-message           . nil)
    (initial-buffer-choice . (lambda () (get-buffer-create "*dashboard*")))
    )
  )

;;; 改ページのライン表示 
(leaf page-break-lines
  :ensure t
  :config (global-page-break-lines-mode))

;;; 起動時のダッシュボードバッファの設定
(leaf startup-dashboard
  :ensure dashboard
  :custom
  `((dashboard-items . '((recents  . 50)))
    (dashboard-page-separator . "\n\f\n"))
  :config
  (dashboard-setup-startup-hook)
  (set-fontset-font "fontset-default"
                    (cons page-break-lines-char page-break-lines-char)
                    (face-attribute 'default :family)))


;;; 現在行のハイライト
(leaf hl-line
  :hook
  ;;(emacs-startup-hook . global-hl-line-mode)
  )

;;; カッコの対応関係ハイライト
(leaf paren
  :custom
  ((show-paren-style  . 'mixed))
  :hook
  (emacs-startup-hook . show-paren-mode)
  )


;;; 複数タブ・Smartタブキーバインド
(leaf smart-tab-and-region
  :config
  (leaf multiple-cursors
    :ensure t
    :preface
    (global-unset-key (kbd "C-t"))
    :bind
    (("C-M-c" . mc/edit-lines)
     ("C-M-r" . mc/mark-all-in-region)
     ("C-t C-t" . mc/mark-next-like-this)
     ("C-t C-s" . mc/mark-all-like-this-dwim))
    )
  (leaf smart-region
    :ensure t))


;;; 行番号表示
(leaf line-number-mode
  :custom
  `((display-line-numbers-width-start . t))
  :hook
  (emacs-startup-hook . global-display-line-numbers-mode))

;;; ファイル変更に応じて再読み込み
(leaf autorevert
  :custom
  `(
    (auto-revert-interval . 0.1)
    (make-backup-files . nil)
    (auto-save-default . nil))
  :hook
  (emacs-startup-hook . global-auto-revert-mode)
  )

;;; セーブ履歴
(leaf savehist
  :custom
  `((savehist-file
     . ,(expand-file-name "history" user-emacs-directory)))
  :hook
  ((after-init-hook . savehist-mode))
  )

;;; オートセーブ
(leaf auto-save
  :custom
  `(
    ;; 1秒後に保存
    (auto-save-buffers-enhanced-interval . 1)
    ;; 特定のファイルのみ有効にする
    (auto-save-buffers-enhanced-include-regexps . '(".+")) ;全ファイル
    ;; 自動保存しないファイルやバッファ
    (auto-save-buffers-enhanced-exclude-regexps . '("^not-save-file" "\\.ignore$" "\\bookmarks$"))
    ;; Wroteのメッセージを抑制
    (auto-save-buffers-enhanced-quiet-save-p . t)
    ;; *scratch*も ~/.emacs.d/scratch に自動保存
    (auto-save-buffers-enhanced-save-scratch-buffer-to-file-p . t)
    (auto-save-buffers-enhanced-file-related-with-scratch-buffer
     . ,(expand-file-name "scratch" user-emacs-directory))
    )
  :config
  ;;(auto-save-buffers-enhanced-include-only-checkout-path t)
  ;;(auto-save-buffers-enhanced t)
  (run-with-idle-timer 3 t 'do-auto-save)
  )


;;; バッファの自動分割
(leaf shackle
  :ensure t
  :custom
  `(
    (shackle-lighter . "")
    (shackle-rules .
                   '(("*compilatoin*")
	                 ("*Help*" :align right :ratio 0.5)
	                 ("*undo-tree*" :ratio 0.3 :align right)
                     ("\\`\\*helm.*?\\*\\'" :regexp t :align below :size 0.4)
                     ;;("\\`\\*helm.*?\\*\\'" :regexp t :align below :size 0.4)
	                 ;; ("*helm mini*" :align below :ratio 0.4)
	                 ;; ("*helm kill ring*" :align below)
	                 ;;("\*helm" :regexp t :align below)
	                 ("*Org*" :regexp t :align below :ration 0.2)))
    )
  :config
  (shackle-mode t)
  (winner-mode t)
  :bind
  (("C-<" . winner-undo))
  )

;;; デフォルトファイルの場所
(leaf *change-default-file-location
  :custom
  `(;; url
    (url-configuration-directory
     . ,(expand-file-name "url" user-emacs-directory))
    ;; nsm
    (nsm-settings-file
     . ,(expand-file-name "nsm.data" user-emacs-directory))
    ;; bookmark
    (bookmark-default-file
     . ,(expand-file-name "bookmarks" user-emacs-directory))
    ;; eshell
    (eshell-directory-name
     . ,(expand-file-name "eshell" user-emacs-directory))
    )
  )

;;; モードラインにファイル名がかぶってるときにディレ名も表示
(leaf uniquify
  :custom
  ((uniquify-buffer-name-style . 'post-forward-angle-brackets)
   (uniquify-min-dir-content   . 1))
  )

;;;バッファのナローイング（一部分だけの見える化）
(leaf narrowing
  ;;コマンドはC-x n n / C-x n w
  :config
  (put 'narrow-to-region 'disabled nil))


;;; undo-redo
;; (leaf undo-redo
;;   :preface
;;   (global-unset-key (kbd "C-x u"))
;;   (global-unset-key (kbd "C-x C-u"))
;;   :custom
;;   `((undo-limit              . 600000)
;;     (undo-strong-limit       . 900000))
;;   :config
;;   (leaf undohist
;;     :ensure t
;;     :custom
;;     `(
;;       (undohist-ignored-files . '("/tmp/"))
;;       )
;;     :preface
;;     (when (eq system-type 'windows-nt)
;;       (defun make-undohist-file-name (file)
;;         (setq file (convert-standard-filename (expand-file-name file)))
;;         (if (eq (aref file 1) ?:)
;;             (setq file (concat "/"
;;                                "drive_"
;;                                (char-to-string (downcase (aref file 0)))
;;                                (if (eq (aref file 2) ?/)
;;                                    ""
;;                                  (if (eq (aref file 2) ?\\)
;;                                      ""
;;                                    "/"))
;;                                (substring file 2))))
;;         (setq file (expand-file-name
;;                     (subst-char-in-string
;;                      ?/ ?!
;;                      (subst-char-in-string
;;                       ?\\ ?!
;;                       (replace-regexp-in-string "!" "!!"  file)))
;;                     undohist-directory))))
;;     :custom `((volatile-highlights-mode .  t))
;;     :config (undohist-initialize)
;;     :bind (("C-_" . undo))

;;     )
;;   (leaf undo-tree
;;     :ensure t
;;     :bind (("C-x C-u" . undo-tree-visualize)
;;            ("C-x u" . undo-tree-visualize))
;;     :custom
;;     `((global-undo-tree-mode . t)
;;       (undo-tree-auto-save-history . t)
;;       (undo-tree-history-directory-alist . `(("." . ,(concat user-emacs-directory "undo-tree-hist")))))))


;;; ssh越しの編集
(leaf tramp
  :preface
  (setq tramp-persistency-file-name (expand-file-name "tramp" user-emacs-directory))
  :custom
  `((tramp-persistency-file-name
     . ,(expand-file-name "tramp" user-emacs-directory))
    (tramp-completion-reread-directory-timeout . nil)
    )
  :hook
  (kill-emacs-hook
   . (lambda ()
       (if (file-exists-p tramp-persistency-file-name)
           (delete-file tramp-persistency-file-name))))
  )


;;; key-chord（複数キーのコンビネーション）
;; (leaf key-chord
;;   :ensure t
;;   :custom
;;   `((key-chord-two-keys-delay . 0.04))
;;   :hook
;;   (emacs-startup-hook . `(key-chord-mode 1)))


;;; migemo(日本語でのインクリメンタルサーチ)
;; (leaf migemo
;;   :ensure t
;;   :custom
;;   `(
;;     (migemo-command . "/usr/bin/cmigemo")
;;     (migemo-options . '("-q" "--emacs")) 
;;     ;; Set your installed path
;;     (migemo-dictionary . "/usr/local/share/migemo/utf-8/migemo-dict")
;;     (migemo-user-dictionary . nil)
;;     (migemo-regex-dictionary . nil)
;;     (migemo-coding-system . 'utf-8-unix)
;;     )
;;   :hook
;;   (after-init-hook . migemo-init))


;;; auto-complete
(leaf auto-complete
  :ensure t
  :hook
  (after-init-hook . global-auto-complete-mode))


;;; 最近開いたファイル履歴
(leaf recentf
  :defun
  (recentf-save-list recentf-cleanup)
  :preface
  (leaf shut-up
    :ensure t
    :init
    (defvar shut-up-ignore t))
  ;;
  (defun recentf-save-list-silence ()
    "Shut up"
    (interactive)
    (let ((message-log-max nil))
      (shut-up (recentf-save-list)))
    (message ""))
  ;;
  (defun recentf-cleanup-silence ()
    "Shut up"
    (interactive)
    (let ((message-log-max nil))
      (shut-up (recentf-cleanup)))
    (message ""))
  ;;
  :init
  (leaf recentf-ext :ensure t)
  :hook
  ((after-init-hook . recentf-mode)
   (focus-out-hook  . recentf-save-list-silence)
   (focus-out-hook  . recentf-cleanup-silence))
  :custom
  `((recentf-save-file       . ,(expand-file-name "recentf" user-emacs-directory))
    (recentf-max-saved-items . 2000)
    (recentf-auto-cleanup    . 'never)
    (recentf-exclude         . '(".recentf"
                                 "bookmarks"
                                 )))
  )

;;; 閉じタグ
(leaf smartparens
  :ensure t
  :blackout t
  :defun (sp-pair)
  :hook (after-init-hook . smartparens-global-mode)
  :config
  (require 'smartparens-config)
  (sp-pair "<" ">" :actions '(wrap))
  (sp-pair "$" "$" :actions '(wrap))
  )

;;; カラーコードへの色付け
(leaf rainbow-mode
  :ensure t
  :blackout `((rainbow-mode . ,(format " %s" "\x1F308")))
  )

(leaf cursol
  :config
  (leaf transition-mark
    :custom
    (transient-mark-mode . t)
    )
  )

;;; mini-buffer
(leaf mini-buffer
  :config
  (progn
    ;;;時間をモードラインに表示
    (display-time)
    
    ;;;行・列番号を表示
    (column-number-mode t)
    (line-number-mode t)
    ))


;;; window-resiser
(leaf window-resize
  :preface
  (defun window-resizer ()
    "Control window size and position."
    (interactive)
    (let ((window-obj (selected-window))
          (current-width (window-width))
          (current-height (window-height))
          (dx (if (= (nth 0 (window-edges)) 0) 1
                -1))
          (dy (if (= (nth 1 (window-edges)) 0) 1
                -1))
          c)
      (catch 'end-flag
        (while t
          (message "size[%dx%d]"
                   (window-width) (window-height))
          (setq c (read-char))
          (cond ((= c ?l)
                 (enlarge-window-horizontally dx))
                ((= c ?h)
                 (shrink-window-horizontally dx))
                ((= c ?j)
                 (enlarge-window dy))
                ((= c ?k)
                 (shrink-window dy))
                ;; otherwise
                (t
                 (message "Quit")
                 (throw 'end-flag t)))))))
  :bind
  (("C-c C-r" . window-resizer)))


;;; Dired mode内でのファイル・ディレクトリ名の書き換え
(leaf wdired
  :require t
  :bind
  ((:dired-mode-map
    ("r" . wdired-change-to-wdired-mode))))

;;; ウィンドウの移動
(leaf change-window
  :bind
  (("M-o" . other-window)
   ("C-o" . other-window)))
  

;;; Helmの設定
(leaf helm
  :ensure t helm-swoop
  :preface
  (leaf helm-robe :ensure t)
  (leaf helm-flyspell :ensure t)
  (leaf helm-flycheck :ensure t)
  (leaf helm-tramp :ensure t)
  (leaf helm-smex :ensure t)
  (leaf helm-ls-git :ensure t)
  (leaf helm-google :ensure t)
  (leaf helm-git-grep :ensure t)
  (leaf helm-git-files :ensure t)
  (leaf helm-git :ensure t)
  ;; Helm-find-filesなどでキルリングに追加
  (defadvice helm-delete-minibuffer-contents (before helm-emulate-kill-line activate)
    "Emulate `kill-line' in helm minibuffer"
    (kill-new (buffer-substring (point) (field-end))))
;;  (require 'helm-config)

  ;; ;; 存在しないファイルに対して補完を効かせない
  ;; (defadvice helm-ff-kill-or-find-buffer-fname (around execute-only-if-exist activate)
  ;;   "Execute command only if CANDIDATE exists"
  ;;   (when (file-exists-p candidate)
  ;;     ad-do-it))
  :custom
  `(
    (helm-autoresize-max-height . 0)
    (helm-autoresize-min-height . 150)
    (browse-url-mosaic-program . nil)
    (helm-delete-minibuffer-contents-from-point . t)
    (helm-display-function . #'display-buffer)
    ;;(helm-display-function . #'pop-to-buffer)
    (helm-full-frame . nil)
    )
  :config
  (helm-mode 1)
  (helm-autoresize-mode t)
  ;;(helm-migemo-mode 1)

  :bind
  (("C-x C-f" . helm-find-files)
   ("M-x" . helm-M-x)
   ("C-y" . helm-show-kill-ring)
   ("C-x C-b" . helm-for-files)
   ("C-s" . helm-swoop)
   ("M-s" . search-forward)
   (helm-map
    ("<tab>" . helm-execute-persistent-action)
    ("C-i" . helm-execute-persistent-action)
    ("C-z" . helm-select-action))
  ;; (helm-find-files-map
  ;;  ("C-h" . 'helm-select-action)
  ;;  ("C-@" . 'set-mark-command))
  ;; (helm-read-file-map
  ;;  ("C-h" . 'helm-select-action))
  ))



;;;;---- プログラミング/文字書き系の設定 ----
;;; Org mode
(leaf org
  :ensure t
  :preface
  (leaf org-re-reveal :ensure t)
  (leaf org-ac :ensure t)
  :custom
  `(
    (org-startup-truncated . nil)
    (org-mode . 1)
    )
  :bind
  (("C-c l" . org-store-link)
   ("C-c c" . org-capture)
   ("C-c a" . org-agenda)))


;;; auto-insert
(leaf auto-insert
  :custom
  `((auto-insert-directory . template-directory)
    (auto-insert-alist .
                       '(("\\.html$" . "html-template.html")
                         ("\\.php$" . "php-template.php")))
    (auto-insert-mode . t)))

(leaf php-mode :ensure t)
;;; Web-mode
(leaf web-mode
  :ensure t
  :mode "\\.js\\'" "\\.p?html?\\'" "\\.scss\\'" "\\.vue\\'"
  :config
  (leaf php-mode
    :ensure t ac-php
    :mode "\\.php\\'" "\\.blade.php\\'"
    :custom
    `((ac-sources . '(ac-source-php ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
      (yas-global-mode . 1))
    )
  (leaf js-jsx-mode
    :ensure t rjsx-mode
    :mode "\\.jsx\\'")
  (leaf css-mode
    :ensure t
    :mode "\\.css\\'")
  )


;;; XML-formed mode
(leaf xml-formed-mode
  :config
  (leaf yaml-mode
    :ensure t
    :mode "\\.yaml\\'"))


;;; TeX-mode
(leaf tex-related-mode
  :ensure yatex latex-preview-pane latex-extra
  )


(leaf color-theme
  :ensure color-theme-modern
  :config
  (load-theme
   ;;'calm-forest
   ;;'arjen
   'clarity
   ;;'dark-erc
   t)
  ;; (set-face-foreground 'mode-line-buffer-id "#adff2f")
  ;; (set-face-background 'mode-line "#3366d0")
  ;; (set-face-foreground 'mode-line "white")
  ;; (set-face-foreground 'mode-line-inactive "blue")
  ;; (set-face-background 'mode-line-inactive "#696969")
  ;; (set-face-background 'vertical-border "gray")
  )

;;; ここまで設定

(provide 'init)
