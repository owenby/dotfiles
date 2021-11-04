;(use-package base16-theme
  ;:defer nil
  ;:config
  ;;(load-theme 'base16-flat t)     
  ;;(load-theme 'base16-eva t)
  ;;(load-theme 'base16-materia t)

  ;; Light themes
  ;; (set-face-background 'mode-line "white")
  ;)

;;https://github.com/bbatsov/solarized-emacse
;; (use-package solarized-theme
;;   :defer nil
;;   :config
;;   ;; (load-theme 'solarized-gruvbox-dark t)
;;   ;; (load-theme 'solarized-dark-high-contrast t)
;;   ;; (load-theme 'solarized-light t)
;;   ;; (load-theme 'leuven t)
;; )


(use-package doom-themes
  :defer nil
  :config
  ;; (load-theme 'doom-solarized-dark-high-contrast t)
  ;; (load-theme 'doom-solarized-light t)
  ;; (load-theme 'doom-henna t)
  ;; (load-theme 'doom-snazzy t)
  ;; (load-theme 'doom-old-hope t)
  (load-theme 'doom-oceanic-next t)
)

;;; Modeline

;(use-package minions
;  :defer nil
;  :config
;  (minions-mode))

(use-package rich-minority
  :defer nil
  :config
  (rich-minority-mode 1)
  (setq rm-whitelist
      (format "^ \\(%s\\)$"
              (mapconcat #'identity
                         '("God.*")
                         "\\|")))
  )


(defun mode-line-fill (face reserve)
  "Return empty space using FACE and leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 20))
  (when (and window-system (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ right right-fringe right-margin) ,reserve)))
              'face face))

(setq-default mode-line-format (list
                                " "
                                'mode-name
                                "   "
                                '(:eval (abbreviate-file-name default-directory))
                                'mode-line-buffer-identification
                                ;; 'buffer-file-name
                                ;; 'mode-line-modes
                                ;; `(vc-mode vc-mode)
                               ;; Fill until the end of line but 10 characters
                                (mode-line-fill 'mode-line 8)
                                "%l:%c"
                                ))

;; ;; Bloated but simply the most comprehensive 
;; (use-package doom-modeline
;;   :ensure t
;;   :hook (after-init . doom-modeline-mode)
;;   :config
;;   (setq doom-modeline-height 25)
;;   ;; (setq doom-modeline-bar-width nil)
;;   ;; (setq doom-modeline-major-mode-icon t)
;;   ;; (setq doom-modeline-minor-modes nil)
;;   ;; (setq doom-modeline-modal-icon nil)
;;   ;; (setq doom-modeline-project-detection 'project)
;;   ;; (setq doom-modeline-lsp t)
;;   (set-face-attribute 'mode-line nil :height 150)
;; )

;;; Dashboard

;;disable splash screen and startup message
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; (use-package dashboard
;;   :defer nil
;;   :ensure t
;;   :config
;;   (dashboard-setup-startup-hook)
;;   (setq dashboard-center-content t)
;;   ;; (setq dashboard-startup-banner "~/Pictures/Memes/Anime/Asuka.png")
;;   ;; (setq dashboard-startup-banner "~/Pictures/Memes/eizouken/hegel.png")
;;   ;;
;;   (setq dashboard-footer-messages '("Welcome"))
;;   (setq dashboard-items '((projects . 5)
;;                           ;(recents  . 5)
;;                           ;(agenda . 5)
;;                           ))
  
;;   ;; (setq dashboard-items nil)
;;   (setq dashboard-set-footer nil)
;;   (setq dashboard-show-shortcuts nil)
;;   (setq dashboard-banner-logo-title "Let's get to work.")
;;  )






(provide 'appearance)
