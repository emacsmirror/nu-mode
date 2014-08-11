
;;
;;   Pierre-Yves Luyten
;;   2014
;;
;;
;;   This file is part of Nu.
;;
;;   Nu is free software: you can redistribute it and/or modify
;;   it under the terms of the GNU General Public License as published by
;;   the Free Software Foundation, either version 3 of the License, or
;;   (at your option) any later version.
;;
;;   Nu is distributed in the hope that it will be useful,
;;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;   GNU General Public License for more details.
;;
;;   You should have received a copy of the GNU General Public License
;;   along with Nu.  If not, see <http://www.gnu.org/licenses/>.
;;
;;
;;

;; Get the macro make-help-screen when this is compiled,
;; or run interpreted, but not when the compiled code is loaded.
(eval-when-compile (require 'help-macro))


(require 'nu-help)

(defun nu-prompt (&optional title message)
 (interactive)
 (setq curb (current-buffer))
 (unless title (setq title "Enter:"))
 (setq buf (generate-new-buffer title))
 (view-buffer-other-window buf)
 (read-only-mode t)
 (org-mode)
 (funcall (and initial-major-mode))
 (setq message
   (concat "\n    ~~~ ☸ ~~~\n" ; U+2638
            message))
 (insert message)
 (setq x (read-event))
 (quit-window)
 (kill-buffer buf)q
 (switch-to-buffer curb)
 (setq x x))


(require 'windmove)


(nu-define-prefix 'nu-window-map)
(define-key nu-window-map (kbd "w") 'nu-close-tab)
(define-key nu-window-map (kbd "C-k") 'kill-buffer)
(define-key nu-window-map (kbd "C-w") 'delete-other-windows)
(define-key nu-window-map (kbd "C-<space>") 'scroll-other-window)
(define-key nu-window-map (kbd "C-<backspace>") 'scroll-other-window-down)
(define-key nu-window-map (kbd "i") 'windmove-up)
(define-key nu-window-map (kbd "j") 'windmove-left)
(define-key nu-window-map (kbd "k") 'windmove-down)
(define-key nu-window-map (kbd "l") 'windmove-right)
(define-key nu-window-map (kbd "t") 'transpose-frame)
(define-key nu-window-map (kbd "C-q") 'save-buffers-kill-emacs)
(defun nu-window-prompt ()
  (interactive)
  (nu-prompt-for-keymap nu-window-map))


(nu-define-prefix 'nu-print-map)
(define-key nu-print-map (kbd "P") 'print-buffer)
(define-key nu-print-map (kbd "p") 'async-shell-command)
(define-key nu-print-map (kbd "s") 'eval-last-sexp)
(define-key nu-print-map (kbd "d") 'ediff)
(define-key nu-print-map (kbd "M-f") 'find-grep)
(define-key nu-print-map (kbd "g") 'grep)
(define-key nu-print-map (kbd "b") 'eval-current-buffer)
(define-key nu-print-map (kbd "w") 'pwd)
(define-key nu-print-map (kbd "-") 'negative-argument)
(define-key nu-print-map (kbd "\C-p") 'universal-argument)
(define-key nu-print-map (kbd "m") 'compile)
(defun nu-print-prompt ()
  (interactive)
  (nu-prompt-for-keymap nu-print-map))


(defun nu-populate-delete ()
  "Populate nu-delete-map."
  (nu-define-prefix 'nu-delete-map)
  (define-key nu-delete-map (kbd "i") 'nu-delete-above-line)
  (define-key nu-delete-map (kbd "j") 'backward-delete-char)
  (define-key nu-delete-map (kbd "M-j") 'nu-backward-kill-line)
  (define-key nu-delete-map (kbd "x") 'kill-whole-line)
  (define-key nu-delete-map (kbd "k") 'nu-delete-below-line)
  (define-key nu-delete-map (kbd "l") 'delete-forward-char)
  (define-key nu-delete-map (kbd "$") 'kill-line)
  (define-key nu-delete-map (kbd "M-l") 'kill-line)
  (define-key nu-delete-map (kbd "u") 'backward-kill-word)
  (define-key nu-delete-map (kbd "o") 'kill-word)
  (define-key nu-delete-map (kbd "M-o") 'nu-delete-a-block)
  (define-key nu-delete-map (kbd "h") 'delete-horizontal-space)
  (define-key nu-delete-map (kbd "t") 'delete-trailing-whitespace)
  (define-key nu-delete-map (kbd "b") 'delete-blank-lines)
  (define-key nu-delete-map (kbd "s") 'kill-sexp)
  (define-key nu-delete-map (kbd "e") 'kill-sentence)
  (define-key nu-delete-map (kbd "f") 'nu-delete-defun)
  (define-key nu-delete-map (kbd "a") 'nu-delete-all)
  (define-key nu-delete-map (kbd "M-f") 'delete-file)
  (if (equal major-mode 'org-mode)
      (progn
        (define-key nu-delete-map (kbd "!") 'org-table-delete-column)
        (define-key nu-delete-map (kbd "-") 'org-table-kill-row)
        (define-key nu-delete-map (kbd "*") 'org-cut-special))))

(defun nu-delete-prompt-internal ()
  (interactive)
  (nu-populate-delete)
  (nu-prompt-for-keymap nu-delete-map))



(defun nu-delete-prompt ()
  (interactive)
  (if mark-active
    (call-interactively 'kill-region)
    (progn
      (nu-delete-prompt-internal)
      (help-make-xrefs (help-buffer)))))


(defun nu-populate-insert-map ()
 "Populate insert map."
  (nu-define-prefix 'nu-insert-map)
  (define-key nu-insert-map (kbd "v") 'nu-yank-pop-or-yank)
  (define-key nu-insert-map (kbd "k") 'yank)
  (define-key nu-insert-map (kbd "i") 'browse-kill-ring)
  (define-key nu-insert-map (kbd "b") 'insert-buffer)
  (define-key nu-insert-map (kbd "f") 'insert-file)
  (define-key nu-insert-map (kbd "c") 'quoted-insert)
  (define-key nu-insert-map (kbd "l") 'open-line)
  (define-key nu-insert-map (kbd "s") 'async-shell-command)
  (define-key nu-insert-map (kbd "S") 'shell-command)
  (if (eq major-mode 'org-mode)
    (progn
      (define-key nu-insert-map (kbd "L") 'org-insert-link)
      (define-key nu-insert-map (kbd "o") 'org-table-insert-column)
      (define-key nu-insert-map (kbd "O") 'org-table-insert-row)
      (define-key nu-insert-map (kbd "t") 'org-insert-todo-heading))))

(defun nu-insert-prompt ()
  (interactive)
  (nu-populate-insert-map)
  (nu-prompt-for-keymap nu-insert-map))



(defun nu-populate-save-map ()
 "Populate save map."
  (nu-define-prefix 'nu-save-map)
  (define-key nu-save-map (kbd "s") 'save-buffer)
  (define-key nu-save-map (kbd "g") 'nu-toggle-goal-column)
  (define-key nu-save-map (kbd "b") 'bookmark-set)
  (define-key nu-save-map (kbd "w") 'ido-write-file)
  (define-key nu-save-map (kbd "r") 'rename-buffer)
  (define-key nu-save-map (kbd "l") 'org-store-link)
  (define-key nu-save-map (kbd "m") 'magit-status)
  ;(if (boundp 'magit-diff)
    (define-key nu-save-map (kbd "d") 'magit-diff)
  ;(if (equal major-mode 'Magit)
    (define-key nu-save-map (kbd "c") 'magit-commit)
  ;(if (equal major-mode 'Magit)
    (define-key nu-save-map (kbd "p") 'magit-push)
  ;(if (boundp 'git-commit-commit)
    (define-key nu-save-map (kbd "x") 'git-commit-commit))

(defun nu-save-prompt ()
  (interactive)
  (nu-populate-save-map)
  (nu-prompt-for-keymap nu-save-map))


(nu-define-prefix 'nu-new-map)
(define-key nu-new-map (kbd "b") 'nu-new-empty-buffer)
(define-key nu-new-map (kbd "w") 'make-frame-command)
(define-key nu-new-map (kbd "v") 'split-window-below)
(define-key nu-new-map (kbd "h") 'split-window-right)
(define-key nu-new-map (kbd "i") 'ibuffer-other-window)
(define-key nu-new-map (kbd "f") 'makedir)
(defun nu-new-prompt ()
  (interactive)
  (nu-prompt-for-keymap nu-new-map))



(nu-define-prefix 'nu-a-map)
(define-key nu-a-map (kbd "a") 'nu-mark-whole-buffer)
(define-key nu-a-map (kbd "f") 'nu-mark-defun)
(define-key nu-a-map (kbd "C-f") 'cd)
(define-key nu-a-map (kbd "s") 'nu-mark-sentence)
(define-key nu-a-map (kbd "w") '_nu-mark-a-word)
(define-key nu-a-map (kbd "C-w") '_nu-select-a-block)
(define-key nu-a-map (kbd "p") 'nu-mark-paragraph)
(define-key nu-a-map (kbd "j") 'nu-mark-to-bol)
(define-key nu-a-map (kbd "l") 'nu-mark-to-eol)
(define-key nu-a-map (kbd "k") '_nu-mark-current-line)
(define-key nu-a-map (kbd "C-<SPC>") 'nu-set-mark)
(define-key nu-a-map (kbd "r") 'nu-set-rectangle-mark)

(defun nu-a-prompt-internal ()
  (interactive)
  (nu-prompt-for-keymap nu-a-map))


(defun nu-a-prompt ()
  "Triggers nu-a-map.

But if mark is active, exchange point and mark."
  (interactive)
     (if mark-active
      (exchange-point-and-mark)
      (nu-a-prompt-internal)))




(defun nu-populate-open-map ()
"Populate open map."
  (setq nu-open-map nil)
  (nu-define-prefix 'nu-open-map)
  (define-key nu-open-map (kbd "f")  'find-file)
  (define-key nu-open-map (kbd "\C-f")  'find-file-other-window)
  (define-key nu-open-map (kbd "r")  'recentf-open-files)
  (define-key nu-open-map (kbd "m")  'bookmark-bmenu-list)
  (define-key nu-open-map (kbd "M")  'bookmark-jump)
  (define-key nu-open-map (kbd "b")  'bookmark-set)
  (define-key nu-open-map (kbd "x")  'list-registers)
  (define-key nu-open-map (kbd "l")  'next-buffer)
  (define-key nu-open-map (kbd "j")   'previous-buffer)
  (define-key nu-open-map (kbd "c")   'org-capture)
  (define-key nu-open-map (kbd "a")   'org-agenda)
  (define-key nu-open-map (kbd "o")   'nu-next-window)
  (define-key nu-open-map (kbd "O")   'nu-previous-window)
  (define-key nu-open-map (kbd "i")   'ibuffer)
  (define-key nu-open-map (kbd "C-i")   'org-iswitchb)
  (define-key nu-open-map (kbd "C-<SPC>") 'ido-switch-buffer)
  (if (eq major-mode 'org-mode)
      (progn
         (define-key nu-open-map (kbd "L") 'org-open-at-point))))

(defun nu-open-prompt ()
  (interactive)
  (nu-populate-open-map)
  (nu-prompt-for-keymap nu-open-map))




(defun nu-global-prompt ()
  (interactive)
  (nu-prompt-for-keymap ctl-x-map))



; we do use native help-map.
; this is an exception : we do not want
; to print the _entire_ help map.
; still, we use this.
;
; this is why a specific prompt is there.
;(make-help-screen nu-help-prompt
;(purecopy "Help")
;"Press q to quit or :
; 
;h: emacs-nu help page
;r: emacs manual
;i: info
;f: describe-function         d: search in documentation
;k: describe-key              m: describe-mode
;v: describe-variable"
;help-map)
(defun nu-help-prompt ()
 (interactive)
 (define-key help-map (kbd "*") 'nu-help)
 ;(define-key help-map (kbd "h") 'nu-help)
 (nu-prompt-for-keymap help-map))


(nu-define-prefix 'nu-find-map)
(define-key nu-find-map (kbd "F") 'nu-isearch-forward)
(define-key nu-find-map (kbd "R") 'nu-isearch-backward)
(define-key nu-find-map (kbd "C-f") 'nu-isearch-forward-regexp)
(define-key nu-find-map (kbd "M-f") 'search-forward-regexp)
(define-key nu-find-map (kbd "r") 'nu-isearch-backward-regexp)
(define-key nu-find-map (kbd "C-r") 'search-backward-regexp)
(define-key nu-find-map (kbd "i") 'beginning-of-buffer)
(define-key nu-find-map (kbd "k") 'end-of-buffer)
(define-key nu-find-map (kbd "b") 'regexp-builder)
(define-key nu-find-map (kbd "s") 'nu-set-mark-1)
(define-key nu-find-map (kbd "l") 'ace-jump-line-mode)
(define-key nu-find-map (kbd "f") 'ace-jump-char-mode)
(define-key nu-find-map (kbd "w") 'ace-jump-word-mode)
(define-key nu-find-map (kbd "z") 'nu-find-char)
(define-key nu-find-map (kbd "\C-z") 'nu-find-char-backward)
(define-key nu-find-map (kbd "g") 'goto-line)
(define-key nu-find-map (kbd "C-g") 'nu-goto-line-previousbuffer)
(defun nu-find-prompt ()
  (interactive)
  (nu-prompt-for-keymap nu-find-map))



(defun nu-toggle-read-only ()
 "Toggle read only mode."
 (interactive)
 (run-with-timer 0.1 nil 'lambda ()
   (interactive)
   (if (eq buffer-read-only t)
   (read-only-mode -1)
   (read-only-mode 1))
   (message "read-only toggled yep!"))
 (message "read only toggled."))

(defun nu-populate-replace ()
  "Create replace-keymap."
  (setq nu-replace-map nil)
  (nu-define-prefix 'nu-replace-map)
  (define-key nu-replace-map (kbd "m") 'nu-toggle-read-only)
  (define-key nu-replace-map (kbd "\C-r")  'query-replace-regexp)
  (define-key nu-replace-map (kbd "a")  'revert-buffer)
  (define-key nu-replace-map (kbd "R")	 'query-replace)
  (define-key nu-replace-map (kbd "k")	 'overwrite-mode)
  (define-key nu-replace-map (kbd "I")	 'replace-string)
  (define-key nu-replace-map (kbd "r")	 'replace-regexp)
  (define-key nu-replace-map (kbd "j")	  'nu-join-with-following-line)
  (define-key nu-replace-map (kbd "J")	  'join-line)
  (define-key nu-replace-map (kbd "t")	  'transpose-lines)
  (define-key nu-replace-map (kbd "z")	  'zap-to-char)
  (define-key nu-replace-map (kbd "u")	  'upcase-word)
  (define-key nu-replace-map (kbd "d") 'downcase-word)
  (define-key nu-replace-map (kbd "c") 'capitalize-word)
  (define-key nu-replace-map (kbd "x") 'nu-rot-reg-or-toggle-rot)
  (define-key nu-replace-map (kbd "h") 'delete-horizontal-space)
  (if (eq major-mode 'org-mode)
      (progn
          (define-key nu-replace-map (kbd "\C-u") 'org-shiftleft)
          (define-key nu-replace-map (kbd "\C-o") 'org-shiftright)
          (define-key nu-replace-map (kbd "C-j") 'org-metaleft)
          (define-key nu-replace-map (kbd "C-l") 'org-metaright)
          (define-key nu-replace-map (kbd "C-i") 'org-metaup)
          (define-key nu-replace-map (kbd "C-k") 'org-metadown))))


(defun nu-replace-do-prompt ()
  (interactive)
  (nu-populate-replace)
  (nu-prompt-for-keymap nu-replace-map))


(defun nu-replace-prompt ()
  (interactive)
  (if (or (eq overwrite-mode 'overwrite-mode-textual)
	  (eq overwrite-mode 'overwrite-mode-binary))
      (overwrite-mode -1)
      (if (eq buffer-read-only t)
        (nu-toggle-read-only)
        (nu-replace-do-prompt))))


(provide 'nu-prompts)
