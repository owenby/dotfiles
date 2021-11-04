;;; lsp-mode

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :config
  ;; (setq lsp-ui-sideline-enable t)
  (setq lsp-headerline-breadcrumb-enable-diagnostics nil)
  (setq lsp-idle-delay 0)
  ;; (setq lsp-completion-show-detail nil)
  (setq read-process-output-max (* 1024 1024))
  (setq lsp-modeline-diagnostics-enable nil)

  (setq lsp-enable-semantic-highlighting nil)
  
  :hook
  (
   (c++-mode . lsp)
   (c-mode . lsp)
   (python-mode . lsp)
   (latex-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; (use-package eglot
;;   :defer nil
;;   :config
;;   (add-hook 'c-mode-hook 'eglot-ensure)
;;   (add-hook 'c++-mode-hook 'eglot-ensure)
;;   (add-hook 'python-mode-hook 'eglot-ensure)
;;   )

(global-eldoc-mode 0)
;; (setq eldoc-idle-delay 0.5)
;; (setq eldoc-current-idle-delay 0.5)
;; (setq tooltip-delay 0.5)

(use-package company
  :defer nil
  :config
  (setq company-idle-delay 0)
  (setq company-tooltip-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (bind-key "C-=" 'company-complete) 
  (global-company-mode)
  ;; (setq company-icon-size 1)

  (setq company-tooltip-limit 10)
  (setq company-dabbrev-downcase 0)
  (setq company-echo-delay 0)
  (setq company-tooltip-maximum-width 100)

  (setq company-backends
        '((company-files
           company-keywords
           company-capf
           )
           ;; (company-clang
           ;; company-gtags
           ;; company-etags
          ;; company-dabbrev-code)
        ))

  ;; cycle through completions on hitting tab. No need to use arrows
    (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
    (define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
    ;; select previous completion on shift + tab
    (define-key company-active-map (kbd "S-TAB") 'company-select-previous)
    (define-key company-active-map (kbd "<backtab>") 'company-select-previous)

    ;; cancel selections by typing non-matching characters
    (setq company-require-match 'never)
    ;; keys like SPC do NOT finish completion (have to press enter to select completion)
    (setq company-auto-complete nil)

    (define-key company-active-map (kbd "C-c C-a C-d") #'my/company-show-doc-buffer)
    
    )


;;; C/C++

;; Indenting 4 big
(setq-default c-basic-offset 4)
;; Treat header files as cpp
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(use-package dumb-jump
  :defer nil
  :init
  (dumb-jump-mode)
  :config
  ;; (setq dumb-jump-selector 'ivy)
  )
 
;; (use-package opencl-mode)
(add-to-list 'auto-mode-alist '("\\.cl\\'" . c-mode))
(use-package make-mode
  :ensure t)

;; Compile mode
(require 'compile)

(setq compilation-read-command nil)

(defun my-compile ()
  "Run compile and resize the compile window"
  (interactive)
  (progn
    (save-buffer)
    (call-interactively 'compile)
    (setq cur (selected-window))
    (setq w (get-buffer-window "*compilation*"))
    (select-window w)
    (setq h (window-height w))
    (shrink-window (- h 12))
    (select-window cur)
    )
  )

(defun my-compile-faces ()
  "Buffer-local face remapping for 'compilation mode'."
  (face-remap-add-relative 'default
                           :background "#1D1D1D"
                           :foreground "#F2F2F2"))
(add-hook 'compilation-mode-hook #'my-compile-faces)

;; Syntax highlighting
;; https://emacs-tree-sitter.github.io/syntax-highlighting/customization/
;; (use-package tree-sitter)
;; (use-package tree-sitter-langs)
;; (add-hook 'c-mode-hook #'tree-sitter-mode)
;; (add-hook 'c++-mode-hook #'tree-sitter-mode)
;; ;; (global-tree-sitter-mode) ;; Just the C++ files
;; (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)


;;; R
;; (use-package ess)

;;; Lisp

(use-package guix)
(use-package geiser)
(use-package flycheck-guile)

;;; Latex

;; Making emacs find latex (so that C-c C-x C-l works on orgmode)
(setenv "PATH" (concat ":/Library/TeX/texbin/" (getenv "PATH")))
(setenv "PATH" (concat (getenv "PATH") ":/Library/TeX/texbin/"))  
(setq exec-path (append exec-path '("/Library/TeX/texbin/")))
(add-to-list 'exec-path "/Library/TeX/texbin/")
(add-to-list 'exec-path "/usr/local/opt/llvm/bin/")
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; AucTeX
(use-package auctex
  :defer nil
  :config
                                        ;(setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (add-hook 'LaTeX-mode-hook 'visual-line-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)
  (setq TeX-PDF-mode t)
  (setq TeX-save-query nil)

  )

;;; Web

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
)

;; Matlab
;; (use-package matlab-mode
;;   :defer nil
;;   :config
;;   (setq matlab-indent-function-body t)
;;   (setq matlab-shell-command "/Applications/MATLAB_R2020b.app/bin/matlab")
;;   (setq matlab-shell-command-switches (list "-nodesktop"))
;;   (setq matlab-indent-function t)
;;  )
;;    (add-to-list
;;   'auto-mode-alist
;;   '("\\.m$" . matlab-mode))


;;; Syntax checking

;;; Selection

;; (use-package corfu
;;   ;; Optional customizations
;;   :custom
;;   (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
;;   (corfu-auto t)                 ;; Enable auto completion
;;   (corfu-auto-delay 0.01)
;;   ;; (corfu-commit-predicate nil)   ;; Do not commit selected candidates on next input
;;   ;; (corfu-quit-at-boundary t)     ;; Automatically quit at word boundary
;;   (corfu-quit-no-match nil)        ;; Automatically quit if there is no match
;;   ;; (corfu-echo-documentation nil) ;; Do not show documentation in the echo area

;;   ;; Optionally use TAB for cycling, default is `corfu-complete'.
;;   ;; :bind (:map corfu-map
;;   ;;        ("TAB" . corfu-next)
;;   ;;        ([tab] . corfu-next)
;;   ;;        ("S-TAB" . corfu-previous)
;;   ;;        ([backtab] . corfu-previous))

;;   ;; You may want to enable Corfu only for certain modes.
;;   ;; :hook ((prog-mode . corfu-mode)
;;   ;;        (shell-mode . corfu-mode)
;;   ;;        (eshell-mode . corfu-mode))

;;   ;; Recommended: Enable Corfu globally.
;;   ;; This is recommended since dabbrev can be used globally (M-/).
;;   :init
;;   (corfu-global-mode))

;; ;; Optionally use the `orderless' completion style.
;; ;; Enable `partial-completion' for files to allow path expansion.
;; ;; You may prefer to use `initials' instead of `partial-completion'.
;; (use-package orderless
;;   :init
;;   (setq completion-styles '(orderless)
;;         completion-category-defaults nil
;;         completion-category-overrides '((file (styles . (partial-completion))))))

;; ;; Dabbrev works with Corfu
;; ;; (use-package dabbrev
;; ;;   ;; Swap M-/ and C-M-/
;; ;;   :bind (("M-/" . dabbrev-completion)
;; ;;          ("C-M-/" . dabbrev-expand)))

;; ;; A few more useful configurations...
;; (use-package emacs
;;   :init
;;   ;; TAB cycle if there are only few candidates
;;   (setq completion-cycle-threshold 2)

;;   ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
;;   ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
;;   ;; (setq read-extended-command-predicate
;;   ;;       #'command-completion-default-include-p)

;;   ;; Enable indentation+completion using the TAB key.
;;   ;; `completion-at-point' is often bound to M-TAB.
;;   (setq tab-always-indent 'complete))


(use-package flycheck
  :ensure t
  :defer nil
  :config
  ;; (global-flycheck-mode)
  )
(use-package flycheck-pkg-config)

(use-package yasnippet
  :defer nil
  :config
  (add-to-list 'load-path "~/.config/emacs/snippets")
  (yas-global-mode)
  (yas-minor-mode))

;(outline-minor-mode)

(use-package multiple-cursors
  :config
  (global-set-key (kbd "C-\ C-c") 'mc/edit-lines))

;;; Mini buffer

(use-package which-key
  :defer nil
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5
        which-key-idle-secondary-delay 0.1)

  (which-key-enable-god-mode-support) 
  )

(use-package counsel
  :config
  (setq counsel-find-file-ignore-regexp (regexp-opt '(".DS_Store")))
  )

;; (use-package prescient)
(use-package company-prescient
  :defer nil
  :config
  (company-prescient-mode))
;; (use-package ivy-prescient
;;   :defer nil
;;   :config
;;   (ivy-prescient-mode t))
;; (use-package ivy
;;   :defer nil
;;   :ensure t
;;   :config
;;   (ivy-mode 1))

;; Enable vertico
(use-package vertico
  :defer nil
  :init
  (vertico-mode)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Use the `orderless' completion style. Additionally enable
;; `partial-completion' for file path expansion. `partial-completion' is
;; important for wildcard support. Multiple files can be opened at once
;; with `find-file' if you enter a wildcard. You may also give the
;; `initials' completion style a try.
(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
;; (use-package savehist
;;   :init
;;   (savehist-mode))


;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :defer nil
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))










(require 'cc-mode)
(require 'python)
(require 'tex-mode)

(define-key c++-mode-map (kbd "C-<return>") 'my-compile)
(define-key c-mode-map (kbd "C-<return>") 'my-compile)
(define-key python-mode-map (kbd "C-<return>") 'my-compile)
(eval-after-load 'LaTeX-mode
  '(define-key LaTeX-mode-map (kbd "C-<return>") 'TeX-command-run-all))
















(provide 'programming)

