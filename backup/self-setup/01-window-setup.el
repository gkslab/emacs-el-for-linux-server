(global-linum-mode t)

;;(scroll-bar-mode -1)
;;(tool-bar-mode -1)
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(setq transient-mark-mode t)
(global-whitespace-mode 0)

(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
;;(setq inhibit-startup-screen t)

(put 'narrow-to-region 'disabled nil)
(setq make-backup-files nil)

(display-time)
(column-number-mode t)
(line-number-mode t)

(setq init-loader-show-log-after-init nil)
