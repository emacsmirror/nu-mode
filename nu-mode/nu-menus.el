;;; nu-mode.el --- Modern Emacs Keybinding
;;; Emacs-Nu is an emacs mode which wants to makes Emacs easier.kk
;;; Copyright (C) 2017 Pierre-Yves LUYTEN
;;;  
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.
;;;  
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;  
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

;;
;; prompts : first define keys from "common case"
;; that might be shallowed by other modes
;;


(require 'windmove)
(require 'nu-prompters)
(require 'hydra)

(defvar nu-quit-map)
(defvar nu-print-map)
(defvar nu-delete-map)
(defvar nu-insert-map)
(defvar nu-save-map)
(defvar nu-open-map)
(defvar nu-goto-map)
(defvar nu-replace-map)
(defvar nu-window-map)
(defvar nu-new-map)
(defvar nu-a-map)
(defvar nu-find-map)
(defvar nu-copy-map)
(defvar nu-tab-map)
(defvar nu-bold-map)

 (autoload 'zap-up-to-char "misc"
"Kill up to, but not including ARGth occurrence of CHAR." t)



(defun nu-populate-window ()
   (nu-define-prefix 'nu-window-map)
   (define-key nu-window-map (kbd "M-k") 'kill-buffer)
   (define-key nu-window-map (kbd "M-o") 'scroll-other-window-down)
   (define-key nu-window-map (kbd "M-w") 'delete-window)
   (define-key nu-window-map (kbd "Q") 'save-buffers-kill-emacs)
    
   (define-key nu-window-map (kbd "f") 'transpose-frame)
   (define-key nu-window-map (kbd "i") 'enlarge-window)
   (define-key nu-window-map (kbd "j") 'shrink-window-horizontally)
   (define-key nu-window-map (kbd "k") 'shrink-window)
   (define-key nu-window-map (kbd "l") 'enlarge-window-horizontally)
   (define-key nu-window-map (kbd "n")   'nu-next-window)
   (define-key nu-window-map (kbd "o") 'scroll-other-window)
   (define-key nu-window-map (kbd "p")   'nu-previous-window)
   (define-key nu-window-map (kbd "w") 'delete-other-windows)
   (define-key nu-window-map (kbd "x") 'nu-close-document))

(defun nu-window-prompt ()
  (interactive)
  (nu-populate-window)
  (nu-prompt-for-keymap nu-window-map))


(defun nu-populate-print ()
  (nu-define-prefix 'nu-print-map)

  (cond
   ((or (eq nu-major-mode 'emacs-lisp-mode)
	(eq nu-major-mode 'lisp-interaction-mode))
    (define-key nu-print-map (kbd "s") 'eval-last-sexp)
    (define-key nu-print-map (kbd "b") 'eval-buffer)
    (define-key nu-print-map (kbd "M-d") 'eval-defun)
    (define-key nu-print-map (kbd "r") 'eval-region))
   ((eq nu-major-mode 'magit-status-mode)
    (define-key nu-print-map (kbd "p") 'magit-shell-command)
    (define-key nu-print-map (kbd ":") 'magit-git-command))
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-print-map (kbd "C-p") 'dired-do-print)
    (define-key nu-print-map (kbd "C-b") 'dired-do-byte-compile)
    (define-key nu-print-map (kbd "p")   'dired-do-async-shell-command)
    (define-key nu-print-map (kbd "P")   'dired-do-shell-command)
    (define-key nu-print-map (kbd "d")   'dired-diff))
   ((eq nu-major-mode 'texinfo-mode)
    (define-key nu-print-map (kbd "i") 'makeinfo-buffer)
    (define-key nu-print-map (kbd "P") 'nu-texi2pdf))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-print-map (kbd "M-d") 'ibuffer-diff-with-file)
    (define-key nu-print-map (kbd "P") 'ibuffer-do-shell-command-pipe)
    (define-key nu-print-map (kbd "M-f") 'ibuffer-do-shell-command-file)
    (define-key nu-print-map (kbd "r") 'ibuffer-do-print))
   ((eq nu-major-mode 'org-mode)
    (define-key nu-print-map (kbd "l") 'pcomplete)))

  ; common case
  (define-key nu-print-map (kbd "C-p") 'print-buffer)
  (define-key nu-print-map (kbd "p") 'async-shell-command)
  (define-key nu-print-map (kbd "d") 'ediff)
  (define-key nu-print-map (kbd "c") 'subword-mode)
  (define-key nu-print-map (kbd "f") 'find-grep)
  (define-key nu-print-map (kbd "g") 'grep)
  (define-key nu-print-map (kbd "k") 'kmacro-end-or-call-macro)
  (define-key nu-print-map (kbd "m") 'compile)
  (define-key nu-print-map (kbd "n") 'negative-argument)
  (define-key nu-print-map (kbd "u") 'universal-argument)
  (define-key nu-print-map (kbd "w") 'pwd))


(defun nu-print-prompt ()
  (interactive)
  (nu-populate-print)
  (nu-prompt-for-keymap nu-print-map))


(defun nu-populate-quit ()
  "Populate quit map."
 (nu-define-prefix 'nu-quit-map)
 (define-key nu-quit-map (kbd "C-m") 'save-buffers-kill-emacs)
 (define-key nu-quit-map (kbd "e") 'kill-emacs)
 (define-key nu-quit-map (kbd "f") 'delete-frame)
 (define-key nu-quit-map (kbd "q") 'keyboard-escape-quit)
 (define-key nu-quit-map (kbd "w") 'quit-window))


(defun nu-quit-prompt ()
  "Prompt to quit."
  (interactive)
  (if mark-active
      (cua-set-mark)
      (progn
        (nu-populate-quit)
        (nu-prompt-for-keymap nu-quit-map))))

(defun nu-populate-delete ()
  "Populate nu-delete-map."
  (nu-define-prefix 'nu-delete-map)

  (cond
   ((eq nu-major-mode 'magit-status-mode)
    (define-key nu-delete-map (kbd "b") 'magit-delete-branch)
    (define-key nu-delete-map (kbd "h") 'magit-discard-item))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-delete-map (kbd "M-d") 'ibuffer-do-delete)
    (define-key nu-delete-map (kbd "M-k") 'ibuffer-do-kill-lines)
    (define-key nu-delete-map (kbd "c") 'ibuffer-copy-filename-as-kill)
    (define-key nu-delete-map (kbd "d") 'ibuffer-do-delete)
    (define-key nu-delete-map (kbd "k") 'ibuffer-kill-line)
    (define-key nu-delete-map (kbd "m") 'ibuffer-mark-for-delete))
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-delete-map (kbd "d") 'dired-flag-file-deletion)
    (define-key nu-delete-map (kbd "k") 'dired-do-flagged-delete)
    (define-key nu-delete-map (kbd "o") 'dired-do-delete))
   (t
    (define-key nu-delete-map (kbd "M-f") 'flush-lines)
    (define-key nu-delete-map (kbd "M-l") 'kill-line)
    (define-key nu-delete-map (kbd "a") 'nu-delete-all)
    (define-key nu-delete-map (kbd "b") 'delete-blank-lines)
    (define-key nu-delete-map (kbd "k") 'kill-buffer)
    (define-key nu-delete-map (kbd "d") 'kill-whole-line)
    (define-key nu-delete-map (kbd "e") 'kill-sentence)
    (define-key nu-delete-map (kbd "f") 'nu-delete-defun)
    (define-key nu-delete-map (kbd "h") 'delete-horizontal-space)
    (define-key nu-delete-map (kbd "s") 'kill-sexp)
    (define-key nu-delete-map (kbd "t") 'delete-trailing-whitespace)
    (define-key nu-delete-map (kbd "z")  'zap-up-to-char)))

  ; common cases
  (define-key nu-delete-map (kbd "F") 'delete-file)
  (define-key nu-delete-map (kbd "j") 'delete-other-windows)
  (define-key nu-delete-map (kbd "l") 'delete-window)

  ; these ones are additional	.	..
  (if (eq nu-major-mode 'org-mode)
      (progn
        (define-key nu-delete-map (kbd "!") 'org-table-delete-column)
        (define-key nu-delete-map (kbd "r") 'org-table-kill-row)
        (define-key nu-delete-map (kbd "*") 'org-cut-special)
        (define-key nu-delete-map (kbd "M-k") 'org-cut-subtree)))

  (if mark-active
    (define-key nu-delete-map (kbd "<RET>") 'kill-region)))

(defun nu-delete-prompt ()
  (interactive)
  (nu-populate-delete)
  (nu-prompt-for-keymap nu-delete-map))






(defun nu-populate-bold-map ()
 "Populate bold map	.	"
  (nu-define-prefix 'nu-bold-map)
  (define-key nu-bold-map (kbd "a") 'align)
  (define-key nu-bold-map (kbd "f") 'fill-paragraph)
  (define-key nu-bold-map (kbd "i") 'indent)
  (if (or (eq nu-major-mode 'c-mode)
          (eq nu-major-mode 'lisp-interaction-mode)
          (eq nu-major-mode 'emacs-lisp-mode))
      (progn
          (define-key nu-bold-map (kbd "M-c") 'comment-or-uncomment-region)
          (define-key nu-bold-map (kbd "c") 'comment-dwim)
          (define-key nu-bold-map (kbd "m") 'comment-indent-new-line)
          (define-key nu-bold-map (kbd "l") 'comment-indent))))

(defun nu-bold-prompt ()
  (interactive)
  (nu-populate-bold-map)
  (nu-prompt-for-keymap nu-bold-map))


(defun nu-populate-insert-map ()
 "Populate insert map	.	"
  (nu-define-prefix 'nu-insert-map)

  (if (eq nu-major-mode 'dired-mode)
        (progn
           (define-key nu-insert-map (kbd "v") 'dired-maybe-insert-subdir)
           (define-key nu-insert-map (kbd "M-v") 'dired-create-directory))
         ; else
        (define-key nu-insert-map (kbd "M-v") 'expand-abbrev)
        (define-key nu-insert-map (kbd "V") 'nu-yank-pop-or-yank) ; absurd	.	
        (define-key nu-insert-map (kbd "b") 'insert-buffer)
        (define-key nu-insert-map (kbd "c") 'quoted-insert)
        (define-key nu-insert-map (kbd "f") 'insert-file)
        (define-key nu-insert-map (kbd "i") 'nu-insert-line-above)
        (define-key nu-insert-map (kbd "k") 'nu-insert-line-below)
        (define-key nu-insert-map (kbd "r") 'yank-rectangle)
        (define-key nu-insert-map (kbd "M-r") 'open-rectangle)
        (define-key nu-insert-map (kbd "v") 'yank)

        ; addon
        (if (eq nu-major-mode 'texinfo-mode)
          (progn
            (define-key nu-insert-map (kbd "M-u") 'texinfo-insert-@url)
            (define-key nu-insert-map (kbd "M-k") 'texinfo-insert-@kbd))
        (if (eq nu-major-mode 'org-mode)
          (progn
            (define-key nu-insert-map (kbd "L") 'org-insert-link)
            (define-key nu-insert-map (kbd "o") 'org-table-insert-column)
            (define-key nu-insert-map (kbd "O") 'org-table-insert-row)
            (define-key nu-insert-map (kbd "M-s") 'org-paste-subtree)
            (define-key nu-insert-map (kbd "M-o") 'org-paste-special)
            (define-key nu-insert-map (kbd "m") 'org-time-stamp)
            (define-key nu-insert-map (kbd "d") 'org-deadline)
            (define-key nu-insert-map (kbd "t") 'org-insert-todo-heading)))))

  ; anycase
  (define-key nu-insert-map (kbd "S") 'shell-command)
  (define-key nu-insert-map (kbd "g") 'define-global-abbrev)
  (define-key nu-insert-map (kbd "h")  'nu-browse-kill-ring)
  (define-key nu-insert-map (kbd "s") 'async-shell-command))


(defun nu-insert-prompt ()
  (interactive)
  (nu-populate-insert-map)
  (nu-prompt-for-keymap nu-insert-map))


(defun nu-populate-save-map ()
 "Populate save map	.	"
  (nu-define-prefix 'nu-save-map)
  (define-key nu-save-map (kbd "L") 'org-store-link)
  (define-key nu-save-map (kbd "M-f") 'frame-configuration-to-register)
  (define-key nu-save-map (kbd "M-s") 'write-file)
  (define-key nu-save-map (kbd "b") 'bookmark-set)
  (define-key nu-save-map (kbd "g") 'nu-toggle-goal-column)
  (define-key nu-save-map (kbd "r") 'rename-buffer)
  (define-key nu-save-map (kbd "s") 'save-buffer)
  (define-key nu-save-map (kbd "w") 'window-configuration-to-register)
  (if (eq nu-major-mode 'org-mode)
      (progn
        (define-key nu-save-map (kbd "o") 'org-refile)
        (define-key nu-save-map (kbd "M-o") 'org-save-all-org-buffers)))
  (define-key nu-save-map (kbd "k") 'kmacro-start-macro-or-insert-counter)
  (define-key nu-save-map (kbd "f") 'nu-create-tags)

  (if (eq nu-major-mode 'magit-status-mode)
      (progn
        (define-key nu-save-map (kbd "d") 'magit-diff)
        (define-key nu-save-map (kbd "c") 'magit-commit)
        (define-key nu-save-map (kbd "p") 'nu-git-push)
        (define-key nu-save-map (kbd "t") 'magit-push-tags)
        (define-key nu-save-map (kbd "x") 'git-commit-commit))
      ; else
      (define-key nu-save-map (kbd "m") 'magit-status)))


(defun nu-save-prompt ()
  (interactive)
  (nu-populate-save-map)
  (nu-prompt-for-keymap nu-save-map))


(defun nu-populate-new-map ()
  (nu-define-prefix 'nu-new-map)

  (if (eq nu-major-mode 'dired-mode)
      ; switch what does d according to mode
      (define-key nu-new-map (kbd "d") 'dired-create-directory)
      (define-key nu-new-map (kbd "d") 'make-directory))

  (if (eq nu-major-mode 'magit-status-mode)
      (progn
      (define-key nu-new-map (kbd "b") 'magit-create-branch)
      (define-key nu-new-map (kbd "a") 'magit-annotated-tag)))

  (define-key nu-new-map (kbd "C-n") 'helm-run-external-command)
  (define-key nu-new-map (kbd "h") 'split-window-right)
  (define-key nu-new-map (kbd "i") 'ibuffer-other-window)
  (define-key nu-new-map (kbd "m") 'compose-mail)
  (define-key nu-new-map (kbd "n") 'nu-new-empty-buffer)
  (define-key nu-new-map (kbd "o")   'org-capture)
  (define-key nu-new-map (kbd "p") 'package-list-packages)
  (define-key nu-new-map (kbd "s") 'eshell)
  (define-key nu-new-map (kbd "t") 'term)
  (define-key nu-new-map (kbd "v") 'split-window-below)

  (define-key nu-new-map (kbd "w") 'make-frame-command))


(defun nu-new-prompt ()
  (interactive)
  (nu-populate-new-map)
  (nu-prompt-for-keymap nu-new-map))


(defhydra nu-selection-hydra (:color pink
                	      :hint   nil)
"
_<SPC>_: move cursor around mark
_c_ : copy region
_d_ : kill region
_r_ : replace prompt

QUIT : _q_ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
("<SPC>" exchange-point-and-mark) ; does not exit.
("q" pop-to-mark-command :exit t)
("M-q" pop-to-mark-command :exit t)
("d" kill-region :exit t)
("r" (lambda () (interactive) (nu-completion-prompt-for-keymap nu-replace-map)))
("c" copy-region-as-kill :exit t))

(defhydra nu-rectangle-selection-hydra (:color pink
                	                :hint   nil)
"
_<SPC>_: move cursor around mark
_c_ : copy rectangle
_d_ : kill rectangle
_r_ : replace prompt
_i_ : insert 
_j_ : insert 

QUIT : _q_ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
("<SPC>" rectangle-exchange-point-and-mark)
("q" pop-to-mark-command :exit t)
("M-q" pop-to-mark-command :exit t)
("c" copy-rectangle-as-kill :exit t)
("d" kill-rectangle :exit t)
("r" (lambda () (interactive) (nu-completion-prompt-for-keymap nu-replace-map)))
("j" string-rectangle :exit t)
("i" string-insert-rectangle :exit t)
("q" nil :exit t))

(defun nu-populate-a-map ()
  (nu-define-prefix 'nu-a-map)

  (define-key nu-a-map (kbd "C-f") 'cd)
    
  (cond
   ((eq nu-major-mode 'proced)
    (define-key nu-a-map (kbd "M-a") 'proced-unmark-all)
    (define-key nu-a-map (kbd "a") 'proced-mark-all)
    (define-key nu-a-map (kbd "c") 'proced-mark-children)
    (define-key nu-a-map (kbd "l") 'proced-mark)
    (define-key nu-a-map (kbd "p") 'proced-mark-parents)
    (define-key nu-a-map (kbd "t") 'proced-toggle-marks)
    (define-key nu-a-map (kbd "u") 'proced-unmark))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-a-map (kbd "D") 'ibuffer-mark-dired-buffers)
    (define-key nu-a-map (kbd "H") 'ibuffer-mark-help-buffers)
    (define-key nu-a-map (kbd "M-d") 'ibuffer-mark-for-delete-backwards)
    (define-key nu-a-map (kbd "M-f") 'ibuffer-mark-dissociated-buffers)
    (define-key nu-a-map (kbd "M-i") 'ibuffer-backwards-next-marked)
    (define-key nu-a-map (kbd "M-k") 'ibuffer-forward-next-marked)
    (define-key nu-a-map (kbd "M-m") 'ibuffer-mark-by-mode)
    (define-key nu-a-map (kbd "M-r") 'nu-set-rectangle-mark)
    (define-key nu-a-map (kbd "M-u") 'ibuffer-unmark-all)
    (define-key nu-a-map (kbd "S") 'ibuffer-mark-special-buffers)
    (define-key nu-a-map (kbd "c") 'ibuffer-mark-unsaved-buffers)
    (define-key nu-a-map (kbd "d") 'ibuffer-mark-for-delete)
    (define-key nu-a-map (kbd "e") 'ibuffer-mark-modified-buffers)
    (define-key nu-a-map (kbd "f") 'ibuffer-mark-by-file-name-regexp)
    (define-key nu-a-map (kbd "i") 'ibuffer-unmark-backward)
    (define-key nu-a-map (kbd "k") 'ibuffer-mark-forward)
    (define-key nu-a-map (kbd "m") 'ibuffer-mark-by-mode-regexp)
    (define-key nu-a-map (kbd "n") 'ibuffer-mark-by-name-regexp)
    (define-key nu-a-map (kbd "o") 'ibuffer-mark-old-buffers)
    (define-key nu-a-map (kbd "r") 'ibuffer-mark-read-only-buffers)
    (define-key nu-a-map (kbd "t") 'ibuffer-toggle-marks)
    (define-key nu-a-map (kbd "u") 'ibuffer-unmark-forward)
    (define-key nu-a-map (kbd "x") 'ibuffer-do-kill-on-deletion-marks)
    (define-key nu-a-map (kbd "z") 'ibuffer-mark-compressed-file-buffers))
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-a-map (kbd "M-r") 'dired-mark-files-containing-regexp)
    (define-key nu-a-map (kbd "M-u") 'dired-unmark-all-marks)
    (define-key nu-a-map (kbd "d") 'dired-flag-file-deletion)
    (define-key nu-a-map (kbd "m") 'dired-mark)
    (define-key nu-a-map (kbd "r") 'dired-flag-files-regexp)
    (define-key nu-a-map (kbd "r") 'dired-mark-files-regexp)
    (define-key nu-a-map (kbd "s") 'nu-mark-subdirs-files)
    (define-key nu-a-map (kbd "u") 'dired-unmark)
    (define-key nu-a-map (kbd "x") 'dired-toggle-marks))
   (t
     (define-key nu-a-map (kbd "a") 'nu-mark-whole-buffer)
     (define-key nu-a-map (kbd "f") 'nu-mark-defun)
     (define-key nu-a-map (kbd "i") 'nu-set-mark)
     (define-key nu-a-map (kbd "r") 'nu-set-rectangle-mark))))

(defun nu-a-prompt ()
  "Triggers nu-a-map.

But if mark is active, exchange point and mark."
  (interactive)
  (nu-populate-a-map)
  (nu-prompt-for-keymap nu-a-map))

; on #master this is C,
; on #noxpaddle this is M...
(defun nu-populate-open-map ()
"Populate open map."
  (setq nu-open-map nil)
  (nu-define-prefix 'nu-open-map)

  ;; common case
  (define-key nu-open-map (kbd "B")  'bookmark-jump)
  (define-key nu-open-map (kbd "C-f")  'find-file-other-window) ; useless now that helm fixes this stuff =)
  (define-key nu-open-map (kbd "C-j")   'nu-previous-buffer)
  (define-key nu-open-map (kbd "C-l")  'nu-next-buffer)
  (define-key nu-open-map (kbd "C-o") 'ido-switch-buffer)
  (define-key nu-open-map (kbd "C-r")  'helm-register)
  (define-key nu-open-map (kbd "a")   'org-agenda)
  (define-key nu-open-map (kbd "b")  'nu-bookmarks)
  (define-key nu-open-map (kbd "f")  'nu-find-files)
  (define-key nu-open-map (kbd "i")   'ibuffer) ; is better at _reorganizing_ buffers...
  (define-key nu-open-map (kbd "l")   'nu-buffers-list)
  (define-key nu-open-map (kbd "m")   'menu-bar-read-mail)
  (define-key nu-open-map (kbd "o")  'helm-mini)
  (define-key nu-open-map (kbd "r")  'nu-recentf)
  (define-key nu-open-map (kbd "s") 'org-iswitchb)
  (define-key nu-open-map (kbd "u")  'browse-url)
  (define-key nu-open-map (kbd "x")  'list-registers)

  (cond
   ((eq nu-major-mode 'magit-status-mode)
    (define-key nu-open-map (kbd "g") 'magit-log-long)
    (define-key nu-open-map (kbd "C-b") 'magit-branch-manager))
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-open-map (kbd "d") 'dired-find-file)
    (define-key nu-open-map (kbd "C-d") 'dired-find-file-other-window))
   ((eq nu-major-mode 'org-mode)
    (define-key nu-open-map (kbd "L") 'org-open-at-point))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-open-map (kbd "h") 'ibuffer-do-view-horizontally)
    (define-key nu-open-map (kbd "i") 'ibuffer-find-file))))


(defun nu-open-prompt ()
"Maybe temporary prompt."
  (interactive)
  (nu-populate-open-map)
  (nu-prompt-for-keymap nu-open-map))




(defun nu-populate-goto-map ()
"Populate goto map."
  (setq nu-goto-map nil)
  (nu-define-prefix 'nu-goto-map)

  ;; actually this case is : all read only modes...
  (cond
   ((eq nu-major-mode 'dired-mode)
     ; i should go parent dir. k should try to persistent-action subdir.
    (define-key nu-goto-map (kbd "u") 'dired-prev-marked-file)
    (define-key nu-goto-map (kbd "o") 'dired-next-marked-file))
   ((eq nu-major-mode 'help-mode)
    (define-key nu-goto-map (kbd "L") 'forward-button)
    (define-key nu-goto-map (kbd "J") 'backward-button)
    (define-key nu-goto-map (kbd "o") 'push-button)
    (define-key nu-goto-map (kbd "u") 'help-go-back))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-goto-map (kbd "J") 'ibuffer-jump-to-buffer))
   (t
      ; else - default goto map.
      (define-key nu-goto-map (kbd "L") 'forward-sentence)
      (define-key nu-goto-map (kbd "J") 'backward-sentence)
      (define-key nu-goto-map (kbd "u") 'backward-paragraph)
      (define-key nu-goto-map (kbd "o") 'forward-paragraph)
      (define-key nu-goto-map (kbd "f") 'end-of-defun)
      (define-key nu-goto-map (kbd "M-f") 'beginning-of-defun)
      (define-key nu-goto-map (kbd "*") 'forward-list)
      (define-key nu-goto-map (kbd "M-*") 'backward-list)))

   ;
   ; common keys
   ;

   (define-key nu-goto-map (kbd "M-e") 'previous-error)
   (define-key nu-goto-map (kbd "M-g") 'nu-goto-line-previousbuffer)

   (define-key nu-goto-map (kbd "M-s") 'org-mark-ring-goto)
   (define-key nu-goto-map (kbd "e") 'next-error)
   (define-key nu-goto-map (kbd "g") 'avy-goto-line)
   (define-key nu-goto-map (kbd "G") 'goto-line)
   (define-key nu-goto-map (kbd "i") 'beginning-of-buffer)
   (define-key nu-goto-map (kbd "k") 'end-of-buffer)
   (define-key nu-goto-map (kbd "s") 'nu-find-previous-mark)
   (define-key nu-goto-map (kbd "m") 'nu-buffers-list)


   ;;
   ;; add-ons
   ;;

   (if (eq nu-major-mode 'org-mode)
       (progn
         (define-key nu-goto-map (kbd "I") 'org-backward-heading-same-level)
         (define-key nu-goto-map (kbd "K") 'org-forward-heading-same-level)
         (define-key nu-goto-map (kbd "J") 'org-backward-element)
         (define-key nu-goto-map (kbd "L") 'org-forward-element))))


(defun nu-goto-prompt ()
"Offer to goto wherever wished."
  (interactive)
  (nu-populate-goto-map)
  (nu-prompt-for-keymap nu-goto-map))


(defun nu-global-prompt ()
"Offer x keymap. Temporary function."
  (interactive)
  (nu-prompt-for-keymap ctl-x-map))


;; TODO insert into hydra....
;; emacs-nu help page        emacs manual
;; info                      describe-function
;; search in documentation   describe-key
;; describe-mode             describe-variable

(defhydra hydra-nu-help-menu (:color pink
                              :hint nil)
"
~~~~~~~~~~~~~  WELCOME TO EMACS NU HELP! ~~~~~~~~~~~~~~~
Press q to quit any prompt. Press Alt+q to quit commands

MOST FREQUENT HELP FUNCTIONS
--------------------------------------------------------
_f_ describe function       _j_   describe-variable
_k_ describe key (then type a key or shortcut)
_<SPC>_ where-is
_u_ describe keymap  (for example nu-keymap)
_i_ info directory

ALL HELP FUNCTIONS : _h_ prompt for help map
-------------------------------------------------------

OTHER
-------------------------------------------------------
_o_ describe bindings       _m_   describe mode
_y_ find function on key
"
  ("i" info-directory :exit t)
  ("f" nu-describe-function :exit t)
  ("j" nu-describe-variable :exit t)
  ("k" describe-key :exit t)
  ("u" describe-keymap :exit t)
  ("o" describe-bindings :exit t)
  ("m" describe-mode :exit t)
  ("y" find-function-on-key :exit t)
  ("<SPC>" where-is :exit t)
  ("h" (nu-buffer-prompt-for-keymap help-map) :exit t))


(defun nu-help-prompt ()
  (interactive)
  (define-key help-map (kbd "*") 'nu-help)
  (hydra-nu-help-menu/body))


(defun nu-populate-find-map ()
  (nu-define-prefix 'nu-find-map)

  (cond
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-find-map (kbd "f") 'dired-mark-files-containing-regexp)
    (define-key nu-find-map (kbd "s") 'dired-isearch-filenames)
    (define-key nu-find-map (kbd "M-s") 'dired-do-isearch)
    (define-key nu-find-map (kbd "%") 'dired-isearch-filenames-regexp)
    (define-key nu-find-map (kbd "x") 'dired-do-isearch-regexp))
   ((eq nu-major-mode 'ibuffer-mode)
    (define-key nu-find-map (kbd "M-o") 'ibuffer-do-occur))
   (t
    (define-key nu-find-map (kbd "F") 'nu-isearch-forward)
    (define-key nu-find-map (kbd "M-F") 'search-forward-regexp)
    (define-key nu-find-map (kbd "M-R") 'search-backward-regexp)
    (define-key nu-find-map (kbd "M-f") 'nu-isearch-forward-regexp)
    (define-key nu-find-map (kbd "M-z") 'nu-find-char-backward)
    (define-key nu-find-map (kbd "R") 'nu-isearch-backward)
    (define-key nu-find-map (kbd "f") 'ace-jump-char-mode)
    (define-key nu-find-map (kbd "l") 'ace-jump-line-mode)
    (define-key nu-find-map (kbd "r") 'nu-isearch-backward-regexp)
    (define-key nu-find-map (kbd "w") 'ace-jump-word-mode)))

  ; common keys
  (define-key nu-find-map (kbd "b") 'regexp-builder)
  (define-key nu-find-map (kbd "g") 'rgrep)
  (define-key nu-find-map (kbd "m") 'helm-imenu)
  (define-key nu-find-map (kbd "o") 'occur)
  (define-key nu-find-map (kbd "t") 'find-tag)
  (define-key nu-find-map (kbd "z") 'nu-find-char))

(defun nu-find-prompt ()
  (interactive)
  (nu-populate-find-map)
  (nu-prompt-for-keymap nu-find-map))


(defun nu-toggle-read-only ()
 "Toggle read only mode."
 (interactive)
 (run-with-timer 0.1 nil 'lambda ()
              (if (eq buffer-read-only t)
                  (read-only-mode -1)
                  (read-only-mode 1)))
 (message "read only toggled."))


(defun nu-populate-copy-map ()
  (nu-define-prefix 'nu-copy-map)
  (cond
   ((eq nu-major-mode 'dired-mode)
    (define-key nu-copy-map (kbd "c") 'dired-do-copy)
    (define-key nu-copy-map (kbd "C-c") 'dired-copy-filename-as-kill)
    (define-key nu-copy-map (kbd "h") 'dired-do-hardlink)
    (define-key nu-copy-map (kbd "s") 'dired-do-symlink))
   (t
    (define-key nu-copy-map (kbd "r") 'copy-rectangle-as-kill)
    (define-key nu-copy-map (kbd "c") 'nu-copy-region-or-line)
    (define-key nu-copy-map (kbd "e") 'nu-copy-from-above)
    (define-key nu-copy-map (kbd "y") 'nu-copy-from-below))))


(defun nu-copy-prompt ()
 (interactive)
 (nu-populate-copy-map)
 (nu-prompt-for-keymap nu-copy-map))


(defalias 'toggle-sorting-by-date-or-name 'dired-sort-toggle-or-edit)

(defun nu-populate-replace-dired ()
  (setq nu-replace-map nil)
  (nu-define-prefix 'nu-replace-map)
  (define-key nu-replace-map (kbd "c") 'dired-do-chmod)
  (define-key nu-replace-map (kbd "d") 'dired-downcase)
  (define-key nu-replace-map (kbd "g") 'dired-do-chgrp)
  (define-key nu-replace-map (kbd "o") 'dired-do-chown)
  (define-key nu-replace-map (kbd "r") 'dired-do-rename)
  (define-key nu-replace-map (kbd "s") 'toggle-sorting-by-date-or-name)
  (define-key nu-replace-map (kbd "t") 'dired-do-touch)
  (define-key nu-replace-map (kbd "u") 'dired-upcase)
  (define-key nu-replace-map (kbd "w") 'wdired-change-to-wdired-mode)
  (define-key nu-replace-map (kbd "z") 'dired-do-compress))

(defun nu-populate-replace-ibuffer ()
  (setq nu-replace-map nil)
  (nu-define-prefix 'nu-replace-map)
  (define-key nu-replace-map (kbd "M-r") 'ibuffer-do-replace-regexp)
  (define-key nu-replace-map (kbd "a") 'ibuffer-do-sort-by-alphabetic)
  (define-key nu-replace-map (kbd "f") 'ibuffer-do-sort-by-filename/process)
  (define-key nu-replace-map (kbd "i") 'ibuffer-invert-sorting)
  (define-key nu-replace-map (kbd "m") 'ibuffer-do-sort-by-major-mode)
  (define-key nu-replace-map (kbd "n") 'ibuffer-do-rename-uniquely)
  (define-key nu-replace-map (kbd "q") 'ibuffer-do-query-replace)
  (define-key nu-replace-map (kbd "r") 'ibuffer-do-revert)
  (define-key nu-replace-map (kbd "s") 'ibuffer-do-sort-by-size)
  (define-key nu-replace-map (kbd "t") 'ibuffer-do-toggle-read-only)
  (define-key nu-replace-map (kbd "v") 'ibuffer-do-sort-by-recency))

(defalias 'git-checkout-item 'magit-discard-item)
(defalias 'git-pull-rebase 'magit-rebase-step)
(defalias 'git-toggle-amend-next-commit 'magit-log-edit-toggle-amending)


(defun nu-populate-replace-magit ()
  (setq nu-replace-map nil)
  (nu-define-prefix 'nu-replace-map)
  (define-key nu-replace-map (kbd "a") 'git-toggle-amend-next-commit)
  (define-key nu-replace-map (kbd "b") 'magit-move-branch)
  (define-key nu-replace-map (kbd "k") 'git-checkout-item)
  (define-key nu-replace-map (kbd "r") 'git-pull-rebase))


(defun nu-populate-replace ()
  "Create replace-keymap."
  (setq nu-replace-map nil)
  (nu-define-prefix 'nu-replace-map)

  (define-key nu-replace-map (kbd "J")  'join-line)
  (define-key nu-replace-map (kbd "M-f")  'sort-regexp-fields)
  (define-key nu-replace-map (kbd "M-r")  'query-replace-regexp)
  (define-key nu-replace-map (kbd "M-s")  'sort-lines)
  (define-key nu-replace-map (kbd "R")  'query-replace)
  (define-key nu-replace-map (kbd "a")  'revert-buffer)
  (define-key nu-replace-map (kbd "c") 'capitalize-word)
  (define-key nu-replace-map (kbd "d") 'downcase-word)
  (define-key nu-replace-map (kbd "e")  'keep-lines)
  (define-key nu-replace-map (kbd "f")  'sort-fields)
  (define-key nu-replace-map (kbd "g")  'clear-rectangle)
  (define-key nu-replace-map (kbd "G")  'delete-whitespace-rectangle)
  (define-key nu-replace-map (kbd "M-g")  'string-rectangle)
  (define-key nu-replace-map (kbd "h") 'delete-horizontal-space)
  (define-key nu-replace-map (kbd "j")  'nu-join-with-following-line)
  (define-key nu-replace-map (kbd "k")  'overwrite-mode)
  (define-key nu-replace-map (kbd "m") 'nu-toggle-read-only)
  (define-key nu-replace-map (kbd "n")  'sort-numeric-fields)
  (define-key nu-replace-map (kbd "r")  'replace-regexp)
  (define-key nu-replace-map (kbd "s")  'replace-string)
  (define-key nu-replace-map (kbd "t")  'transpose-lines)
  (define-key nu-replace-map (kbd "u") 'upcase-word)
  (define-key nu-replace-map (kbd "x") 'nu-rot-reg-or-toggle-rot)


  (if (not (fboundp 'ethan-wspace-untabify))
    (defun ethan-wspace-untabify ()
      (interactive)
      (message "Please install ethan-wspace mode!")))
  (define-key nu-replace-map (kbd "t") 'ethan-wspace-untabify)

  (if (eq nu-major-mode 'c-mode)
      (define-key nu-replace-map (kbd "y") 'c-set-style))


  (if (eq nu-major-mode 'org-mode)
      (progn
          (define-key nu-replace-map (kbd "J") 'org-shiftleft)
          (define-key nu-replace-map (kbd "K") 'org-shiftdown)
          (define-key nu-replace-map (kbd "L") 'org-shiftright)
          (define-key nu-replace-map (kbd "I") 'org-shiftup)
          (define-key nu-replace-map (kbd "C-j") 'org-metaleft)
          (define-key nu-replace-map (kbd "C-l") 'org-metaright)
          (define-key nu-replace-map (kbd "C-u") 'org-metaup)
  (define-key nu-replace-map (kbd "C-o") 'org-metadown))))


(defun nu-replace-prompt ()
  (interactive)
      (cond
        ((eq nu-major-mode 'dired-mode)
         (nu-populate-replace-dired)
	 (nu-prompt-for-keymap nu-replace-map))
	((eq nu-major-mode 'ibuffer-mode)
	 (nu-populate-replace-ibuffer)
         (nu-prompt-for-keymap nu-replace-map))
        ((eq nu-major-mode 'magit-status-mode)
         (nu-populate-replace-magit)
         (nu-prompt-for-keymap nu-replace-map))
        ((or (eq overwrite-mode 'overwrite-mode-textual)
             (eq overwrite-mode 'overwrite-mode-binary))
         (overwrite-mode -1))
        ((eq buffer-read-only t)
         (nu-toggle-read-only))
        (t
         (nu-populate-replace)
         (nu-prompt-for-keymap nu-replace-map))))


;;
;; term
;;


(defun nu-tmp-prompt-for-term-line-c-c ()
  "Temporary map... to be improved."
  (interactive)
  (nu-define-prefix 'nu-term-line-c-c)

  (define-key nu-term-line-c-c (kbd "c") 'nu-copy-region-or-line)

  ; stolen from term mode map C-c part...
  (define-key nu-term-line-c-c (kbd "C-\\") 'term-quit-subjob)
  (define-key nu-term-line-c-c (kbd "C-a") 'term-bol)
  (define-key nu-term-line-c-c (kbd "C-c") 'term-interrupt-subjob)
  (define-key nu-term-line-c-c (kbd "C-d") 'term-send-eof)
  (define-key nu-term-line-c-c (kbd "C-e") 'term-show-maximum-output)
  (define-key nu-term-line-c-c (kbd "C-j") 'term-line-mode)
  (define-key nu-term-line-c-c (kbd "C-k") 'term-char-mode)
  (define-key nu-term-line-c-c (kbd "C-l") 'term-dynamic-list-input-ring)
  (define-key nu-term-line-c-c (kbd "C-n") 'term-next-prompt)
  (define-key nu-term-line-c-c (kbd "C-o") 'term-kill-output)
  (define-key nu-term-line-c-c (kbd "C-p") 'term-previous-prompt)
  (define-key nu-term-line-c-c (kbd "C-q") 'term-pager-toggle)
  (define-key nu-term-line-c-c (kbd "C-r") 'term-show-output)
  (define-key nu-term-line-c-c (kbd "C-u") 'term-kill-input)
  (define-key nu-term-line-c-c (kbd "C-w") 'backward-kill-word)
  (define-key nu-term-line-c-c (kbd "C-z") 'term-stop-subjob)
  (define-key nu-term-line-c-c (kbd "RET") 'term-copy-old-input)

  (nu-prompt-for-keymap nu-term-line-c-c))

(defvar nu-term-map "Map for term single point of entry.")

(defun nu-prompt-for-term ()
  "This is a specific prompt designed to make term usable.

& still, respect cua principles. The idea is to let the user
both navigate, access to essential prompts, and control the terminal."
  (interactive)
  (nu-define-prefix 'nu-term-map)

  ; paddle keys are dedicated to direct functions
  ; either to navigate or do something with term.
  (define-key nu-term-map (kbd "i") 'helm-buffers-list)
  (define-key nu-term-map (kbd "k") 'ibuffer)
  (define-key nu-term-map (kbd "l") 'term-line-mode)


  ; This includes internal windows
  ; or other functions using modified buffers keys.
  ; since control is necessary to run this prompt
  ; we use control as the unique modifier...
   (define-key nu-term-map (kbd "C-i") 'windmove-up)
   (define-key nu-term-map (kbd "C-j") 'windmove-left)
   (define-key nu-term-map (kbd "C-k") 'windmove-down)
   (define-key nu-term-map (kbd "C-l") 'windmove-right)


  ; Prompt keys will run prompt, but that means
  ; at least three keys to run a func :
  ; term prompt -> nu prompt -> func
  ; so whenever it might be avoided it should.
  (define-key nu-term-map (kbd "c") 'nu-copy-region-or-line)
  (define-key nu-term-map (kbd "d") 'nu-delete-prompt)
  (define-key nu-term-map (kbd "g") 'nu-goto-prompt)
  (define-key nu-term-map (kbd "h") 'nu-help-prompt)
  (define-key nu-term-map (kbd "n") 'nu-new-prompt)
  (define-key nu-term-map (kbd "o") 'nu-open-prompt)
  (define-key nu-term-map (kbd "p") 'nu-print-prompt)
  (define-key nu-term-map (kbd "q") 'nu-quit-prompt)
  (define-key nu-term-map (kbd "w") 'nu-window-prompt)


  ; some specific stuff that do not fit well
  ; elsewhere...
  (define-key nu-term-map (kbd "C-c") 'term-interrupt-subjob)
  (define-key nu-term-map (kbd "C-<SPC>") 'term-pager-toggle)

  (nu-prompt-for-keymap nu-term-map))


(defun nu-populate-tab ()
  (nu-define-prefix 'nu-tab-map)
  (define-key nu-tab-map (kbd "i") 'delete-other-windows)
  (define-key nu-tab-map (kbd "j") 'minimize-window)
  (define-key nu-tab-map (kbd "k") 'delete-window)
  (define-key nu-tab-map (kbd "l") 'split-window-right)

  (define-key nu-tab-map (kbd "g") 'ido-switch-buffer-other-window)
  (define-key nu-tab-map (kbd "t") 'ace-window)

  (define-key nu-tab-map (kbd "u") 'windmove-up)
  (define-key nu-tab-map (kbd "h") 'windmove-left)
  (define-key nu-tab-map (kbd "o") 'windmove-down)
  (define-key nu-tab-map (kbd "m") 'windmove-right))

(defun nu-tab-prompt ()
  (interactive)
  (nu-populate-tab)
  (nu-prompt-for-keymap nu-tab-map))

(defhydra hydra-nu-meta-menu (:color pink
			      :hint nil
			      :pre (setq nu-major-mode major-mode))	     
"
_q_ quit any prompt

PADDLE
----------------------------------------------------------------
_i_: open file  _j_: recent     _k_: kill buffer   _l_: switch buffer
_u_: bookmarks  _m_: maximize   _<SPC>_ : ibuffers

PROMPTS
----------------------------------------------------------------
_a_ select       _r_ replace    _o_ open     _g_ goto
_h_ help         _f_ find       _p_ print    _s_ save
_n_ new          _v_ insert     _b_ bold
_d_ delete       _Q_ quit

OTHER
--------------------------------------------------------------
_e_ execute command   or use M-x
_z_ undo tree         _t_ tab (what emacs calls window)
"
    ;; paddle direct functions.
    ("i" nu-find-files :exit t)
    ("l" nu-buffers-list :exit t)
    ("k" kill-buffer :exit t)
    ("j" nu-recentf :exit t)
    ("u" nu-bookmarks :exit t)
    ("m" delete-other-windows :exit t)
    ("<SPC>" ibuffer :exit t)

    ;; nu prompts
    ("a" (progn (nu-populate-a-map)
		(nu-full-prompt-for-keymap nu-a-map)) :exit t)
    ("r" (progn (nu-populate-replace)
		(nu-full-prompt-for-keymap nu-replace-map)) :exit t)
    ("o" (progn (nu-populate-open-map)
		(nu-full-prompt-for-keymap nu-open-map)) :exit t)
    ("g" (progn (nu-populate-goto-map)
		(nu-full-prompt-for-keymap nu-goto-map)) :exit t)
    ("h" (progn (nu-populate-help)
		(nu-full-prompt-for-keymap nu-help-map)) :exit t)
    ("f" (progn (nu-populate-find-map)
		(nu-full-prompt-for-keymap nu-find-map)) :exit t)
    ("p" (progn (nu-populate-print)
		(nu-full-prompt-for-keymap nu-print-map)) :exit t)
    ("s" (progn (nu-populate-save-map)
		(nu-full-prompt-for-keymap nu-save-map)) :exit t)
    ("d" (progn (nu-populate-delete)
		(nu-full-prompt-for-keymap nu-delete-map)) :exit t)
    ("n" (progn (nu-populate-new-map)
		(nu-full-prompt-for-keymap nu-new-map)) :exit t)
    ("t" (progn (nu-populate-tab)
		(nu-full-prompt-for-keymap nu-tab-map)) :exit t)
    ("Q" (progn (nu-populate-quit)
		(nu-full-prompt-for-keymap nu-quit-map)) :exit t)
    ("v" (progn (nu-populate-insert-map)
		(nu-full-prompt-for-keymap nu-insert-map)) :exit t)
    ("b" (progn (nu-populate-bold-map)
		(nu-full-prompt-for-keymap nu-bold-map)) :exit t)
    ;; other
    ("z" undo-tree-visualize :exit t)
    ("e" nu-M-x :exit t)
    ("y" nil :exit t)
    ("w" nil :exit t)
    ("x" nil :exit t)
    ("c" nil :exit t)
    ("q" nil :exit t))

(provide 'nu-menus)