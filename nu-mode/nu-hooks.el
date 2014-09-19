;;
;; Pierre-Yves Luyten <py@luyten.fr> 2014
;; GPL V3.
;;
;;
;; hooks and eval-after-load stuff.
;;
;;

(defvar ibuffer-mode-map)
(defvar dired-mode-map)

(defvar nu-isearch-direction 'forward)

(defun nu-isearch-repeat-same ()
  "Continue isearch same direction."
  (interactive)
  (if (eq nu-isearch-direction 'forward)
      (isearch-repeat-forward)
      (isearch-repeat-backward)))

(defun nu-isearch-repeat-opposite ()
  "Continue isearch, opposite direction."
  (interactive)
  (if (eq nu-isearch-direction 'forward)
      (setq nu-isearch-direction 'backward)
      (setq nu-isearch-direction 'forward))
  (nu-isearch-repeat-same))

(defun nu-prepare-for-isearch ()
  "I still need to replace this isearch turd."
  (define-key isearch-mode-map (kbd "C-f") 'nu-isearch-repeat-same)
  (define-key isearch-mode-map (kbd "C-S-f") 'nu-isearch-repeat-opposite)
  (define-key isearch-mode-map (kbd "C-v") 'isearch-yank-kill)
  (define-key isearch-mode-map (kbd "M-e") 'isearch-yank-word-or-char)
  (define-key isearch-mode-map (kbd "M-y") 'isearch-yank-line)
  (define-key isearch-mode-map (kbd "C-r") 'isearch-edit-string)
  (define-key isearch-mode-map (kbd "C-q") 'isearch-cancel))

(defun nu-prepare-for-ibuffer ()
  "Obsolete, now helm is used."
  (define-key ibuffer-mode-map (kbd "M-i") 'ibuffer-backward-line)
  (define-key ibuffer-mode-map (kbd "M-k") 'ibuffer-forward-line))


; stock M-i & M-k functions to restore them
; while leaving minibuffer

(defvar nu-m-i-sname nil)
(defvar nu-m-k-sname nil)

(defun nu-prepare-for-minibuffer ()
  "Minibuffer might be not as important as helm. Still."
  (setq nu-m-i-sname (symbol-name (lookup-key nu-keymap (kbd "M-i"))))
  (setq nu-m-k-sname (symbol-name (lookup-key nu-keymap (kbd "M-k"))))
  (define-key nu-keymap (kbd "M-i") 'previous-history-element)
  (define-key nu-keymap (kbd "M-k") 'next-history-element))


(defun nu-leave-minibuffer ()
  "Restore tab for previous."
  (define-key nu-keymap (kbd "M-i") (intern-soft nu-m-i-sname))
  (define-key nu-keymap (kbd "M-k") (intern-soft nu-m-k-sname)))



(defun nu-prepare-for-dired ()
  "Most dired adaptation is done using prompts.

Still, some keys here help."
  (define-key dired-mode-map  (kbd "M-i") 'dired-previous-line)
  (define-key dired-mode-map  (kbd "M-k") 'dired-next-line)
  (define-key dired-mode-map  (kbd "M-z") 'dired-undo)
  (define-key dired-mode-map  (kbd "C-c") 'nu-copy-prompt))

(add-hook 'minibuffer-setup-hook 'nu-prepare-for-minibuffer)
(add-hook 'minibuffer-exit-hook  'nu-leave-minibuffer)
(add-hook 'ibuffer-hook          'nu-prepare-for-ibuffer)
(add-hook 'isearch-mode-hook     'nu-prepare-for-isearch)
(add-hook 'dired-mode-hook       'nu-prepare-for-dired)


(eval-after-load "helm-mode" ;; TODO = helm-M-x-map
  '(progn
    ;; qwertyuiop
    (define-key helm-map (kbd "C-q") 'helm-keyboard-quit)
    (define-key helm-find-files-map (kbd "C-r") 'helm-ff-run-rename-file) ; dired is better as this, no?
    (define-key helm-buffer-map (kbd "C-r") 'helm-buffer-run-query-replace) ; absurd func! well...

    (define-key helm-find-files-map (kbd "<backspace>") 'helm-find-files-up-one-level) ;yé!
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "M-i") 'helm-previous-line)
    (define-key helm-find-files-map (kbd "M-i") 'helm-previous-line)
    (define-key helm-generic-files-map (kbd "M-i") 'helm-previous-line)
    (define-key helm-find-files-map (kbd "C-o") 'helm-execute-persistent-action)
    (define-key helm-generic-files-map (kbd "C-o") 'helm-execute-persistent-action)
    (define-key helm-find-files-map (kbd "C-p") 'helm-ff-run-switch-to-eshell)
    (define-key helm-map (kbd "M-p") 'universal-argument)

    ;asdfghjkl. Use Alt-g for goto.
    (define-key helm-map (kbd "C-a") 'helm-mark-all) ; for once a mark all makes sense...
    (define-key helm-map (kbd "M-a") 'helm-toggle-visible-mark)
    (define-key helm-find-files-map (kbd "M-d") 'helm-ff-run-delete-file) ; ok
    (define-key helm-buffer-map (kbd "M-d") 'helm-buffer-run-kill-buffers) ; ok but no confirm???!
    (define-key helm-map (kbd "S-<backspace>") 'helm-previous-source) ; sort of previous page...
    (define-key helm-map (kbd "S-<space>") 'helm-next-source) ; sort of next page...
    (define-key helm-map (kbd "M-<dead-circumflex>") 'previous-history-element) ; not most frequent...
    (define-key helm-map (kbd "M-$") 'next-history-element) ; not most frequent...
    (define-key helm-map (kbd "M-k") 'helm-next-line) ; ok

    ; zxcvbn
    (define-key helm-map (kbd "C-x") 'helm-delete-minibuffer-contents) ; stick to this.
    (define-key helm-map (kbd "C-c") 'nu-copy-region-or-line) ; stick to this
    (define-key helm-find-files-map (kbd "M-c") 'helm-ff-run-copy-file) ; lame
    (define-key helm-map (kbd "C-v") 'helm-yank-text-at-point) ; stick to this.

    ; non char
    (define-key helm-map (kbd "M-<SPC>") 'helm-next-page)
    (define-key helm-map (kbd "M-<backspace>") 'helm-previous-page)
    (define-key helm-find-files-map (kbd "M-=") 'helm-ff-properties-persistent))) ; lame

 ;helm-copy-to-buffer?
 ;helm-yank-selection

(provide 'nu-hooks)
