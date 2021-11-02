;;; Early loaded settings

;; Set default font
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 160
                    :weight 'normal
                    :width 'normal)

;; Disable tool bar, menu bar, scroll bar.
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 10)

;; Ensures scaling window properly 
(setq frame-resize-pixelwise t)
;; Scrolling
(setq redisplay-dont-pause t
  scroll-margin 3
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

;; For some reason makes scrolling smoother
(setq jit-lock-defer-time 0)



;; Mouse autoselect
(setq mouse-autoselect-window t)

(setq-default indent-tabs-mode nil)
;; Highlight current line.
(global-hl-line-mode t)

(setq show-paren-delay 0)
(show-paren-mode 1)
;; Line wrapping
(global-visual-line-mode t)

(blink-cursor-mode 0)
(setq-default cursor-in-non-selected-windows nil)

(fset 'yes-or-no-p 'y-or-n-p)
;; Annoying # files
(setq create-lockfiles nil)
;; Annoying ~ files
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq native-comp-async-report-warnings-errors 'silent)
;; A little padding
;(set-frame-parameter nil 'internal-border-width 20)

;; dumb
(setq package-enable-at-startup nil
      package--init-file-ensured t)

;; Bracket matching
;; (setq electric-pair-pairs '(
;;                            (?\{ . ?\})
;;                            (?\( . ?\))
;;                            (?\[ . ?\])
;;                            (?\" . ?\")
;;                            (?\< . ?\>)
;;                             ))
;;(electric-pair-mode t)

;; Line numbers
;; (setq display-line-numbers-type 'relative)
;; (setq display-line-numbers-type t)
;; (global-display-line-numbers-mode)

