
;;; Packages

(setq gc-cons-threshold 1000000000)
(setq garbage-collection-messages t)

;; Cooompile speed (native only)
;(setq comp-speed 2)

;; straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
;; Setting up use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

;; garbage collection

;; Load modules

(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         user-emacs-directory)
        ((boundp 'user-init-directory)
         user-init-directory)
        (t "~/.config/emacs/src")))

(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))


(load-user-file "src/keybinds.el")

(load-user-file "src/appearance.el")

(load-user-file "src/notes.el")

(load-user-file "src/modules.el")

(load-user-file "src/programming.el")





(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e6f3a4a582ffb5de0471c9b640a5f0212ccf258a987ba421ae2659f1eaa39b09" "850bb46cc41d8a28669f78b98db04a46053eca663db71a001b40288a9b36796c" "266ecb1511fa3513ed7992e6cd461756a895dcc5fef2d378f165fed1c894a78c" "a9a67b318b7417adbedaab02f05fa679973e9718d9d26075c6235b1f0db703c8" "1d44ec8ec6ec6e6be32f2f73edf398620bb721afeed50f75df6b12ccff0fbb15" "c2aeb1bd4aa80f1e4f95746bda040aafb78b1808de07d340007ba898efa484f5" "4f1d2476c290eaa5d9ab9d13b60f2c0f1c8fa7703596fa91b235db7f99a9441b" "cbdf8c2e1b2b5c15b34ddb5063f1b21514c7169ff20e081d39cf57ffee89bc1e" "6c531d6c3dbc344045af7829a3a20a09929e6c41d7a7278963f7d3215139f6a7" "d2e44214a7dc0bd5b298413ed6c3ba9719f1d96794d9de3bdf7a9808902fd098" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-block ((t (:foreground "#bbbbbc"))))
 '(org-block-background ((t (:background "#252b2b"))))
 '(org-block-begin-line ((t (:foreground "#888a85" :background "#252b2b"))))
 '(org-block-end-line ((t (:foreground "#888a85" :background "#252b2b"))))
 '(org-date ((t (:underline t :foreground "magenta3"))))
 '(org-document-info ((t (:bold t :height 2.0))))
 '(org-document-title ((t (:bold t :height 2.5))))
 '(org-done ((t (:bold t :foreground "ForestGreen"))))
 '(org-footnote ((t (:underline t :foreground "magenta3"))))
 '(org-hide ((t (:foreground "#2e3436"))))
 '(org-level-1 ((t (:bold t :height 2.0))))
 '(org-level-2 ((t (:bold t :height 1.5))))
 '(org-level-3 ((t (:bold t :height 1.25))))
 '(org-level-4 ((t (:bold nil :height 1.0))))
 '(org-link ((t (:foreground "skyblue2" :background "#2e3436" :underline nil))))
 '(org-quote ((t (:inherit org-block :slant italic))))
 '(org-special-keyword ((t (:foreground "brown"))))
 '(org-todo ((t (:bold t :foreground "Red"))))
 '(org-verbatim ((t (:foreground "#eeeeec" :underline t :slant italic))))
 '(org-verse ((t (:inherit org-block :slant italic)))))
