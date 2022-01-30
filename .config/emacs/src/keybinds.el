

;; Fix mac modifiers and basic binds
;; https://github.com/railwaycat/homebrew-emacsmacport
;; (if (eq system-type 'darwin)
;;     (progn (setq mac-option-modifier 'meta)
;;            (setq mac-command-modifier 'hyper)
;;            (global-set-key [(hyper q)]
;;                            (lambda () (interactive) (kill-emacs)))
;;            (global-set-key [(hyper v)]
;;                            (lambda () (interactive) (yank)))
;;                                         ;(global-set-key (kbd "H-3") '(lambda () (interactive) (insert "#")))
;;            ))


;; (global-set-key [control-bracketleft] 'backward-paragraph)
;; (global-set-key (kbd "C-]") 'forward-paragraph)

(define-prefix-command 'leader-map)
(global-set-key (kbd "C-c") 'leader-map)
;; (define-key 'leader-map (kbd "a") 'some-func)

(defvar my-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    
;; navigation
(bind-key "C-h" 'backward-char)
(bind-key "C-j" 'forward-line)
(bind-key "C-k" 'backward-line)
(bind-key "C-l" 'forward-char)
(bind-key "C-{" 'beginning-of-buffer)
(bind-key "C-}" 'end-of-buffer)

(bind-key "M-n" "\C-u1\C-v")
(bind-key "M-p" "\C-u1\M-v")

(bind-key "C-f" 'forward-word)
(bind-key "C-b" 'backward-word)
(bind-key "C-o" 'evil-newline)
(bind-key "C-a" 'smart-beginning-of-line)

(bind-key "C-w" 'copy-region-as-kill)
(bind-key "C-S-w" 'kill-region)
(bind-key "C-;" 'comment-line)
(bind-key* "C-d" 'kill-whole-line)
(bind-key "C-<backspace>" 'kill-to-beginning)

;; windows
(bind-key "C-x C-q" 'kill-this-buffer)
(bind-key "C-x C-d" 'dired-jump)
(bind-key* "C-x C-h" 'split-window-right)
(bind-key* "C-x C-j" 'split-window-below)
(bind-key* "C-x C-k" 'split-window-below)
(bind-key* "C-x C-l" 'split-window-right)
(bind-key* "C-c C-h" 'windmove-left)
(bind-key* "C-c C-j" 'windmove-down)
(bind-key* "C-c C-k" 'windmove-up)
(bind-key* "C-c C-l" 'windmove-right)
   ;; "C-m C-j" 'split-window-below
  ;; "C-m C-l" 'split-window-right  
(bind-key "C-c C-p" 'popout)

(define-key leader-map (kbd "C-t") 'eshell-here)
(bind-key "C-s" 'swiper-isearch)
(bind-key "C-r" 'swiper-isearch-backward)
(bind-key "C-c C-TAB" 'indent-for-tab-command)
(bind-key "C-c C-b" 'eval-buffer)
(bind-key "C-c C-g" 'magit)

(bind-key "C-c C-;" 'counsel-M-x)
(bind-key "C-c C-:" 'eval-expression)
(bind-key "C-c C-i" 'ibuffer)
(bind-key "C-c C-r" 'replace-string)
(bind-key "C-c C-e" 'count-words)
(bind-key* "C-c C-n" 'next-buffer)
(bind-key* "C-c C-p" 'previous-buffer)
(bind-key "C-c C-f" 'lsp-find-definition)
(bind-key "C-c C-m C-m" 'emms-browser)
(bind-key "C-c C-s" 'rgrep)
(bind-key "C-c C-c" 'projectile-find-other-file)
                                        ;"m c" 'emms-stop
;(bind-key* "C-c C-h C-v" 'describe-variable)
;(bind-key* "C-c C-h C-k" 'describe-key)

   ;; Open stuff
(bind-key* "C-x C-o C-o" 'open-emacs-config)
(bind-key* "C-x C-o C-u" 'open-uni)
(bind-key* "C-x C-o C-b" 'open-book)
(bind-key* "C-x C-o C-p" 'open-pictures)
(bind-key* "C-x C-o C-d" 'open-dissertation)
(bind-key* "C-x C-o C-c" 'open-config)

(bind-key* "C-x C-x" 'tmtxt/open-current-dir-in-terminal)

(bind-key "<escape>" 'keyboard-escape-quit)
(bind-key "`" "\\" )


    map)
  "my-keys-minor-mode keymap.")

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-keys")

(my-keys-minor-mode 1)

 


(add-hook 'after-load-functions 'my-keys-have-priority)

(defun my-keys-have-priority (_file)
  "Try to ensure that my keybindings retain priority over other minor modes.

Called via the `after-load-functions' special hook."
  (unless (eq (caar minor-mode-map-alist) 'my-keys-minor-mode)
    (let ((mykeys (assq 'my-keys-minor-mode minor-mode-map-alist)))
      (assq-delete-all 'my-keys-minor-mode minor-mode-map-alist)
      (add-to-list 'minor-mode-map-alist mykeys))))





















(use-package god-mode
  :defer nil
  :config
   (god-mode-all)
   (global-set-key (kbd "<escape>") 'god-local-mode)
   )

 (defun my-update-cursor ()
   (setq cursor-type (if (or god-local-mode buffer-read-only)
                         'box
                       'bar)))

(add-hook 'god-mode-enabled-hook 'my-update-cursor)
(add-hook 'god-mode-disabled-hook 'my-update-cursor)
(define-key god-local-mode-map (kbd "[") #'backward-paragraph)
(define-key god-local-mode-map (kbd "]") #'forward-paragraph)

;; (use-package modalka
;;   :defer nil
;;   :config
;;   (modalka-global-mode 1)
;;   (global-set-key (kbd "<escape>") 'modalka-mode)
;;   (setq-default cursor-type '(bar))
;;   (setq modalka-cursor-type 'box)

  
;;   (modalka-define-kbd "n" "C-n")
;;   (modalka-define-kbd "p" "C-p")
;;   )



;;; Functions

(defun backward-line ()
    (interactive)
  (forward-line -1))

;; Term
(defun open-term ()
  (interactive)
  (split-window-vertically)
  (eshell))
;; Open config file
(defun open-emacs-config ()
  (interactive)
  (find-file "~/.config/emacs/src/"))
;; Open book folder
(defun open-book ()
  (interactive)
  (find-file "~/Documents/Books"))
;; Open uni folder
(defun open-uni ()
  (interactive)
  (find-file "~/University"))
;; Open C
(defun open-pictures ()
  (interactive)
  (find-file "~/Pictures/"))
;; Open dissertation
(defun open-dissertation ()
  (interactive)
  (find-file "~/Work/"))
;; Open config files
(defun open-config ()
  (interactive)
  (find-file "~/dotfiles/"))
;; New framme
(defun popout ()
  (interactive)
  (make-frame)
  (other-frame 1))

(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

(defun kill-to-beginning ()
  "Delete backwards until beginning of line is hit"
  (interactive)
  (kill-line 0))

(defun evil-newline ()
  "Insert new line under current one and jump to it"
  (interactive)
  (end-of-line)
  (newline-and-indent))

(provide 'keybinds)

