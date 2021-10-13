
;;; Dired
(use-package all-the-icons)
(use-package all-the-icons-dired)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(use-package dired
  :straight nil
  :demand
  :config
  (add-hook 'dired-mode-hook
            (lambda ()
              (dired-hide-details-mode)))
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode)))
  
  (setq-default dired-omit-files-p t)
  (setq dired-omit-files "^\\.DS_Store")




  (defun mydired-sort ()
  "Sort dired listings with directories first."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header 
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
    (set-buffer-modified-p nil)))

(defadvice dired-readin
  (after dired-after-updating-hook first () activate)
  "Sort dired listings with directories first before adding marks."
  (mydired-sort))


  :bind
  (:map dired-mode-map
        (("j" . dired-next-line)
         ("k" . dired-previous-line)
         ("h" . dired-up-directory)
         ("l" . dired-find-file)
         ("i" . peep-dired))) 
  )

(use-package peep-dired
  :demand
  :config
  (setq peep-dired-cleanup-on-disable t)
  :bind
  (:map peep-dired-mode-map
        ("j" . peep-dired-next-file)
        ("k" . peep-dired-prev-file))
  )

(use-package dired-x
  :straight nil
  :demand)








;; default terminal application path
(defvar tmtxt/macos-default-terminal-app-path
  "/Applications/kitty.app" "The default path to terminal application in MacOS")
;;; function to open new terminal window at current directory
(defun tmtxt/open-current-dir-in-terminal ()
  "Open current directory in dired mode in terminal application.
For MacOS only"
  (interactive)
  
  (shell-command (concat "open -a "
			 (shell-quote-argument tmtxt/macos-default-terminal-app-path)
			 " "
			 (shell-quote-argument (file-truename default-directory))
                         )))



(use-package popper
  :ensure t ; or :straight t
  :bind (("C-`"   . popper-toggle-latest)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\eshell\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))                ; For echo area hints



