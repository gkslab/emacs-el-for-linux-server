;;; leaf-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "leaf" "leaf.el" (25527 37176 138164 22000))
;;; Generated autoloads from leaf.el

(autoload 'leaf-available-keywords "leaf" "\
Return current available `leaf' keywords list.

\(fn)" t nil)

(autoload 'leaf-pp-to-string "leaf" "\
Return format string of `leaf' SEXP like `pp-to-string'.

\(fn SEXP)" nil t)

(autoload 'leaf-pp "leaf" "\
Output the pretty-printed representation of leaf SEXP.

\(fn SEXP)" nil nil)

(autoload 'leaf-create-issue-template "leaf" "\
Create issue template buffer.

\(fn)" t nil)

(autoload 'leaf-expand "leaf" "\
Expand `leaf' at point.

\(fn)" t nil)

(autoload 'leaf-key-describe-bindings "leaf" "\
Display all the bindings configured via `leaf-key'.

\(fn)" t nil)

(autoload 'leaf "leaf" "\
Symplify your `.emacs' configuration for package NAME with ARGS.

\(fn NAME &rest ARGS)" nil t)

(function-put 'leaf 'lisp-indent-function 'defun)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; leaf-autoloads.el ends here
