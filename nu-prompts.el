;;
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

(defun nu-prompt-for-keymap (keym)
 (setq curb (current-buffer))
 (with-help-window (help-buffer)
   (prin1 (symbol-name keym))
   (princ "\n
Now i should lookup for available keys!!!")))



(defun nu-light-prompt-for-keymap (keym)
  ; enter minibuffer
)

(defun nu-prompt (&optional title message)
 (interactive)
 (setq curb (current-buffer))
 (unless title (setq title "Enter:"))
 (setq buf (generate-new-buffer title))
 (view-buffer-other-window buf)
 (read-only-mode t)
 (funcall (and initial-major-mode))
 (setq message
   (concat "\n~~~ ☸ ~~~\n" ; U+2638
           "\n\n\n\n"
           message))
 (insert message)
 (setq x (read-char-exclusive))
 (quit-window)
 (kill-buffer buf)
 (switch-to-buffer curb)
 (setq x x))


(defun nu-all-prompt ()
  "Use functions on _all_."
   (interactive)
   (setq c (nu-prompt "All"
     "
      a: select all"))
   (cond
   ((eq c ?a)
    (lambda (transient-mark-mode 1)(call-interactively 'mark-whole-buffer)))
   (t
    (keyboard-quit))))



(defun nu-global-prompt ()
  "Access global functions."
  (interactive)
  (setq c (nu-prompt "Global"
     " <!> if you wanted C-g to keyboard-quit, use C-q <!> 

     ==== GOTO ==========        === GLOBAL ===
     i: beginning of buffer      r: xxx xxx xxx
     g: goto line                t: transpose-frame
        (or, z-g)
     k: end of buffer
                                 n: xxx xxx xxx
     $: next buffer              v: xxx xxx xxx
     o: other window             V: xxx xxx xxx

     j: bookmark-jump            b: bookmark-set

     0: (à) : close this window. You can also directly Control-w rather than C-g 0.
     1 (&): close all other windows. You can also directly Alt-w rather than C-g 1.
     2 (é): horizontal split
     3 (\"): vertical split.
     50 ((à): close this window
     52 ((é): new window

     x: Emacs standard Control-X keymap
     q: quit emacs                               "))
  (cond
   ((eq c ?1)
    (delete-other-windows))
   ((eq c ?&)
    (delete-other-windows))
   ((eq c ?2)
     (split-window-below))
   ((eq c ?é)
     (split-window-below))
   ((eq c ?3)
     (split-window-right))
   ((eq c 34) ; "
     (split-window-right))
   ((eq c ?4)
     (set-temporary-overlay-map ctl-x-4-map))
   ((eq c ?')
    (set-temporary-overlay-map ctl-x-4-map))
   ((eq c ?5)
     (set-temporary-overlay-map ctl-x-5-map))
   ((eq c 40) ; (
     (set-temporary-overlay-map ctl-x-5-map))
   ((eq c ?i)
    (beginning-of-buffer))
   ((eq c ?k)
    (end-of-buffer))
   ((eq c ?g)
    (set-temporary-overlay-map goto-map))
   ((eq c ?$)
    (next-buffer))
   ((eq c ?o)
    (other-window 1))
   ((eq c ?r)
    (revert-buffer))
   ((eq c ?q)
    (save-buffers-kill-emacs))
   ((eq c ?b)
    (call-interactively 'bookmark-set))
   ((eq c ?j)
    (call-interactively 'bookmark-jump))
   ((eq c ?t)
    (transpose-frame))
   ((eq c ?x)
    (set-temporary-overlay-map ctl-x-map))
   ((eq c ?z)
    (set-temporary-overlay-map goto-map))
   (t
    (keyboard-quit))))


(defun nu-help-prompt ()
  "Find some documenation"
  (interactive)
  (setq c (nu-prompt "Help"
   "
   h: emacs-nu help page
   r: emacs manual

   f: describe-function         d: search in documentation
   k: describe-key              m: describe-mode
   v: describe-variable

   x: toggle help prefix keymap (ie emacs vanilla ctrl h
      You might use Alt-H too, directly,
      rather than Control-h x"))
  (cond
  ((eq c ?h)
    (nu-help))
  ((eq c ?f)
    (call-interactively 'describe-function))
  ((eq c ?d)
   (call-interactively 'apropos-documentation))
  ((eq c ?k)
    (call-interactively 'describe-key))
  ((eq c ?m)
    (describe-mode))
  ((eq c ?r)
    (info-emacs-manual))
  ((eq c ?v)
    (call-interactively 'describe-variable))
  ((eq c ?x)
    (set-temporary-overlay-map help-map))
  (t
   (keyboard-quit))))


(defun nu-find-prompt ()
  (interactive)
  (setq c (nu-prompt "Search"
   "<!> if you wanted to forward char, use M-l <!>

    f: isearch-forward                    v: visit-file
    j: isearch-backward                   r: recent files

    i: isearch-backward-regexp
    k: isearch-forward-regexp
    b: regexp-builder"))
  (cond
   ((eq c ?f)
    (if mark-active
      (progn
	(call-interactively 'isearch-forward)
	(isearch-yank-string (buffer-substring-no-properties (region-beginning) (region-end))))
      (isearch-forward)))
   ((eq c ?j)
    (isearch-backward))
   ((eq c ?k)
    (if mark-active
      (progn
	(call-interactively 'isearch-forward-regexp)
	(isearch-yank-string (buffer-substring-no-properties (region-beginning) (region-end))))p
    (isearch-forward-regexp)))
   ((eq c ?i)
    (if mark-active
      (progn
	(call-interactively 'isearch-backward-regexp)
	(isearch-yank-string (buffer-substring-no-properties (region-beginning) (region-end))))
    (isearch-backward-regexp)))
   ((eq c ?b)
    (regexp-builder))
   ((eq c ?v)
    (call-interactively 'find-file))
   ((eq c ?r)
    (call-interactively 'recentf-open-files))
   (t
    (keyboard-quit))))



(defun nu-replace-do-prompt ()
  (interactive)
  (setq c (nu-prompt "Search"
   "
    r: query-replace-regexp    j: join-line (following)
    R: query-replace           J: join-line (previous)
    I: replace-string          
    i: replace-regexp          t: transpose-lines          
                               
    k: overwrite-mode          u: UPCASE-WORD
                               d: downcase-word
    z: zap-to-char             c: Capitalize-Word

    a: revert buffer           x: rot13-region (if region)"))
  (cond
   ((eq c ?r)
    (call-interactively 'query-replace-regexp))
   ((eq c ?a)
    ('revert-buffer))
   ((eq c ?R)
    (call-interactively 'query-replace))
   ((eq c ?k)
    (call-interactively 'overwrite-mode))
   ((eq c ?I)
    (call-interactively 'replace-string))
   ((eq c ?i)
    (call-interactively 'replace-regexp))
   ((eq c ?j)
    (join-line 1))
   ((eq c ?J)
    (join-line))
   ((eq c ?t)
    (call-interactively 'transpose-lines))
   ((eq c ?z)
    (call-interactively 'zap-to-char))
   ((eq c ?u)
    (call-interactively 'upcase-word))
   ((eq c ?d)
    (call-interactively 'downcase-word))
   ((eq c ?c)
    (call-interactively 'capitalize-word))
   ((eq c ?x)
    (when mark-active
    (call-interactively 'rot13-region)))
   (t
    (keyboard-quit))))


(defun nu-replace-prompt ()
  (interactive)
  (if (or (eq overwrite-mode 'overwrite-mode-textual)
	  (eq overwrite-mode 'overwrite-mode-binary))
    (overwrite-mode -1)
    (nu-replace-do-prompt)))

(provide 'nu-prompts)