(add-hook 'eshell-mode-hook '(lambda() (set (make-local-variable 'god-local-mode) nil)))



;; (use-package all-the-icons-dired
;;   :config
;;   (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))
(when (string= system-type "darwin")       
  (setq dired-use-ls-dired nil))

;;; Pdf

(use-package pdf-tools
  :init
  (pdf-loader-install)
  (setq pdf-view-use-scaling t)
  (setq-default pdf-view-display-size 'fit-page)
  ;; The following helps if image is blurry
  (defadvice pdf-info-renderpage (before double-width-arg activate)
    (ad-set-arg 1 (* 2 (ad-get-arg 1))))

  :config

  ;; Add retina support for MacOS users
  (eval-when! IS-MAC
              (defun +pdf-view-create-page-a (page &optional window)
                "Create an image of PAGE for display on WINDOW."
                :override #'pdf-view-create-page
                (let* ((size (pdf-view-desired-image-size page window))
                       (width (if (not (pdf-view-use-scaling-p))
                                  (car size)
                                (* 2 (car size))))
                       (data (pdf-cache-renderpage
                              page width width))
                       (hotspots (pdf-view-apply-hotspot-functions
                                  window page size)))
                  (pdf-view-create-image data
                                         :width width
                                         :scale (if (pdf-view-use-scaling-p) 0.5 1)
                                         :map hotspots
                                         :pointer 'arrow)))

              (defvar +pdf--scaled-p nil)
              (defadvice! +pdf--scale-up-on-retina-display-a (orig-fn &rest args)
                "Scale up the PDF on retina displays."
                :around #'pdf-util-frame-scale-factor
                (cond ((not pdf-view-use-scaling) 1)
                      ((and (memq (pdf-view-image-type) '(imagemagick image-io))
                            (fboundp 'frame-monitor-attributes))
                       (funcall orig-fn))
                      ;; Add special support for retina displays on MacOS
                      ((and (eq (framep-on-display) 'ns)
                            (not +pdf--scaled-p)
                            EMACS27+)
                       (setq-local +pdf--scaled-p t)
                       2)
                      (1)))

              (defadvice! +pdf--use-scaling-on-ns-a ()
                :before-until #'pdf-view-use-scaling-p
                (and (eq (framep-on-display) 'ns)
                     EMACS27+))

              (defadvice! +pdf--supply-width-to-create-image-calls-a (orig-fn &rest args)
                :around '(pdf-annot-show-annotation
                          pdf-isearch-hl-matches
                          pdf-view-display-region)
                (letf! (defun create-image (file-or-data &optional type data-p &rest props)
                         (apply create-image file-or-data type data-p
                                :width (car (pdf-view-image-size))
                                props))
                       (apply orig-fn args))))

  )

(setq TeX-view-program-selection '((output-pdf "pdf-tools"))
      TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view"))
      TeX-source-correlate-mode t
      TeX-source-correlate-start-server t
      )

;; Update PDF buffers after successful LaTeX runs
;;Autorevert works by polling the file-system every auto-revert-interval seconds, optionally combined with some event-based reverting via file notification. But this currently does not work reliably, such that Emacs may revert the PDF-buffer while the corresponding file is still being written to (e.g. by LaTeX), leading to a potential error.

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)



(setq doc-view-resolution 200)
;; Open pdfs in emacs
(add-hook 'org-mode-hook
          '(lambda ()
             (setq org-file-apps
                   (append '(
                             ("\\.pdf\\'" . emacs)
                             ) org-file-apps ))))

(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;;; Music

(use-package emms
  :config
  (emms-default-players)
  (setq emms-source-file-default-directory "/Volumes/SAMSUNG128/music/")
  (setq emms-browser-covers 'emms-browser-cache-thumbnail-async)
  (setq emms-player-list '(emms-player-vlc
                                        ;emms-player-mpg123
                                        ;emms-player-mplayer
                           ))
  (define-key dired-mode-map "!" 'emms-add-dired)

  (require 'emms-player-simple)
  (require 'emms-setup)
  (emms-all)
  (setq emms-playlist-buffer-name "*Music*")
  (setq emms-info-asynchronously t)
  (require 'emms-mode-line)
  (emms-mode-line 1)
  (require 'emms-playing-time)
  (emms-playing-time 1)
  ;; (require 'emms-history)
  ;; (emms-history-load)

  )

(defun myplay ()
  (interactive)
  (emms-browser-clear-playlist)
  (emms-browser-add-tracks-and-play)) 

(use-package emms-browser
  :straight nil
  :config
                                        

                                        ;(evil-define-key 'normal emms-browser-mode-map "h" 'emms-browser-toggle-subitems)
                                        ;(evil-define-key 'normal emms-browser-mode-map "j" 'evil-next-visual-line)
                                        ;(evil-define-key 'normal emms-browser-mode-map "k" 'evil-previous-visual-line)
                                        ;(evil-define-key 'normal emms-browser-mode-map "l" 'emms-browser-toggle-subitems)

  (define-key emms-browser-mode-map (kbd "RET") #'myplay)
  )


;;; Term

;; A full terminal (i.e. use when you want your aliases)
(use-package vterm)

;; Kindly donated by witchmacs
;; (setq eshell-prompt-regexp "^[^αλ\n]*[αλ] ")
;; (setq ehell-prompt-function
;;       (lambda nil
;;         (concat
;;          (if (string= (eshell/pwd) (getenv "HOME"))
;;              (propertize "~" 'face `(:foreground "#99CCFF"))
;;            (replace-regexp-in-string
;;             (getenv "HOME")
;;             (propertize "~" 'face `(:foreground "#99CCFF"))
;;             (propertize (eshell/pwd) 'face `(:foreground "#99CCFF"))))
;;          (if (= (user-uid) 0)
;;              (propertize " α " 'face `(:foreground "#FF6666"))
;;            (propertize " λ " 'face `(:foreground "#A6E22E"))))))

(setq eshell-highlight-prompt nil)

(defun eshell-here ()
      "Opens up a new shell in the directory associated with the
    current buffer's file. The eshell is renamed to match that
    directory to make multiple eshell windows easier."
      (interactive)
      (let* ((parent (if (buffer-file-name)
                         (file-name-directory (buffer-file-name))
                       default-directory))
             (height (/ (window-total-height) 3))
             (name   (car (last (split-string parent "/" t)))))
        (split-window-vertically (- height))
        (other-window 1)
        (eshell "new")
        (rename-buffer (concat "*eshell: " name "*"))

        (insert (concat "ls"))
        (eshell-send-input)))

    (global-set-key (kbd "C-!") 'eshell-here)

;; leave eshell
 (defun eshell/x ()
      (insert "exit")
      (eshell-send-input)
      (delete-window))


(use-package svg-clock)
(use-package csv-mode)

;;; Project

(use-package magit
  :bind
  (:map magit-status-mode-map
        ("j" . magit-next-line)
        ("k" . magit-previous-line)
        ))

;; projectile
(use-package projectile
  :defer nil 
  :config
  (projectile-global-mode)
  ;; (setq projectile-completion-system 'ivy)
)
  
(use-package counsel-projectile
:ensure t
:config
(counsel-projectile-on))

(use-package counsel)




















(use-package elfeed)
;; data is stored in ~/.elfeed
(setq elfeed-feeds
      '(
        ;; programming
        ;; ("https://news.ycombinator.com/rss" hacker)
        ("https://www.reddit.com/r/programming.rss" programming)
        ("https://www.reddit.com/r/emacs.rss" emacs)


))

(setq-default elfeed-search-filter "@7-days-ago +unread")
(setq-default elfeed-search-title-max-width 100)
(setq-default elfeed-search-title-min-width 100)












(use-package eva
  :straight (eva :type git :host github :repo "meedstrom/eva"
                 :files (:defaults "assets" "renv" "*.R" "*.gnuplot"))

  :init
  ;; must be set early
  (setq eva-ai-name "Eva")
  (setq eva-fallback-to-emacs-idle t)

  ;; best set early, but not strictly breaking if not
  (setq eva-user-name "Owen")
  (setq eva-user-birthday "1963-02-19")
  (setq eva-user-short-title "sir")
  (setq eva-idle-log-path         "~/org/self-data/idle.tsv")
  (setq eva-buffer-focus-log-path "~/org/self-data/buffer-focus.tsv")
  (setq eva-buffer-info-path      "~/org/self-data/Self_data/buffer-info.tsv")
  (setq eva-main-ledger-path      "~/org/l.ledger")
  (setq eva-main-datetree-path    "~/org/diary.org")

  ;; prevent annoying ess prompt
  (setq ess-ask-for-ess-directory nil)

  :config
  (require 'eva-builtin)
  (require 'eva-activity)

  ;; these are used by `eva-present-diary'; org-journal not needed
  (setq org-journal-dir "~/org/Diary")
  (setq org-journal-file-format "%F.org")

  (add-hook 'eva-after-load-vars-hook #'eva-check-dangling-clock)
  (add-hook 'eva-after-load-vars-hook #'eva-check-org-variables)

  ;; HINT: you can even use the same object multiple times in the queue, you'll
  ;; just have to assign the output of (eva-item-create) to an external
  ;; variable and refer to it.
  (setq eva-items
        (list
         (eva-item-create :fn #'eva-greet
                          :min-hours-wait 1)

         (eva-item-create :fn #'eva-query-mood
                          :dataset "~/org/self-data/mood.tsv"
                          :min-hours-wait 1)

         (eva-item-create :fn #'eva-query-activity
                          :dataset "~/org/self-data/activities.tsv"
                          :min-hours-wait 1)

         (eva-item-create :fn #'eva-present-diary
                          :max-successes-per-day 1)

         (eva-item-create :fn #'eva-query-weight
                          :dataset "~/org/self-data/weight.tsv"
                          :max-entries-per-day 1)

         (eva-item-create :fn #'eva-plot-weight
                          :max-entries-per-day 1)

         (eva-item-create :fn #'eva-query-sleep
                          :dataset "~/org/self-data/sleep.tsv"
                          :min-hours-wait 5
                          :lookup-posted-time t)

         (eva-item-create :fn #'eva-present-ledger-report)

         (eva-item-create :fn #'eva-present-org-agenda)

         (eva-item-create :fn #'eva-query-ingredients
                          :dataset "~/org/self-data/ingredients.tsv"
                          :min-hours-wait 5)

         (eva-item-create :fn #'eva-query-cold-shower
                          :dataset "~/org/self-data/cold.tsv"
                          :max-entries-per-day 1)

         ;; you can inline define the functions too
         (eva-item-create
          :fn (eva-defun my-bye ()
                (message (eva-emit "All done for now."))
                (bury-buffer (eva-buffer-chat)))
          :min-hours-wait 0)))

  ;; Add hotkeys

  (transient-replace-suffix 'eva-dispatch '(0)
    '["General actions"
      ("q" "Quit" bury-buffer)
      ("l" "View Ledger report" eva-present-ledger-report)
      ("f" "View Ledger file" eva-present-ledger-file)
      ("a" "View Org agenda" org-agenda-list)])

  (define-key eva-chat-mode-map (kbd "l") #'eva-present-ledger-report)
  (define-key eva-chat-mode-map (kbd "a") #'org-agenda-list)

  ;; Activities
  (setq eva-activity-list
        (list (eva-activity-create :name "sleep"
                                   :cost-false-pos 3
                                   :cost-false-neg 3)

              (eva-activity-create :name "dissertation"
                                   :cost-false-pos 8
                                   :cost-false-neg 8)

              (eva-activity-create :name "coding"
                                   :cost-false-pos 5
                                   :cost-false-neg 5)

              (eva-activity-create :name "config"
                                   :cost-false-pos 5
                                   :cost-false-neg 5)

              (eva-activity-create :name "unknown"
                                   :cost-false-pos 0
                                   :cost-false-neg 0)))

  (eva-mode))
;https://github.com/meedstrom/eva





(provide 'modules)

