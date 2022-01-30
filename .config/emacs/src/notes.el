;;; Org Mode

;; (use-package writeroom-mode)
;; (use-package org-web-tools)

(use-package org-bullets
  :defer nil
    :config
    (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package org
  :config
  (setq mode-line-format nil)
  ;(setq org-startup-with-latex-preview t)
  (setq org-latex-image-default-width "2.5\\linewidth")
  ;; Line spacing
  (setq line-spacing 0.1)
  ;; Top padding
  (setq header-line-format " ")
  ;; Side padding
  (lambda () (progn
               (setq left-margin-width 2)
               (setq right-margin-width 2)
               (set-window-buffer nil (current-buffer))))
  ;; Tweaks
  (setq org-startup-indented t
        org-bullets-bullet-list '("\u200b") ;; no bullets, needs org-bullets package
        org-ellipsis " ... " ;; folding symbol
        org-pretty-entities nil ; hide \lambda i think
        org-hide-emphasis-markers t ; show actually italicized text instead of /italicized text/
        org-agenda-block-separator ""
        org-fontify-whole-heading-line t
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t
        org-startup-with-inline-images t)


    (font-lock-add-keywords 'org-mode
                            '(("^ +\\([-*]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))


  
  )


  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
(defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
(defconst day-re "[A-Za-z]\\{3\\}")


(use-package svg-tag-mode
  :config
   (setq svg-tag-tags
        `(
          ;; Org tags
          (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
          (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))
          
          ;; Task priority
          ("\\[#[A-Z]\\]" . ( (lambda (tag)
                                (svg-tag-make tag :face 'org-priority 
                                              :beg 2 :end -1 :margin 0))))

          ;; Progress
          ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                              (svg-progress-percent (substring tag 1 -2)))))
          ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                            (svg-progress-count (substring tag 1 -1)))))
          
          ;; TODO / DONE
          ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
          ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))


          ;; Citation of the form [cite:@Knuth:1984] 
          ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                            (svg-tag-make tag
                                                          :inverse t
                                                          :beg 7 :end -1
                                                          :crop-right t))))
          ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                     (svg-tag-make tag
                                                                   :end -1
                                                                   :crop-left t))))

          
          ;; Active date (without day name, with or without time)
          (,(format "\\(<%s>\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 0))))
          (,(format "\\(<%s *\\)%s>" date-re time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
          (,(format "<%s *\\(%s>\\)" date-re time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

          ;; Inactive date  (without day name, with or without time)
          (,(format "\\(\\[%s\\]\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
          (,(format "\\(\\[%s *\\)%s\\]" date-re time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
          (,(format "\\[%s *\\(%s\\]\\)" date-re time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))))
;;

(defun svg-progress-percent (value)
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag (concat value "%")
                           nil :stroke 0 :margin 0)) :ascent 'center))

(defun svg-progress-count (value)
  (let* ((seq (mapcar #'string-to-number (split-string value "/")))
         (count (float (car seq)))
         (total (float (cadr seq))))
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ count total) nil
                                    :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag value nil
                           :stroke 0 :margin 0)) :ascent 'center)))

  :hook org-mode
  )




;; Pretty org mode

(setq org-adapt-indentation t
      org-hide-leading-stars t)


;; https://github.com/juba/color-theme-tangotango/blob/master/tangotango-theme.el
(custom-set-faces
 `(org-hide ((t (:foreground "#2e3436"))))
 `(org-document-title ((t (:bold t :height 2.5))))
 `(org-document-info ((t (:bold t :height 2.0))))
 `(org-level-1 ((t (:bold t :height 2.0))))
 `(org-level-2 ((t (:bold t :height 1.5))))
 `(org-level-3 ((t (:bold t :height 1.25))))
 `(org-level-4 ((t (:bold nil :height 1.0))))
 
 `(org-date ((t (:underline t :foreground "magenta3"))))
 `(org-footnote  ((t (:underline t :foreground "magenta3"))))
 `(org-link ((t (:foreground "skyblue2" :background "#2e3436" :underline nil))))
 `(org-special-keyword ((t (:foreground "brown"))))
 `(org-verbatim ((t (:foreground "#eeeeec" :underline t :slant italic))))
 `(org-block ((t (:foreground "#bbbbbc"))))
 `(org-quote ((t (:inherit org-block :slant italic))))
 `(org-verse ((t (:inherit org-block :slant italic))))
 `(org-todo ((t (:bold t :foreground "Red"))))
 `(org-done ((t (:bold t :foreground "ForestGreen"))))
 ;; `(org-agenda-structure ((t (:weight bold :foreground "tomato"))))
 ;; `(org-agenda-date ((t (:foreground "#6ac214"))))
 ;; `(org-agenda-date-weekend ((t (:weight normal :foreground "dodger blue"))))
 ;; `(org-agenda-date-today ((t (:weight bold :foreground "#edd400"))))
 ;; `(org-scheduled-previously ((t (:weight normal :foreground "#edd400"))))
 `(org-block-begin-line ((t ( :foreground "#888a85" :background "#252b2b"))))
 `(org-block-background ((t (:background "#252b2b"))))
 `(org-block-end-line ((t ( :foreground "#888a85" :background "#252b2b"))))
 )













(use-package org-download
  :ensure t)
;; need to have this on top of org files
;;-*- mode: Org; org-download-image-dir: "~/Pictures/foo"; -*-




(use-package flyspell-popup
  :config
  (add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode)
  (setq flyspell-popup-correct-delay 0)
                                        ;(define-key flyspell-mode-map (kbd "C-;") #'flyspell-popup-correct)
  (setq flyspell-delay 0)
  )

;;enable flyspell in text mode (and derived modes)
;; (add-hook 'text-mode-hook 'flyspell-mode)


;;; Org Roam

(use-package org-roam
  :init
  (setq org-roam-directory "~/org/roam/")
  :config
  (org-roam-setup)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n l" . org-roam-buffer-toggle)
   ("C-c n c" . org-id-get-create)))



(provide 'notes)
