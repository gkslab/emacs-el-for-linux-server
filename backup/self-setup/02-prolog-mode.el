(autoload 'run-prolog "prolog" "Start a Prolog sub-process." t)
(autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
(autoload 'mercury-mode "prolog" "Major mode for editing Mercury programs." t)
(setq prolog-system 'swi)
(setq auto-mode-alist (append '(("\\.pl$" . prolog-mode)
				("\\.p$" . prolog-mode)
				("\\.m$" . mercury-mode))
			      auto-mode-alist))
(setq prolog-program-name "/usr/local/bin/swipl")
(setq prolog-consult-string "[user].\n")

(add-hook 'prolog-mode-hook 'auto-complete-mode)

(defun line-to-other-buffer ()
  (interactive)
  (let ((prl-buffer (get-buffer-create "*prolog*"))
	(cur-buffer (current-buffer))
	(current-line (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
    (set-buffer (buffer-name prl-buffer))
    (insert (format "%s" current-line))
    (comint-send-input)
    (set-buffer (buffer-name cur-buffer))
    (next-line)
    (beginning-of-line)))

(defun region-to-other-buffer-every-line ()
  (interactive)
  (let ((cur-linum nil)
	(end-linum nil))
    (goto-char (region-end))
    (setq end-linum (line-number-at-pos))
    (goto-char (region-beginning))
    (setq cur-linum (line-number-at-pos))
    (while (not (= cur-linum end-linum))
      (progn
	(line-to-other-buffer)
	(setq cur-linum (line-number-at-pos))))))


(add-hook 'prolog-mode-hook
	  '(lambda ()
	     (define-key prolog-mode-map (kbd "\C-c\C-v")
	       (lambda ()
		 (interactive)
		 (line-to-other-buffer)))
	     (define-key prolog-mode-map (kbd "\C-c\C-c\C-v")
	       (lambda ()
		 (interactive)
		 (region-to-other-buffer-every-line)))))
