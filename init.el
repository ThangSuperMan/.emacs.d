;; -*- lexical-binding: t; -*-
(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                         ("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(defvar bootstrap-version)
(defvar comp-deferred-compilation-deny-list ()) ; workaround, otherwise straight shits itself
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(setq straight-host-usernames
      '((github . "vugomars")
        (gitlab . "vugomars")))

(setq straight-vc-git-default-remote-name "straight")

(straight-use-package '(use-package :build t))
(setq use-package-always-ensure t)

(auth-source-pass-enable)

(customize-set-variable 'epg-pinentry-mode 'loopback)

(setq insert-directory-program "gls" dired-use-ls-dired t)
(setq dired-listing-switches "-al --group-directories-first")

  ;; Change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
  (setq user-emacs-directory (expand-file-name "~/.emacs.d/")
        url-history-file (expand-file-name "url/history" user-emacs-directory))

(add-hook 'before-save-hook #'whitespace-cleanup)

(setq-default sentence-end-double-space nil)

(global-subword-mode 1)

(setq scroll-conservatively 1000)

(setq-default initial-major-mode 'emacs-lisp-mode)

(setq-default indent-tabs-mode nil)
(add-hook 'prog-mode-hook (lambda () (setq indent-tabs-mode nil)))

(dolist (mode '(prog-mode-hook latex-mode-hook))
  (add-hook mode #'display-line-numbers-mode))

(dolist (mode '(prog-mode-hook latex-mode-hook))
  (add-hook mode #'hs-minor-mode))

;; Silence compiler warnings as they can be pretty disruptive
(setq native-comp-async-report-warnings-errors nil)

;; Set the right directory to store the native comp cache
(add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))

(setq backup-directory-alist `(("." . ,(expand-file-name ".tmp/backups/"
                                                         user-emacs-directory))))

(setq-default custom-file (expand-file-name ".custom.el" user-emacs-directory))
(when (file-exists-p custom-file) ; Don’t forget to load it, we still need it
  (load custom-file))

(setq delete-by-moving-to-trash t)

(setq-default initial-scratch-message nil)

(defalias 'yes-or-no-p 'y-or-n-p)

(global-auto-revert-mode 1)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

  ;; Keep customization settings in a temporary file (thanks Ambrevar!)
  (setq custom-file
        (if (boundp 'server-socket-dir)
            (expand-file-name "custom.el" server-socket-dir)
          (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
  (load custom-file t)

(setq user-full-name       "Dang Quang Vu"
      user-real-login-name "Dang Quang Vu"
      user-login-name      "vugomars"
      user-mail-address    "vugomars@gmail.com")

(setq visible-bell t)

(setq x-stretch-cursor t)

(with-eval-after-load 'mule-util
 (setq truncate-string-ellipsis "…"))

(add-to-list 'default-frame-alist '(alpha-background . 0.9))

(require 'time)
(setq display-time-format "%Y-%m-%d %H:%M")
(display-time-mode 1) ; display time in modeline

(let ((battery-str (battery)))
  (unless (or (equal "Battery status not available" battery-str)
              (string-match-p (regexp-quote "N/A") battery-str))
    (display-battery-mode 1)))

(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(defun modeline-contitional-buffer-encoding ()
  "Hide \"LF UTF-8\" in modeline.

It is expected of files to be encoded with LF UTF-8, so only show
the encoding in the modeline if the encoding is worth notifying
the user."
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))

(add-hook 'after-change-major-mode-hook #'modeline-contitional-buffer-encoding)

  (set-face-attribute 'default nil
                      :font "JetBrains Mono"
                      :weight 'light
                      :height 160)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil
                      :font "JetBrains Mono"
                      :weight 'light
                      :height 160)

  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil
                      ;; :font "Cantarell"
                      :font "Iosevka Aile"
                      :height 160
                      :weight 'light)

  ;;(set-fontset-font t 'symbol "Noto Color Emoji")
  ;;(set-fontset-font t 'symbol "Symbola" nil 'append)

  (use-package emojify
    :straight (:build t)
    :general
    (dqv/leader-keys
      "i e" '(emojify-insert-emoji :wk "Emoji"))
    :custom
    (emojify-emoji-set "emojione-v2.2.6")
    (emojify-emojis-dir (concat user-emacs-directory "emojify/"))
    (emojify-display-style 'image)
    :config
    (global-emojify-mode 1))

;; (defun dqv/replace-unicode-font-mapping (block-name old-font new-font)
;;   (let* ((block-idx (cl-position-if
;;                          (lambda (i) (string-equal (car i) block-name))
;;                          unicode-fonts-block-font-mapping))
;;          (block-fonts (cadr (nth block-idx unicode-fonts-block-font-mapping)))
;;          (updated-block (cl-substitute new-font old-font block-fonts :test 'string-equal)))
;;     (setf (cdr (nth block-idx unicode-fonts-block-font-mapping))
;;           `(,updated-block))))

;; (use-package unicode-fonts
;;   :custom
;;   (unicode-fonts-skip-font-groups '(low-quality-glyphs))
;;   :config
;;   ;; Fix the font mappings to use the right emoji font
;;   (mapcar
;;     (lambda (block-name)
;;       (dqv/replace-unicode-font-mapping block-name "Apple Color Emoji" "Noto Color Emoji"))
;;     '("Dingbats"
;;       "Emoticons"
;;       "Miscellaneous Symbols and Pictographs"
;;       "Transport and Map Symbols"))
;;   (unicode-fonts-setup))

(setq frame-title-format
      '(""
        "%b"
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p) " ◉ %s" "  ●  %s - Emacs") project-name))))))

;; Use moody for the mode bar
(use-package moody
  :straight (:build t)
  :config
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package minions
  :straight (:build t)
  :config
  (setq minions-mode-line-lighter ""
        minions-mode-line-delimiters '("" . ""))
  (minions-mode 1))

(setq evil-insert-state-cursor '((bar . 2) "orange")
      evil-normal-state-cursor '(box "orange"))

(defmacro csetq (&rest forms)
  "Bind each custom variable FORM to the value of its VAL.

FORMS is a list of pairs of values [FORM VAL].
`customize-set-variable' is called sequentially on each pairs
contained in FORMS. This means `csetq' has a similar behaviour as
`setq': each VAL expression are evaluated sequentially, i.e. the
first VAL is evaluated before the second, and so on. This means
the value of the first FORM can be used to set the second FORM.

The return value of `csetq' is the value of the last VAL.

\(fn [FORM VAL]...)"
  (declare (debug (&rest sexp form))
           (indent 1))
  ;; Check if we have an even number of arguments
  (when (= (mod (length forms) 2) 1)
    (signal 'wrong-number-of-arguments (list 'csetq (1+ (length forms)))))
  ;; Transform FORMS into a list of pairs (FORM . VALUE)
  (let (sexps)
    (while forms
      (let ((form  (pop forms))
            (value (pop forms)))
        (push `(customize-set-variable ',form ,value)
              sexps)))
    `(progn ,@(nreverse sexps))))

;; Add my library path to load-path
(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/.emacs.d/lisp/maple-iedit")

(defun dqv/open-marked-files (&optional files)
  "Open all marked FILES in Dired buffer as new Emacs buffers."
  (interactive)
  (let* ((file-list (if files
                        (list files)
                      (if (equal major-mode "dired-mode")
                          (dired-get-marked-files)
                        (list (buffer-file-name))))))
   (mapc (lambda (file-path)
           (find-file file-path))
         (file-list))))

(defun switch-to-messages-buffer ()
  "Switch to Messages buffer."
  (interactive)
  (switch-to-buffer (messages-buffer)))

(defun switch-to-scratch-buffer ()
  "Switch to Messages buffer."
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun self-screenshot (&optional type)
  "Save a screenshot of type TYPE of the current Emacs frame.
As shown by the function `', type can weild the value `svg',
`png', `pdf'.

This function will output in /tmp a file beginning with \"Emacs\"
and ending with the extension of the requested TYPE."
  (interactive)
  (let* ((type (if type type
                 (intern (completing-read "Screenshot Type: "
                                          '(png svg pdf postscript)))))
         (extension (pcase type
                      ('png        ".png")
                      ('svg        ".svg")
                      ('pdf        ".pdf")
                      ('postscript ".ps")
                      (otherwise (error "Cannot export screenshot of type %s" otherwise))))
         (filename (make-temp-file "Emacs-" nil extension))
         (data     (x-export-frames nil type)))
    (with-temp-file filename
      (insert data))
    (kill-new filename)
    (message filename)))

(defun split-window-right-and-focus ()
  "Spawn a new window right of the current one and focus it."
  (interactive)
  (split-window-right)
  (windmove-right))

(defun split-window-below-and-focus ()
  "Spawn a new window below the current one and focus it."
  (interactive)
  (split-window-below)
  (windmove-down))

(defun kill-buffer-and-delete-window ()
  "Kill the current buffer and delete its window."
  (interactive)
  (progn
    (kill-this-buffer)
    (delete-window)))

(defun add-all-to-list (list-var elements &optional append compare-fn)
  "Add ELEMENTS to the value of LIST-VAR if it isn’t there yet.

ELEMENTS is a list of values. For documentation on the variables
APPEND and COMPARE-FN, see `add-to-list'."
  (let (return)
    (dolist (elt elements return)
      (setq return (add-to-list list-var elt append compare-fn)))))

(defun scroll-half-page-up ()
  "scroll down half the page"
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-down ()
  "scroll up half the page"
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

  (defun dqv/switch-to-previous-buffer ()
    "Switch to previously open buffer.
        Repeated invocations toggle between the two most recently open buffers."
    (interactive)
    (switch-to-buffer (other-buffer (current-buffer) 1)))

 (defun my-smarter-move-beginning-of-line (arg)
   "Move point back to indentation of beginning of line.

        Move point to the first non-whitespace character on this line.
        If point is already there, move to the beginning of the line.
        Effectively toggle between the first non-whitespace character and
        the beginning of the line.

        If ARG is not nil or 1, move forward ARG - 1 lines first.  If
        point reaches the beginning or end of the buffer, stop there."
   (interactive "^p")
   (setq arg (or arg 1))

   ;; Move lines first
   (when (/= arg 1)
     (let ((line-move-visual nil))
        (forward-line (1- arg))))

   (let ((orig-point (point)))
     (back-to-indentation)
     (when (= orig-point (point))
        (move-beginning-of-line 1))))

 ;; remap C-a to `smarter-move-beginning-of-line'

 (global-set-key (kbd "C-a") #'my-smarter-move-beginning-of-line)

(defun dqv/goto-match-paren (arg)
  "Go to the matching if on (){}[], similar to vi style of % ."
  (interactive "p")
  (cond ((looking-at "[\[\(\{]") (evil-jump-item))
        ((looking-back "[\]\)\}]" 1) (evil-jump-item))
        ((looking-at "[\]\)\}]") (forward-char) (evil-jump-item))
        ((looking-back "[\[\(\{]" 1) (backward-char) (evil-jump-item))
        (t nil)))
  (global-set-key (kbd "s-;") #'dqv/goto-match-paren)

(defun dqv/delete-this-file (&optional trash)
  "Delete this file.

When called interactively, TRASH is t if no prefix argument is given.
With a prefix argument, TRASH is nil."
  (interactive)
  (when (and (called-interactively-p 'interactive)
             (not current-prefix-arg))
    (setq trash t))
  (if-let ((file (buffer-file-name)))
      (when (y-or-n-p "Delete this file? ")
        (delete-file file trash)
        (kill-buffer (current-buffer)))
    (user-error "Current buffer is not visiting a file")))

    (defun dqv/kill-other-buffers ()
      "Kill all other buffers."
      (interactive)
      (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(use-package which-key
  :straight (:build t)
  :defer t
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package general
  :straight (:build t)
  :init
  (general-auto-unbind-keys)
  :config
  (general-create-definer dqv/underfine
    :keymaps 'override
    :states '(normal emacs))
  (general-create-definer dqv/evil
    :states '(normal))
  (general-create-definer dqv/leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")
  (general-create-definer dqv/major-leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix ","
    :global-prefix "M-m"))

(use-package evil
  :straight (:build t)
  :after (general)
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  (require 'evil-vars)
  (evil-set-undo-system 'undo-tree)
  :config
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-global-set-key 'motion "w" 'evil-avy-goto-word-1)
  
  (general-define-key
   :keymaps 'evil-motion-state-map
   "SPC" nil
   ","   nil)
  (general-define-key
   :keymaps 'evil-insert-state-map
   "C-t" nil)
  (general-define-key
   :keymaps 'evil-insert-state-map
   "U"   nil
   "C-a" nil
   "C-y" nil
   "C-e" nil)
  ;; (dolist (key '("c" "C" "t" "T" "s" "S" "r" "R" "h" "H" "j" "J" "k" "K" "l" "L"))
  ;;   (general-define-key :states 'normal key nil))
  
  ;; (general-define-key
  ;;  :states 'motion
  ;;  "h" 'evil-replace
  ;;  "H" 'evil-replace-state
  ;;  "j" 'evil-find-char-to
  ;;  "J" 'evil-find-char-to-backward
  ;;  "k" 'evil-substitute
  ;;  "K" 'evil-smart-doc-lookup
  ;;  "l" 'evil-change
  ;;  "L" 'evil-change-line
  
  ;;  "c" 'evil-backward-char
  ;;  "C" 'evil-window-top
  ;;  "t" 'evil-next-visual-line
  ;;  "T" 'evil-join
  ;;  "s" 'evil-previous-visual-line
  ;;  "S" 'evil-lookup
  ;;  "r" 'evil-forward-char
  ;;  "R" 'evil-window-bottom)
  (evil-mode 1)
  (setq evil-want-fine-undo t) ; more granular undo with evil
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-surround
  :straight (:build t)
  :config
  (global-evil-surround-mode t))

(use-package evil-exchange
  :straight (:build t)
  :config (evil-exchange-install))

(use-package evil-goggles
  :straight (:build t)
  :after evil
  :config (evil-goggles-mode))

  (use-package evil-collection
    :after evil
    :straight (:build t)
    :config
    ;; bépo conversion
    ;; (defun my/bépo-rotate-evil-collection (_mode mode-keymaps &rest _rest)
    ;;   (evil-collection-translate-key 'normal mode-keymaps
    ;;     ;; bépo ctsr is qwerty hjkl
    ;;     "c" "h"
    ;;     "t" "j"
    ;;     "s" "k"
    ;;     "r" "l"
    ;;     ;; add back ctsr
    ;;     "h" "c"
    ;;     "j" "t"
    ;;     "k" "s"
    ;;     "l" "r"))
    ;; (add-hook 'evil-collection-setup-hook #'my/bépo-rotate-evil-collection)
    (evil-collection-init))

(use-package undo-tree
  :defer t
  :straight (:build t)
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(expand-file-name (file-name-as-directory "undo-tree-hist")
                               user-emacs-directory))))
  :init
  (global-undo-tree-mode)
  :config
  
  (when (executable-find "zstd")
    (defun my/undo-tree-append-zst-to-filename (filename)
      "Append .zst to the FILENAME in order to compress it."
      (concat filename ".zst"))
    (advice-add 'undo-tree-make-history-save-file-name
                :filter-return
                #'my/undo-tree-append-zst-to-filename))
  (setq undo-tree-visualizer-diff       t
        undo-tree-auto-save-history     t
        undo-tree-enable-undo-in-region t
        undo-limit        (* 800 1024)
        undo-strong-limit (* 12 1024 1024)
        undo-outer-limit  (* 128 1024 1024)))

(use-package hydra
  :straight (:build t)
  :defer t)

(defhydra hydra-zoom ()
  "
^Zoom^                 ^Other
^^^^^^^--------------------------
[_j_/_k_] zoom in/out  [_q_] quit
[_0_]^^   reset zoom
"
  ("j" text-scale-increase "zoom in")
  ("k" text-scale-decrease "zoom out")
  ("0" text-scale-adjust "reset")
  ("q" nil "finished" :exit t))

(defhydra windows-adjust-size ()
  "
^Zoom^                                ^Other
^^^^^^^-----------------------------------------
[_j_/_k_] shrink/enlarge vertically   [_q_] quit
[_h_/_l_] shrink/enlarge horizontally
"
  ("q" nil :exit t)
  ("h" shrink-window-horizontally)
  ("j" enlarge-window)
  ("k" shrink-window)
  ("l" enlarge-window-horizontally))

(defun my/transparency-round (val)
  "Round VAL to the nearest tenth of an integer."
  (/ (round (* 10 val)) 10.0))

(defun my/increase-frame-alpha-background ()
  "Increase current frame’s alpha background."
  (interactive)
  (set-frame-parameter nil
                       'alpha-background
                       (my/transparency-round
                        (min 1.0
                             (+ (frame-parameter nil 'alpha-background) 0.1))))
  (message "%s" (frame-parameter nil 'alpha-background)))

(defun my/decrease-frame-alpha-background ()
  "Decrease current frame’s alpha background."
  (interactive)
  (set-frame-parameter nil
                       'alpha-background
                       (my/transparency-round
                        (max 0.0
                             (- (frame-parameter nil 'alpha-background) 0.1))))
  (message "%s" (frame-parameter nil 'alpha-background)))

(defhydra my/modify-frame-alpha-background ()
  "
^Transparency^              ^Other^
^^^^^^^^^^^^^^------------------------
[_j_] decrease transparency [_q_] quit
[_k_] increase transparency
"
  ("q" nil :exit t)
  ("j" my/decrease-frame-alpha-background)
  ("k" my/increase-frame-alpha-background))

(use-package citeproc
  :after (org)
  :defer t
  :straight (:build t))

  (use-package org
    :straight t
    :defer t
    :commands (orgtbl-mode)
    :hook ((org-mode . visual-line-mode)
           (org-mode . org-num-mode))
    :custom-face
    (org-macro ((t (:foreground "#b48ead"))))
    :init
    (auto-fill-mode -1)
    :config
    (defhydra org-babel-transient ()
      "
    ^Navigate^                    ^Interact
    ^^^^^^^^^^^------------------------------------------
    [_j_/_k_] navigate src blocs  [_x_] execute src block
    [_g_]^^   goto named block    [_'_] edit src block
    [_z_]^^   recenter screen     [_q_] quit
    "
      ("q" nil :exit t)
      ("j" org-babel-next-src-block)
      ("k" org-babel-previous-src-block)
      ("g" org-babel-goto-named-src-block)
      ("z" recenter-top-bottom)
      ("x" org-babel-execute-maybe)
      ("'" org-edit-special :exit t))
    (require 'ox-beamer)
    (require 'org-protocol)
    (setq org-hide-leading-stars             nil
          org-hide-macro-markers             t
          org-ellipsis                       " ⤵"
          org-image-actual-width             600
          org-redisplay-inline-images        t
          org-display-inline-images          t
          org-startup-with-inline-images     "inlineimages"
          org-pretty-entities                t
          org-fontify-whole-heading-line     t
          org-fontify-done-headline          t
          org-fontify-quote-and-verse-blocks t
          org-startup-indented               t
          org-startup-align-all-tables       t
          org-use-property-inheritance       t
          org-list-allow-alphabetical        t
          org-M-RET-may-split-line           nil
          org-src-window-setup               'split-window-below
          org-src-fontify-natively           t
          org-src-tab-acts-natively          t
          org-src-preserve-indentation       t
          org-log-done                       'time
          org-directory                      "~/Dropbox/Org"
          org-default-notes-file             (expand-file-name "notes.org" org-directory))
    (with-eval-after-load 'oc
     (setq org-cite-global-bibliography '("~/Dropbox/Org/bibliography/references.bib")))
    (setq org-agenda-files (list "~/Dropbox/Org/" "~/Dropbox/Roam/" "~/Dropbox/Roam/daily/"))
    (add-hook 'org-mode-hook (lambda ()
                               (interactive)
                               (electric-indent-local-mode -1)))
    (defvar org-training-file "~/Dropbox/Org/Training.org")
    (defvar org-journal-file "~/Dropbox/Org/Journal.org")
    (defvar org-study-file "~/Dropbox/Org/Study.org")
    (defvar org-social-file "~/Dropbox/Org/Social.org")
    (defvar org-work-file "~/Dropbox/Org/Work.org")
    (defvar org-personal-file "~/Dropbox/Org/Personal.org")
    (setq org-capture-templates
          '(
            ("j" "Journal" entry
              (file+headline org-journal-file "Journal")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("t" "Training" entry
              (file+headline org-training-file "Training")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("s" "Study" entry
              (file+headline org-study-file "Study")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("S" "Social")
            ("Sy" "Youtube" entry
              (file+headline org-social-file "Youtube")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("St" "Tiktok" entry
              (file+headline org-social-file "Tiktok")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("ST" "Tweeter" entry
              (file+headline org-social-file "Tweeter")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("Sl" "Linkedin" entry
              (file+headline org-social-file "Linkedin")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("Sb" "Blog" entry
              (file+headline org-social-file "Posts")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("w" "Work" entry
              (file+headline org-work-file "Work")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))
            ("p" "Personal" entry
              (file+headline org-personal-file "Personal")
              (file "~/.emacs.d/capture/schedule.orgcaptmpl"))))
    (defun org-emphasize-bold ()
      "Emphasize as bold the current region."
      (interactive)
      (org-emphasize 42))
    (defun org-emphasize-italic ()
      "Emphasize as italic the current region."
      (interactive)
      (org-emphasize 47))
    (defun org-emphasize-underline ()
      "Emphasize as underline the current region."
      (interactive)
      (org-emphasize 95))
    (defun org-emphasize-verbatim ()
      "Emphasize as verbatim the current region."
      (interactive)
      (org-emphasize 61))
    (defun org-emphasize-code ()
      "Emphasize as code the current region."
      (interactive)
      (org-emphasize 126))
    (defun org-emphasize-strike-through ()
      "Emphasize as strike-through the current region."
      (interactive)
      (org-emphasize 43))
    
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((C . t)
       (emacs-lisp . t)
       (gnuplot . t)
       (latex . t)
       (makefile . t)
       (plantuml . t)
       (python . t)
       (sass . t)
       (shell . t)
       (sql . t))
     )
    (setq org-use-sub-superscripts (quote {}))
    (setq org-latex-compiler "xelatex")
    (require 'engrave-faces)
    (csetq org-latex-src-block-backend 'engraved)
    (dolist (package '(("AUTO" "inputenc" t ("pdflatex"))
                       ("T1"   "fontenc"  t ("pdflatex"))
                       (""     "grffile"  t)))
      (delete package org-latex-default-packages-alist))
    
    (dolist (package '(("capitalize" "cleveref")
                       (""           "booktabs")
                       (""           "tabularx")))
      (add-to-list 'org-latex-default-packages-alist package t))
    
    (setq org-latex-reference-command "\\cref{%s}")
    (setq org-export-latex-hyperref-format "\\ref{%s}")
    (setq org-latex-pdf-process
          '("tectonic -Z shell-escape --synctex --outdir=%o %f"))
    (dolist (ext '("bbl" "lot"))
      (add-to-list 'org-latex-logfiles-extensions ext t))
    (use-package org-re-reveal
      :defer t
      :after org
      :straight (:build t)
      :init
      (add-hook 'org-mode-hook (lambda () (require 'org-re-reveal)))
      :config
      (setq org-re-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"
            org-re-reveal-revealjs-version "4"))
    (setq org-html-validation-link nil)
    (eval-after-load "ox-latex"
      '(progn
         (add-to-list 'org-latex-classes
                      '("conlang"
                        "\\documentclass{book}"
                        ("\\chapter{%s}" . "\\chapter*{%s}")
                        ("\\section{%s}" . "\\section*{%s}")
                        ("\\subsection{%s}" . "\\subsection*{%s}")
                        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
         (add-to-list 'org-latex-classes
                      `("beamer"
                        ,(concat "\\documentclass[presentation]{beamer}\n"
                                 "[DEFAULT-PACKAGES]"
                                 "[PACKAGES]"
                                 "[EXTRA]\n")
                        ("\\section{%s}" . "\\section*{%s}")
                        ("\\subsection{%s}" . "\\subsection*{%s}")
                        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))))
    
    
    (setq org-publish-project-alist
          `(
            
            
            
            
            
            
            ))
    (add-hook 'org-mode-hook
              (lambda ()
                (dolist (pair '(("[ ]"         . ?☐)
                                ("[X]"         . ?☑)
                                ("[-]"         . ?❍)
                                ("#+title:"    . ?📕)
                                ("#+TITLE:"    . ?📕)
                                ("#+author:"   . ?✎)
                                ("#+AUTHOR:"   . ?✎)
                                ("#+email:"    . ?📧)
                                ("#+EMAIL:"    . ?📧)
                                ("#+include"   . ?⭳)
                                ("#+INCLUDE"   . ?⭳)
                                ("#+begin_src" . ?λ)
                                ("#+BEGIN_SRC" . ?λ)
                                ("#+end_src"   . ?λ)
                                ("#+END_SRC"   . ?λ)))
                  (add-to-list 'prettify-symbols-alist pair))
                (prettify-symbols-mode)))
    :general
    (dqv/evil
      :keymaps 'org-mode-map
      :packages 'org
      "RET" 'org-open-at-point)
    (dqv/major-leader-key
      :keymaps 'org-mode-map
      :packages 'org
      "RET" #'org-ctrl-c-ret
      "*" #'org-ctrl-c-star
      "," #'org-ctrl-c-ctrl-c
      "'" #'org-edit-special
      "-" #'org-ctrl-c-minus
      "a" #'org-agenda
      "c" #'org-capture
      "C" #'org-columns
      "e" #'org-export-dispatch
      "l" #'org-store-link
      "p" #'org-priority
      "r" #'org-reload
      "b" '(:ignore t :wk "babel")
      "b." #'org-babel-transient/body
      "bb" #'org-babel-execute-buffer
      "bc" #'org-babel-check-src-block
      "bC" #'org-babel-tangle-clean
      "be" #'org-babel-execute-maybe
      "bf" #'org-babel-tangle-file
      "bn" #'org-babel-next-src-block
      "bo" #'org-babel-open-src-block-result
      "bp" #'org-babel-previous-src-block
      "br" #'org-babel-remove-result-one-or-many
      "bR" #'org-babel-goto-named-result
      "bt" #'org-babel-tangle
      "bi" #'org-babel-view-src-block-info
      "d" '(:ignore t :wk "dates")
      "dd" #'org-deadline
      "ds" #'org-schedule
      "dt" #'org-time-stamp
      "dT" #'org-time-stamp-inactive
      "i" '(:ignore t :wk "insert")
      "ib" #'org-insert-structure-template
      "id" #'org-insert-drawer
      "ie" '(:ignore t :wk "emphasis")
      "ieb" #'org-emphasize-bold
      "iec" #'org-emphasize-code
      "iei" #'org-emphasize-italic
      "ies" #'org-emphasize-strike-through
      "ieu" #'org-emphasize-underline
      "iev" #'org-emphasize-verbatim
      "iE" #'org-set-effort
      "if" #'org-footnote-new
      "ih" #'org-insert-heading
      "iH" #'counsel-org-link
      "ii" #'org-insert-item
      "il" #'org-insert-link
      "in" #'org-add-note
      "ip" #'org-set-property
      "is" #'org-insert-subheading
      "it" #'org-set-tags-command
      "t" '(:ignore t :wk "tables")
      "th" #'org-table-move-column-left
      "tj" #'org-table-move-row-down
      "tk" #'org-table-move-row-up
      "tl" #'org-table-move-column-right
      "ta" #'org-table-align
      "te" #'org-table-eval-formula
      "tf" #'org-table-field-info
      "tF" #'org-table-edit-formulas
      "th" #'org-table-convert
      "tl" #'org-table-recalculate
      "tp" #'org-plot/gnuplot
      "tS" #'org-table-sort-lines
      "tw" #'org-table-wrap-region
      "tx" #'org-table-shrink
      "tN" #'org-table-create-with-table.el
      "td" '(:ignore t :wk "delete")
      "tdc" #'org-table-delete-column
      "tdr" #'org-table-kill-row
      "ti" '(:ignore t :wk "insert")
      "tic" #'org-table-insert-column
      "tih" #'org-table-insert-hline
      "tir" #'org-table-insert-row
      "tiH" #'org-table-hline-and-move
      "tt" '(:ignore t :wk "toggle")
      "ttf" #'org-table-toggle-formula-debugger
      "tto" #'org-table-toggle-coordinate-overlays
      "T" '(:ignore t :wk "toggle")
      "Tc" #'org-toggle-checkbox
      "Ti" #'org-toggle-inline-images
      "Tl" #'org-latex-preview
      "Tn" #'org-num-mode
      "Ts" #'dqv/toggle-org-src-window-split
      "Tt" #'org-show-todo-tree
      "<SPC>" #'org-todo)
    (dqv/leader-key
      :packages 'org
      :infix "o"
      ""  '(:ignore t :which-key "org")
      "c" #'org-capture)
    (dqv/major-leader-key
      :packages 'org
      :keymaps 'org-src-mode-map
      "'" #'org-edit-src-exit
      "k" #'org-edit-src-abort))

  (use-package evil-org
    :straight (:build t)
    :after (org)
    :hook (org-mode . evil-org-mode)
    :config
    (setq-default evil-org-movement-bindings
                  '((up    . "k")
                    (down  . "j")
                    (left  . "h")
                    (right . "l")))
    (evil-org-set-key-theme '(textobjects navigation calendar additional shift operators))
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys))

(use-package org-contrib
  :after (org)
  :defer t
  :straight (:build t)
  :init
  (require 'ox-extra)
  (ox-extras-activate '(latex-header-blocks ignore-headlines)))

(use-package ob-async
  :straight (:build t)
  :defer t
  :after (org ob))

(use-package ob-latex-as-png
  :after org
  :straight (:build t))

(use-package ob-restclient
  :straight (:build t)
  :defer t
  :after (org ob)
  :init
  (add-to-list 'org-babel-load-languages '(restclient . t)))

(use-package toc-org
  :after (org markdown-mode)
  :straight (:build t)
  :init
  (add-to-list 'org-tag-alist '("TOC" . ?T))
  :hook (org-mode . toc-org-enable)
  :hook (markdown-mode . toc-org-enable))

(defun dqv/toggle-org-src-window-split ()
  "This function allows the user to toggle the behavior of
`org-edit-src-code'. If the variable `org-src-window-setup' has
the value `split-window-right', then it will be changed to
`split-window-below'. Otherwise, it will be set back to
`split-window-right'"
  (interactive)
  (if (equal org-src-window-setup 'split-window-right)
      (setq org-src-window-setup 'split-window-below)
    (setq org-src-window-setup 'split-window-right))
  (message "Org-src buffers will now split %s"
           (if (equal org-src-window-setup 'split-window-right)
               "vertically"
             "horizontally")))

(use-package org-conlang
  :defer t
  :after '(org ol ox)
  :straight (org-conlang :type git
                         :host nil
                         :repo "https://labs.phundrak.com/phundrak/org-conlang"
                         :build t))

(use-package ox-epub
  :after (org ox)
  :straight (:build t))

(use-package ox-gemini
  :defer t
  :straight (:build t)
  :after (ox org))

;; (use-package htmlize
;;   :defer t
;;   :straight (:build t))

(use-package preview-org-html-mode
  :defer t
  :after (org)
  :straight (preview-org-html-mode :build t
                                   :type git
                                   :host github
                                   :repo "jakebox/preview-org-html-mode")
  :general
  (dqv/major-leader-key
   :keymaps 'org-mode-map
   :packages 'preview-org-html-mode
   :infix "P"
   ""  '(:ignore t :which-key "preview")
   "h" #'preview-org-html-mode
   "r" #'preview-org-html-refresh
   "p" #'preview-org-html-pop-window-to-frame)
  :config
  (setq preview-org-html-refresh-configuration 'save))

(use-package engrave-faces
  :defer t
  :straight (:build t)
  :after org)

(use-package org-re-reveal
  :defer t
  :after org
  :straight (:build t)
  :init
  (add-hook 'org-mode-hook (lambda () (require 'org-re-reveal)))
  :config
  (setq org-re-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"
        org-re-reveal-revealjs-version "4"))

(use-package ox-ssh
  :after (ox org)
  :straight (:build t))

(setq org-publish-project-alist
      `(
        
        
        
        
        
        
        ))

(use-package reftex
  :commands turn-on-reftex
  :init (setq reftex-default-bibliography "~/Dropbox/Org/bibliography/references.bib"
              reftex-plug-into-AUCTeX     t))

(use-package org-ref
  ;; :after (org ox-bibtex pdf-tools)
  :after org
  :defer t
  :straight (:build t)
  :custom-face
  (org-ref-cite-face ((t (:weight bold))))
  :init
  (setq org-ref-completion-library    'org-ref-ivy-cite
        org-latex-logfiles-extensions '("lof" "lot" "aux" "idx" "out" "log" "fbd_latexmk"
                                        "toc" "nav" "snm" "vrb" "dvi" "blg" "brf" "bflsb"
                                        "entoc" "ps" "spl" "bbl" "pygtex" "pygstyle"))
  (add-hook 'org-mode-hook (lambda () (require 'org-ref)))
  :config
  (setq bibtex-completion-pdf-field    "file"
        bibtex-completion-notes-path   "~/Dropbox/Org/bibliography/notes/"
        bibtex-completion-bibliography "~/Dropbox/Org/bibliography/references.bib"
        bibtex-completion-library-path "~/Dropbox/Org/bibliography/bibtex-pdfs/"
        bibtex-completion-pdf-symbol   "⌘"
        bibtex-completion-notes-symbol "✎")
  :general
  (dqv/evil
   :keymaps 'bibtex-mode-map
   :packages 'org-ref
   "C-j" #'org-ref-bibtex-next-entry
   "C-k" #'org-ref-bibtex-previous-entry
   "gj"  #'org-ref-bibtex-next-entry
   "gk"  #'org-ref-bibtex-previous-entry)
  (dqv/major-leader-key
   :keymaps '(bibtex-mode-map)
   :packages 'org-ref
   ;; Navigation
   "j" #'org-ref-bibtex-next-entry
   "k" #'org-ref-bibtex-previous-entry

   ;; Open
   "b" #'org-ref-open-in-browser
   "n" #'org-ref-open-bibtex-notes
   "p" #'org-ref-open-bibtex-pdf

   ;; Misc
   "h" #'org-ref-bibtex-hydra/body
   "i" #'org-ref-bibtex-hydra/org-ref-bibtex-new-entry/body-and-exit
   "s" #'org-ref-sort-bibtex-entry

   "l" '(:ignore t :which-key "lookup")
   "la" #'arxiv-add-bibtex-entry
   "lA" #'arxiv-get-pdf-add-bibtex-entry
   "ld" #'doi-utils-add-bibtex-entry-from-doi
   "li" #'isbn-to-bibtex
   "lp" #'pubmed-insert-bibtex-from-pmid)
  (dqv/major-leader-key
   :keymaps 'org-mode-map
   :pakages 'org-ref
   "ic" #'org-ref-insert-link))

(use-package ivy-bibtex
  :defer t
  :straight (:build t)
  :config
  (setq bibtex-completion-pdf-open-function #'find-file)
  :general
  (dqv/leader-key
    :keymaps '(bibtex-mode-map)
    :packages 'ivy-bibtex
    "m" #'ivy-bibtex))

(defun my/org-present-prepare-slide ()
  (org-overview)
  (org-show-entry)
  (org-show-children)
  (org-present-hide-cursor))

(defun my/org-present-init ()
  (setq header-line-format " ")
  (org-display-inline-images)
  (my/org-present-prepare-slide))

(defun my/org-present-quit ()
  (setq header-line-format nil)
  (org-present-small)
  (org-present-show-cursor))

(defun my/org-present-prev ()
  (interactive)
  (org-present-prev)
  (my/org-present-prepare-slide))

(defun my/org-present-next ()
  (interactive)
  (org-present-next)
  (my/org-present-prepare-slide))

(use-package org-present
  :after org
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :packages 'org-present
    :keymaps 'org-mode-map
    "P" #'org-present)
  (dqv/evil
    :states 'normal
    :packages 'org-present
    :keymaps 'org-present-mode-keymap
    "+" #'org-present-big
    "-" #'org-present-small
    "<" #'org-present-beginning
    ">" #'org-present-end
    "«" #'org-present-beginning
    "»" #'org-present-end
    "c" #'org-present-hide-cursor
    "C" #'org-present-show-cursor
    "n" #'org-present-next
    "p" #'org-present-prev
    "r" #'org-present-read-only
    "w" #'org-present-read-write
    "q" #'org-present-quit)
  :hook ((org-present-mode      . my/org-present-init)
         (org-present-mode-quit . my/org-present-quit)))

(setq org-todo-keywords
      '((sequence "IDEA(i)" "TODO(t)" "NEXT(n)" "PROJ(p)" "STRT(s)" "WAIT(w)" "HOLD(h)" "|" "DONE(d)" "KILL(k)")
        (sequence "[ ](T)" "[-](S)" "|" "[X](D)")
        (sequence "|" "OKAY(o)" "YES(y)" "NO(n)")))

(setq org-todo-keyword-faces
      '(("IDEA" . (:foreground "goldenrod" :weight bold))
        ("NEXT" . (:foreground "IndianRed1" :weight bold))
        ("STRT" . (:foreground "OrangeRed" :weight bold))
        ("WAIT" . (:foreground "coral" :weight bold))
        ("KILL" . (:foreground "DarkGreen" :weight bold))
        ("PROJ" . (:foreground "LimeGreen" :weight bold))
        ("HOLD" . (:foreground "orange" :weight bold))))

(defun +log-todo-next-creation-date (&rest ignore)
  "Log NEXT creation time in the property drawer under the key 'ACTIVATED'"
  (when (and (string= (org-get-todo-state) "NEXT")
             (not (org-entry-get nil "ACTIVATED")))
    (org-entry-put nil "ACTIVATED" (format-time-string "[%Y-%m-%d]"))))

(add-hook 'org-after-todo-state-change-hook #'+log-todo-next-creation-date)

(setq org-tag-persistent-alist
      '((:startgroup . nil)
        ("home"      . ?h)
        ("research"  . ?r)
        ("work"      . ?w)
        (:endgroup   . nil)
        (:startgroup . nil)
        ("tool"      . ?o)
        ("dev"       . ?d)
        ("report"    . ?p)
        (:endgroup   . nil)
        (:startgroup . nil)
        ("easy"      . ?e)
        ("medium"    . ?m)
        ("hard"      . ?a)
        (:endgroup   . nil)
        ("urgent"    . ?u)
        ("key"       . ?k)
        ("bonus"     . ?b)
        ("ignore"    . ?i)
        ("noexport"  . ?x)))

(setq org-tag-faces
      '(("home"     . (:foreground "goldenrod"  :weight bold))
        ("research" . (:foreground "goldenrod"  :weight bold))
        ("work"     . (:foreground "goldenrod"  :weight bold))
        ("tool"     . (:foreground "IndianRed1" :weight bold))
        ("dev"      . (:foreground "IndianRed1" :weight bold))
        ("report"   . (:foreground "IndianRed1" :weight bold))
        ("urgent"   . (:foreground "red"        :weight bold))
        ("key"      . (:foreground "red"        :weight bold))
        ("easy"     . (:foreground "green4"     :weight bold))
        ("medium"   . (:foreground "orange"     :weight bold))
        ("hard"     . (:foreground "red"        :weight bold))
        ("bonus"    . (:foreground "goldenrod"  :weight bold))
        ("ignore"   . (:foreground "Gray"       :weight bold))
        ("noexport" . (:foreground "LimeGreen"  :weight bold))))

(use-package mixed-pitch
  :after org
  :straight (:build t)
  :hook
  (org-mode           . mixed-pitch-mode)
  (emms-browser-mode  . mixed-pitch-mode)
  (emms-playlist-mode . mixed-pitch-mode)
  :config
  (add-hook 'org-agenda-mode-hook (lambda () (mixed-pitch-mode -1))))

(use-package org-appear
  :after org
  :straight (:build t)
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis   t
        org-hide-emphasis-markers t
        org-appear-autolinks      t
        org-appear-autoentities   t
        org-appear-autosubmarkers t)
  (run-at-time nil nil #'org-appear--set-elements))

(use-package org-fragtog
  :defer t
  :after org
  :straight (:build t)
  :hook (org-mode . org-fragtog-mode))

(use-package org-modern
  :straight (:build t)
  :after org
  :defer t
  :hook (org-mode . org-modern-mode)
  :hook (org-agenda-finalize . org-modern-agenda))

(use-package org-fancy-priorities
  :after (org all-the-icons)
  :straight (:build t)
  :hook (org-mode        . org-fancy-priorities-mode)
  :hook (org-agenda-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list `(,(all-the-icons-faicon "flag"     :height 1.1 :v-adjust 0.0)
                                    ,(all-the-icons-faicon "arrow-up" :height 1.1 :v-adjust 0.0)
                                    ,(all-the-icons-faicon "square"   :height 1.1 :v-adjust 0.0))))

(use-package org-ol-tree
  :after (org avy)
  :defer t
  :straight (org-ol-tree :build t
                         :host github
                         :type git
                         :repo "Townk/org-ol-tree")
  :general
  (dqv/major-leader-key
    :packages 'org-ol-tree
    :keymaps 'org-mode-map
    "O" #'org-ol-tree))

(add-hook 'org-mode-hook
          (lambda ()
            (dolist (pair '(("[ ]"         . ?☐)
                            ("[X]"         . ?☑)
                            ("[-]"         . ?❍)
                            ("#+title:"    . ?📕)
                            ("#+TITLE:"    . ?📕)
                            ("#+author:"   . ?✎)
                            ("#+AUTHOR:"   . ?✎)
                            ("#+email:"    . ?📧)
                            ("#+EMAIL:"    . ?📧)
                            ("#+include"   . ?⭳)
                            ("#+INCLUDE"   . ?⭳)
                            ("#+begin_src" . ?λ)
                            ("#+BEGIN_SRC" . ?λ)
                            ("#+end_src"   . ?λ)
                            ("#+END_SRC"   . ?λ)))
              (add-to-list 'prettify-symbols-alist pair))
            (prettify-symbols-mode)))

(defun dqv/org-mode-visual-fill ()
  (setq visual-fill-column-width 160
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . dqv/org-mode-visual-fill))

(use-package org-tree-slide
  :defer t
  :after org
  :straight (:build t)
  :config
  (setq org-tree-slide-skip-done nil)
  :general
  (dqv/evil
    :keymaps 'org-mode-map
    :packages 'org-tree-slide
    "<f8>" #'org-tree-slide-mode)
  (dqv/major-leader-key
    :keymaps 'org-tree-slide-mode-map
    :packages 'org-tree-slide
    "d" (lambda () (interactive (setq org-tree-slide-skip-done (not org-tree-slide-skip-done))))
    "n" #'org-tree-slide-move-next-tree
    "p" #'org-tree-slide-move-previous-tree
    "j" #'org-tree-slide-move-next-tree
    "k" #'org-tree-slide-move-previous-tree
    "u" #'org-tree-slide-content))

(use-package org-roll
  :defer t
  :after org
  :straight (:build t :type git :host github :repo "zaeph/org-roll"))

(setq plstore-cache-passphrase-for-symmetric-encryption t)

(use-package org-gcal
  :straight (:build t))

(setq org-gcal-client-id "956221325874-3do4u85pu4s6br8dnlgjgumaje8b0mrg.apps.googleusercontent.com"
      org-gcal-client-secret "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"
      org-gcal-fetch-file-alist '(("vugomars@gmail.com" .  "~/Dropbox/Org/Personal.org")
                                  ("s46oeu2bmec42u0npm837dcmuk@group.calendar.google.com" .  "~/Dropbox/Org/Study.org")
                                  ("b3b6cb234ff0c1bfc2936d5fbb366d24768491cf1ae1750828c14bef6c24494e@group.calendar.google.com" .  "~/Dropbox/Org/Training.org")
                                  ("3c86ecf75197c0493e3773371e8f12baa7196203379112e995829cd31a01a00d@group.calendar.google.com" .  "~/Dropbox/Org/Social.org")
                                  ("tau3ru1gb0ljd6chsijg4vr6c4@group.calendar.google.com" .  "~/Dropbox/Org/Work.org")))

(use-package org-roam
  :ensure t
  :hook (after-init . org-roam-mode)
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Dropbox/Roam")
  (org-roam-completion-everywhere t)
  (org-roam-completion-system 'ivy)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("l" "programming language" plain
      "* Characteristics\n\n- Family: %?\n- Inspired by: \n\n* Reference:\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
      :unnarrowed t)))
  :config
  (org-roam-setup))

(alert-add-rule :status   '(buried visible idle)
                :severity '(moderate high urgent)
                :mode     'erc-mode
                :predicate
                #'(lambda (info)
                    (string-match (concat "\\`[^&].*@BitlBee\\'")
                                  (erc-format-target-and/or-network)))
                :persistent
                #'(lambda (info)
                    ;; If the buffer is buried, or the user has been
                    ;; idle for `alert-reveal-idle-time' seconds,
                    ;; make this alert persistent.  Normally, alerts
                    ;; become persistent after
                    ;; `alert-persist-idle-time' seconds.
                    (memq (plist-get info :status) '(buried idle)))
                :style 'fringe
                :continue t)

(use-package company
  :straight (:build t)
  :defer t
  :hook (company-mode . evil-normalize-keymaps)
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length     2
        company-toolsip-limit             14
        company-tooltip-align-annotations t
        company-require-match             'never
        company-global-modes              '(not erc-mode message-mode help-mode gud-mode)
        company-frontends
        '(company-pseudo-tooltip-frontend ; always show candidates in overlay tooltip
          company-echo-metadata-frontend) ; show selected candidate docs in echo area
        company-backends '(company-capf)
        company-auto-commit         nil
        company-auto-complete-chars nil
        company-dabbrev-other-buffers nil
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase    nil))

(use-package company-dict
  :after company
  :straight (:build t)
  :config
  (setq company-dict-dir (expand-file-name "dicts" user-emacs-directory)))

(use-package company-box
  :straight (:build t)
  :after (company all-the-icons)
  :config
  (setq company-box-show-single-candidate t
        company-box-backends-colors       nil
        company-box-max-candidates        50
        company-box-icons-alist           'company-box-icons-all-the-icons
        company-box-icons-all-the-icons
        (let ((all-the-icons-scale-factor 0.8))
          `(
            (Unknown . ,(all-the-icons-material "find_in_page" :face 'all-the-icons-purple))
            (Text . ,(all-the-icons-material "text_fields" :face 'all-the-icons-green))
            (Method . ,(all-the-icons-material "functions" :face 'all-the-icons-red))
            (Function . ,(all-the-icons-material "functions" :face 'all-the-icons-red))
            (Constructor . ,(all-the-icons-material "functions" :face 'all-the-icons-red))
            (Field . ,(all-the-icons-material "functions" :face 'all-the-icons-red))
            (Variable . ,(all-the-icons-material "adjust" :face 'all-the-icons-blue))
            (Class . ,(all-the-icons-material "class" :face 'all-the-icons-red))
            (Interface . ,(all-the-icons-material "settings_input_component" :face 'all-the-icons-red))
            (Module . ,(all-the-icons-material "view_module" :face 'all-the-icons-red))
            (Property . ,(all-the-icons-material "settings" :face 'all-the-icons-red))
            (Unit . ,(all-the-icons-material "straighten" :face 'all-the-icons-red))
            (Value . ,(all-the-icons-material "filter_1" :face 'all-the-icons-red))
            (Enum . ,(all-the-icons-material "plus_one" :face 'all-the-icons-red))
            (Keyword . ,(all-the-icons-material "filter_center_focus" :face 'all-the-icons-red))
            (Snippet . ,(all-the-icons-material "short_text" :face 'all-the-icons-red))
            (Color . ,(all-the-icons-material "color_lens" :face 'all-the-icons-red))
            (File . ,(all-the-icons-material "insert_drive_file" :face 'all-the-icons-red))
            (Reference . ,(all-the-icons-material "collections_bookmark" :face 'all-the-icons-red))
            (Folder . ,(all-the-icons-material "folder" :face 'all-the-icons-red))
            (EnumMember . ,(all-the-icons-material "people" :face 'all-the-icons-red))
            (Constant . ,(all-the-icons-material "pause_circle_filled" :face 'all-the-icons-red))
            (Struct . ,(all-the-icons-material "streetview" :face 'all-the-icons-red))
            (Event . ,(all-the-icons-material "event" :face 'all-the-icons-red))
            (Operator . ,(all-the-icons-material "control_point" :face 'all-the-icons-red))
            (TypeParameter . ,(all-the-icons-material "class" :face 'all-the-icons-red))
            (Template . ,(all-the-icons-material "short_text" :face 'all-the-icons-green))
            (ElispFunction . ,(all-the-icons-material "functions" :face 'all-the-icons-red))
            (ElispVariable . ,(all-the-icons-material "check_circle" :face 'all-the-icons-blue))
            (ElispFeature . ,(all-the-icons-material "stars" :face 'all-the-icons-orange))
            (ElispFace . ,(all-the-icons-material "format_paint" :face 'all-the-icons-pink))
            ))))

(use-package ivy
  :straight t
  :defer t
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         ("C-u" . ivy-scroll-up-command)
         ("C-d" . ivy-scroll-down-command)
         :map ivy-switch-buffer-map
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1)
  (setq ivy-wrap                        t
        ivy-height                      17
        ivy-sort-max-size               50000
        ivy-fixed-height-minibuffer     t
        ivy-read-action-functions       #'ivy-hydra-read-action
        ivy-read-action-format-function #'ivy-read-action-format-columns
        projectile-completion-system    'ivy
        ivy-on-del-error-function       #'ignore
        ivy-use-selectable-prompt       t))

(use-package ivy-prescient
  :after ivy
  :straight (:build t))

(use-package all-the-icons-ivy
  :straight (:build t)
  :after (ivy all-the-icons)
  :hook (after-init . all-the-icons-ivy-setup))

(use-package ivy-posframe
  :defer t
  :after (:any ivy helpful)
  :hook (ivy-mode . ivy-posframe-mode)
  :straight (:build t)
  :init
  (ivy-posframe-mode 1)
  :config
  (setq ivy-fixed-height-minibuffer nil
        ivy-posframe-border-width   10
        ivy-posframe-parameters
        `((min-width  . 90)
          (min-height . ,ivy-height))))

(use-package ivy-rich
  :straight (:build t)
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :straight (:build t)
  :after recentf
  :after ivy
  :bind (("M-x"     . counsel-M-x)
         ("C-x b"   . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package yasnippet
  :defer t
  :straight (:build t)
  :init
  (yas-global-mode)
  :hook ((prog-mode . yas-minor-mode)
         (text-mode . yas-minor-mode)))

(use-package yasnippet-snippets
  :defer t
  :after yasnippet
  :straight (:build t))

(use-package yatemplate
  :defer t
  :after yasnippet
  :straight (:build t))

(use-package ivy-yasnippet
  :defer t
  :after (ivy yasnippet)
  :straight (:build t)
  :general
  (dqv/leader-key
    :infix "i"
    :packages 'ivy-yasnippet
    "y" #'ivy-yasnippet))

(use-package dockerfile-mode
  :defer t
  :straight (:build t)
  :hook (dockerfile-mode . lsp-deferred)
  :init
  (put 'docker-image-name 'safe-local-variable #'stringp)
  :mode "Dockerfile\\'")

(use-package docker
  :defer t
  :straight (:build t))

(use-package nov
  :straight (:build t)
  :defer t
  :mode ("\\.epub\\'" . nov-mode)
  :general
  (dqv/evil
    :keymaps 'nov-mode-map
    :packages 'nov
    "h"   #'nov-previous-document
    "k"   #'nov-scroll-up
    "C-p" #'nov-scroll-up
    "j"   #'nov-scroll-down
    "C-n" #'nov-scroll-down
    "l"   #'nov-next-document
    "gm"  #'nov-display-metadata
    "gn"  #'nov-next-document
    "gp"  #'nov-previous-document
    "gr"  #'nov-render-document
    "gt"  #'nov-goto-toc
    "gv"  #'nov-view-source
    "gV"  #'nov-view-content-source)
  :config
  (setq nov-text-width 95))

(use-package pdf-tools
  :defer t
  :magic ("%PDF" . pdf-view-mode)
  :straight (:build t)
  :mode (("\\.pdf\\'" . pdf-view-mode))
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :general
  (dqv/evil
    :keymaps 'pdf-view-mode-map
    :packages 'pdf-tools
    "y"   #'pdf-view-kill-ring-save
    "j"   #'evil-collection-pdf-view-next-line-or-next-page
    "k"   #'evil-collection-pdf-view-previous-line-or-previous-page)
  (dqv/major-leader-key
    :keymaps 'pdf-view-mode-map
    :packages 'pdf-tools
    "a"  '(:ignore t :which-key "annotations")
    "aD" #'pdf-annot-delete
    "at" #'pdf-annot-attachment-dired
    "ah" #'pdf-annot-add-highlight-markup-annotation
    "al" #'pdf-annot-list-annotations
    "am" #'pdf-annot-markup-annotation
    "ao" #'pdf-annot-add-strikeout-markup-annotation
    "as" #'pdf-annot-add-squiggly-markup-annotation
    "at" #'pdf-annot-add-text-annotation
    "au" #'pdf-annot-add-underline-markup-annotation

    "f"  '(:ignore t :which-key "fit")
    "fw" #'pdf-view-fit-width-to-window
    "fh" #'pdf-view-fit-height-to-window
    "fp" #'pdf-view-fit-page-to-window

    "s"  '(:ignore t :which-key "slice/search")
    "sb" #'pdf-view-set-slice-from-bounding-box
    "sm" #'pdf-view-set-slice-using-mouse
    "sr" #'pdf-view-reset-slice
    "ss" #'pdf-occur

    "o"  'pdf-outline
    "m"  'pdf-view-midnight-minor-mode)
  :config
  (with-eval-after-load 'pdf-view
    (csetq pdf-view-midnight-colors '("#d8dee9" . "#2e3440"))))

(use-package pdf-view-restore
  :after pdf-tools
  :defer t
  :straight (:build t)
  :hook (pdf-view-mode . pdf-view-restore-mode)
  :config
  (setq pdf-view-restore-filename (expand-file-name ".tmp/pdf-view-restore"
                                                    user-emacs-directory)))

(use-package magit
  :straight (:build t)
  :defer t
  :init
  (setq forge-add-default-bindings nil)
  :config
  (csetq magit-clone-default-directory "~/fromGIT/"
         magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (with-eval-after-load 'evil-collection
    (dqv/evil
      :packages '(evil-collection magit)
      :keymaps '(magit-mode-map magit-log-mode-map magit-status-mode-map)
      :states 'normal
      "t" #'magit-tag
      "s" #'magit-stage))
  :general
  (:keymaps '(git-rebase-mode-map)
   :packages 'magit
   "C-j" #'evil-next-line
   "C-k" #'evil-previous-line)
  (dqv/major-leader-key
    :keymaps 'git-rebase-mode-map
    :packages 'magit
    "," #'with-editor-finish
    "k" #'with-editor-cancel
    "a" #'with-editor-cancel)
  (dqv/leader-key
    :infix   "g"
    :packages 'magit
    ""   '(:ignore t :wk "git")
    "b"  #'magit-blame
    "c"  #'magit-clone
    "d"  #'magit-dispatch
    "i"  #'magit-init
    "s"  #'magit-status
    "y"  #'my/yadm
    "S"  #'magit-stage-file
    "U"  #'magit-unstage-file
    "f"  '(:ignore t :wk "file")
    "fd" #'magit-diff
    "fc" #'magit-file-checkout
    "fl" #'magit-file-dispatch
    "fF" #'magit-find-file))

(use-package hl-todo
  :defer t
  :straight (:build t)
  :init (global-hl-todo-mode 1)
  :general
  (dqv/leader-key
    :packages '(hl-todo)
    :infix "c"
    ""  '(:ignore t :which-key "todos")
    "n" #'hl-todo-next
    "p" #'hl-todo-previous))

(use-package magit-todos
  :defer t
  :straight (:build t)
  :after (magit hl-todo)
  :init
  (with-eval-after-load 'magit
   (defun my/magit-todos-if-not-yadm ()
     "Deactivate magit-todos if in yadm Tramp connection.
If `magit--default-directory' points to a yadm Tramp directory,
deactivate `magit-todos-mode', otherwise enable it."
     (if (string-prefix-p "/yadm:" magit--default-directory)
         (magit-todos-mode -1)
       (magit-todos-mode +1)))
   (add-hook 'magit-mode-hook #'my/magit-todos-if-not-yadm))
  :config
  (csetq magit-todos-ignore-case t)
(setq magit-todos-keyword-suffix "\\(?:([^)]+)\\)?:")
)

(use-package magit-gitflow
  :defer t
  :after magit
  :straight (magit-gitflow :build t
                           :type git
                           :host github
                           :repo "jtatarik/magit-gitflow")
  :hook (magit-mode . turn-on-magit-gitflow))

(use-package forge
  :after magit
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :keymaps 'forge-topic-mode-map
    "c"  #'forge-create-post
    "e"  '(:ignore t :which-key "edit")
    "ea" #'forge-edit-topic-assignees
    "ed" #'forge-edit-topic-draft
    "ek" #'forge-delete-comment
    "el" #'forge-edit-topic-labels
    "em" #'forge-edit-topic-marks
    "eM" #'forge-merge
    "en" #'forge-edit-topic-note
    "ep" #'forge-edit-post
    "er" #'forge-edit-topic-review-requests
    "es" #'forge-edit-topic-state
    "et" #'forge-edit-topic-title))

 (defun buffer-insert-at-end (string)
    "Insert STRING at the maximal point in a buffer."
    (save-excursion
      (goto-char (point-max))
      (end-of-line)
      (insert ?\n string)
      (unless (string-suffix-p "\n" string)
        (insert ?\n))))

  (defun get-knuth-number-from-string (string)
    "Return KNUTH issue number from STRING.
  Return nil if STRING does not contain a KNUTH issue.
  STRING may be nil."
    (if (and string (string-match "\\(KNUTH-[[:digit:]]\+\\)" string))
        (match-string 1 string)
      nil))

  (defun insert-knuth-ticket-number-from-branch ()
    "If we're on a KNUTH feature branch, insert the ticket number."
    (interactive)
    (let ((knuth (get-knuth-number-from-string (magit-get-current-branch))))
      (if (and knuth (not (buffer-line-matches-p (concat "^" knuth)))) (buffer-insert-at-end knuth))))

  (defun buffer-line-matches-p (needle)
    "Return t if the last line matches NEEDLE.
  Ignores comments"
    (save-excursion
      (goto-char 0)
      (search-forward-regexp needle nil 'noerror)))

  (add-hook 'git-commit-setup-hook 'insert-knuth-ticket-number-from-branch)

(use-package ripgrep
  :if (executable-find "rg")
  :straight (:build t)
  :defer t)

(use-package projectile
  :straight (:build t)
  :diminish projectile-mode
  :custom ((projectile-completion-system 'ivy))
  :init
  (setq projectile-switch-project-action #'projectile-dired)
  :config
  (projectile-mode)
  (add-to-list 'projectile-ignored-projects "~/")
  (add-to-list 'projectile-globally-ignored-directories "^node_modules$")
  :general
  (dqv/leader-key
    "p" '(:keymap projectile-command-map :which-key "projectile")))

(use-package counsel-projectile
  :straight (:build t)
  :after (counsel projectile)
  :config (counsel-projectile-mode))

(use-package recentf
  :straight (:build t :type built-in)
  :custom ((recentf-max-saved-items 2000))
  :config
  ;; no Elfeed or native-comp files
  (add-all-to-list 'recentf-exclude
                   `(,(rx (* any)
                          (or "elfeed-db"
                              "eln-cache"
                              "conlanging/content"
                              "org/config"
                              "/Mail/Sent"
                              ".cache/")
                          (* any)
                          (? (or "html" "pdf" "tex" "epub")))
                     ,(rx "/"
                          (or "rsync" "ssh" "tmp" "yadm" "sudoedit" "sudo")
                          (* any)))))

(use-package screenshot
  :defer t
  :straight (screenshot :build t
                        :type git
                        :host github
                        :repo "tecosaur/screenshot")
  :config (load-file (locate-library "screenshot.el"))
  :general
  (dqv/leader-key
    :infix "a"
    :packages '(screenshot)
    "S" #'screenshot))

(use-package shell-pop
  :defer t
  :straight (:build t)
  :custom
  (shell-pop-default-directory "/home/phundrak")
  (shell-pop-shell-type (quote ("eshell" "*eshell*" (lambda () (eshell shell-pop-term-shell)))))
  (shell-pop-window-size 30)
  (shell-pop-full-span nil)
  (shell-pop-window-position "bottom")
  (shell-pop-autocd-to-working-dir t)
  (shell-pop-restore-window-configuration t)
  (shell-pop-cleanup-buffer-at-process-exit t))

(use-package popwin
  :straight t)

(with-eval-after-load 'popwin
  (dqv/leader-key
    "oe" '(+popwin:eshell :wk "Eshell popup")
    "oE" '(eshell :wk "Eshell"))
  (defun +popwin:eshell ()
    (interactive)
    (popwin:display-buffer-1
     (or (get-buffer "*eshell*")
         (save-window-excursion
           (call-interactively 'eshell)))
     :default-config-keywords '(:position :bottom :height 14))))

(use-package vterm
  :defer t
  :straight t
  :general
  (dqv/leader-key
   "ot" '(+popwin:vterm :wk "vTerm popup")
   "oT" '(vterm :wk "vTerm"))
  :preface
  (when noninteractive
    (advice-add #'vterm-module-compile :override #'ignore)
    (provide 'vterm-module))
  :custom
  (vterm-max-scrollback 5000)
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  (setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000)
  (with-eval-after-load 'popwin
    (defun +popwin:vterm ()
      (interactive)
      (popwin:display-buffer-1
       (or (get-buffer "*vterm*")
           (save-window-excursion
             (call-interactively 'vterm)))
       :default-config-keywords '(:position :bottom :height 14)))))

(use-package multi-vterm
  :after vterm
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :packages '(vterm multi-vterm)
    :keymap 'vterm-mode-map
    "c" #'multi-vterm
    "j" #'multi-vterm-next
    "k" #'multi-vterm-prev))

(use-package leetcode
  :ensure t
  :straight (:build t))
(setq leetcode-prefer-language "rust"
      leetcode-prefer-sql "mysql"
      leetcode-save-solutions t
      leetcode-directory "~/Development/leetcode-solution")

(general-define-key
 :states 'visual
 "M-["  #'insert-pair
 "M-{"  #'insert-pair
 "M-<"  #'insert-pair
 "M-'"  #'insert-pair
 "M-`"  #'insert-pair
 "M-\"" #'insert-pair)

(use-package atomic-chrome
  :straight (:build t)
  :init
  (atomic-chrome-start-server)
  :config
  (setq atomic-chrome-default-major-mode 'markdown-mode
        atomic-chrome-url-major-mode-alist `(("github\\.com"          . gfm-mode)
                                             ("gitlab\\.com"          . gfm-mode)
                                             ("labs\\.phundrak\\.com" . markdown-mode)
                                             ("reddit\\.com"          . markdown-mode))))

(use-package editorconfig
  :defer t
  :straight (:build t)
  :diminish editorconfig-mode
  :config
  (editorconfig-mode t))

(use-package evil-nerd-commenter
  :after evil
  :straight (:build t))

(use-package evil-iedit-state
  :defer t
  :straight (:build t)
  :commands (evil-iedit-state evil-iedit-state/iedit-mode)
  :init
  (setq iedit-curent-symbol-default     t
        iedit-only-at-symbol-boundaries t
        iedit-toggle-key-default        nil)
  :general
  (dqv/leader-key
    :infix "r"
    :packages '(iedit evil-iedit-state)
    "" '(:ignore t :which-key "refactor")
    "i" #'evil-iedit-state/iedit-mode)
  (general-define-key
   :keymaps 'evil-iedit-state-map
   "c" nil
   "s" nil
   "J" nil
   "S" #'iedit-expand-down-a-line
   "T" #'iedit-expand-up-a-line
   "h" #'evil-iedit-state/evil-change
   "k" #'evil-iedit-state/evil-substitute
   "K" #'evil-iedit-state/substitute
   "q" #'evil-iedit-state/quit-iedit-mode))

(use-package parinfer-rust-mode
  :defer t
  :straight (:build t)
  :diminish parinfer-rust-mode
  :hook emacs-lisp-mode common-lisp-mode scheme-mode
  :init
  (setq parinfer-rust-auto-download     t
        parinfer-rust-library-directory (concat user-emacs-directory
                                                "parinfer-rust/"))
  (add-hook 'parinfer-rust-mode-hook
            (lambda () (smartparens-mode -1)))
  :general
  (dqv/major-leader-key
    :keymaps 'parinfer-rust-mode-map
    "m" #'parinfer-rust-switch-mode
    "M" #'parinfer-rust-toggle-disable))

(use-package smartparens
  :defer t
  :straight (:build t)
  :hook (prog-mode . smartparens-mode))

(use-package string-edit-at-point
  :defer t
  :straight (:build t))

(use-package maple-iedit
  :ensure nil
  :commands (maple-iedit-match-all maple-iedit-match-next maple-iedit-match-previous)
  :config
  (setq maple-iedit-ignore-case t)

  (defhydra maple/iedit ()
    ("n" maple-iedit-match-next "next")
    ("t" maple-iedit-skip-and-match-next "skip and next")
    ("T" maple-iedit-skip-and-match-previous "skip and previous")
    ("p" maple-iedit-match-previous "prev"))
  :bind (:map evil-visual-state-map
              ("n" . maple/iedit/body)
              ;; ("C-n" . maple-iedit-match-next)
              ;; ("C-p" . maple-iedit-match-previous)
              ("C-t" . maple-iedit-skip-and-match-next)))

  (use-package engine-mode
    :config
    (engine/set-keymap-prefix (kbd "C-c s"))
    (setq browse-url-browser-function 'browse-url-default-macosx-browser
          engine/browser-function 'browse-url-default-macosx-browser
          )

    (defengine duckduckgo
      "https://duckduckgo.com/?q=%s"
      :keybinding "d")

    (defengine github
      "https://github.com/search?ref=simplesearch&q=%s"
      :keybinding "1")

    (defengine gitlab
      "https://gitlab.com/search?search=%s&group_id=&project_id=&snippets=false&repository_ref=&nav_source=navbar"
      :keybinding "2")

    (defengine stack-overflow
      "https://stackoverflow.com/search?q=%s"
      :keybinding "s")

    (defengine npm
      "https://www.npmjs.com/search?q=%s"
      :keybinding "n")

    (defengine crates
      "https://crates.io/search?q=%s"
      :keybinding "c")

    (defengine localhost
      "http://localhost:%s"
      :keybinding "l")

    (defengine translate
      "https://www.macmillandictionary.com/dictionary/british/%s"
      :keybinding "t")

    (defengine youtube
      "http://www.youtube.com/results?aq=f&oq=&search_query=%s"
      :keybinding "y")

    (defengine google
      "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s"
      :keybinding "g")

    (engine-mode 1))

  (use-package bm
    :demand t
    :init
    ;; restore on load (even before you require bm)
    (setq bm-restore-repository-on-load t)

    :config
    ;; Allow cross-buffer 'next'
    (setq bm-cycle-all-buffers t

          ;; where to store persistant files
          bm-repository-file "~/.emacs.d/bm-repository")

    ;; save bookmarks
    (setq-default bm-buffer-persistence t)

    ;; Loading the repository from file when on start up.
    (add-hook 'after-init-hook 'bm-repository-load)

    ;; Saving bookmarks
    (add-hook 'kill-buffer-hook #'bm-buffer-save)

    ;; must save all bookmarks first.
    (add-hook 'kill-emacs-hook #'(lambda nil
                                   (bm-buffer-save-all)
                                   (bm-repository-save)))

    (add-hook 'after-save-hook #'bm-buffer-save)

    ;; Restoring bookmarks
    (add-hook 'find-file-hooks   #'bm-buffer-restore)
    (add-hook 'after-revert-hook #'bm-buffer-restore)

    (add-hook 'vc-before-checkin-hook #'bm-buffer-save)

    ;; key binding
    :bind (("C-M-s-l" . bm-toggle)
           ("C-M-s-j" . bm-next)
           ("C-M-s-k" . bm-previous)
           ("C-M-s-o" . bm-show-all))
    )

(use-package move-text
  :straight (:build t))

(global-set-key (kbd "s-j") #'move-text-down)
(global-set-key (kbd "s-k") #'move-text-up)

(use-package hideshow
  :hook
  (prog-mode . hs-minor-mode)
  :bind
  ("C-<tab>" . hs-cycle)
  ("C-<iso-lefttab>" . hs-global-cycle)
  ("C-S-<tab>" . hs-global-cycle))
(defun hs-cycle (&optional level)
  (interactive "p")
  (let (message-log-max
        (inhibit-message t))
    (if (= level 1)
        (pcase last-command
          ('hs-cycle
           (hs-hide-level 1)
           (setq this-command 'hs-cycle-children))
          ('hs-cycle-children
           ;; called twice to open all folds of the parent
           ;; block.
           (save-excursion (hs-show-block))
           (hs-show-block)
           (setq this-command 'hs-cycle-subtree))
          ('hs-cycle-subtree
           (hs-hide-block))
          (_
               (hs-hide-block)
             (hs-hide-level 1)
             (setq this-command 'hs-cycle-children)))
      (hs-hide-level level)
      (setq this-command 'hs-hide-level))))

(defun hs-global-cycle ()
    (interactive)
    (pcase last-command
      ('hs-global-cycle
       (save-excursion (hs-show-all))
       (setq this-command 'hs-global-show))
      (_ (hs-hide-all))))

  (use-package eyebrowse
    :straight (:build t)
    :config
    (setq eyebrowse-new-workspace t)
    (eyebrowse-mode 1))

  (dqv/leader-key
   "TAB"  '(:ignore t :which-key "Window Management")
   "TAB 0" '(eyebrowse-switch-to-window-config-0 :which-key "Select Windown 0")
   "TAB 1" '(eyebrowse-switch-to-window-config-1 :which-key "Select Window 1")
   "TAB 2" '(eyebrowse-switch-to-window-config-2 :which-key "Select Window 2")
   "TAB 3" '(eyebrowse-switch-to-window-config-3 :which-key "Select Window 3")
   "TAB 4" '(eyebrowse-switch-to-window-config-4 :which-key "Select Window 4")
   "TAB 5" '(eyebrowse-switch-to-window-config-5 :which-key "Select Window 5")
   "TAB 6" '(eyebrowse-switch-to-window-config-6 :which-key "Select Window 6")
   "TAB 7" '(eyebrowse-switch-to-window-config-7 :which-key "Select Window 7")
   "TAB 8" '(eyebrowse-switch-to-window-config-8 :which-key "Select Window 8")
   "TAB 9" '(eyebrowse-switch-to-window-config-9 :which-key "Select Window 9")
   "TAB r" '(eyebrowse-rename-window-config :which-key "Rename Window")
   "TAB n" '(eyebrowse-create-window-config :which-key "Create New Window")
   "TAB TAB" '(eyebrowse-switch-to-window-config :which-key "Switch Window")
   "TAB d" '(eyebrowse-close-window-config :which-key "Delete Window")
   "TAB j" '(eyebrowse-next-window-config :which-key "Next Window")
   "TAB k" '(eyebrowse-prev-window-config :which-key "Previous Window"))

(use-package dirvish
  :straight (:build t)
  :defer t
  :init (dirvish-override-dired-mode)
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/" "Home")
     ("d" "~/Downloads/" "Downloads")
     ("c" "~/org/config" "Config")
     ("C" "~/Documents/conlanging/content" "Conlanging")))
  (dirvish-mode-line-format
   '(:left (sort file-time "" file-size symlink) :right (omit yank index)))
  (dirvish-attributes '(all-the-icons file-size collapse subtree-state vc-state git-msg))
  :config
  (dirvish-peek-mode)
  (csetq dired-mouse-drag-files                   t
         mouse-drag-and-drop-region-cross-program t)
  (csetq dired-listing-switches (string-join '("--all"
                                               "--human-readable"
                                               "--time-style=long-iso"
                                               "--group-directories-first"
                                               "-lv1")
                                             " "))
  (let ((my/file (lambda (path &optional dir)
                   (expand-file-name path (or dir user-emacs-directory))))
        (my/dir (lambda (path &optional dir)
                  (expand-file-name (file-name-as-directory path)
                                    (or dir user-emacs-directory)))))
    (csetq image-dired-thumb-size             150
           image-dired-dir                    (funcall my/dir "dired-img")
           image-dired-db-file                (funcall my/file "dired-db.el")
           image-dired-gallery-dir            (funcall my/dir "gallery")
           image-dired-temp-image-file        (funcall my/file "temp-image" image-dired-dir)
           image-dired-temp-rotate-image-file (funcall my/file "temp-rotate-image" image-dired-dir)))
  (dirvish-define-preview exa (file)
    "Use `exa' to generate directory preview."
    :require ("exa")
    (when (file-directory-p file)
      `(shell . ("exa" "--color=always" "-al" ,file))))
  
  (add-to-list 'dirvish-preview-dispatchers 'exa)
  (csetq dired-dwim-target         t
         dired-recursive-copies    'always
         dired-recursive-deletes   'top
         delete-by-moving-to-trash t)
  :general
  (dqv/evil
    :keymaps 'dirvish-mode-map
    :packages '(dired dirvish)
    "q" #'dirvish-quit
    "TAB" #'dirvish-subtree-toggle)
  (dqv/major-leader-key
    :keymaps 'dirvish-mode-map
    :packages '(dired dirvish)
    "A"   #'gnus-dired-attach
    "a"   #'dirvish-quick-access
    "d"   #'dirvish-dispatch
    "e"   #'dirvish-emerge-menu
    "f"   #'dirvish-fd-jump
    "F"   #'dirvish-file-info-menu
    "h"   '(:ignore t :which-key "history")
    "hp"  #'dirvish-history-go-backward
    "hn"  #'dirvish-history-go-forward
    "hj"  #'dirvish-history-jump
    "hl"  #'dirvish-history-last
    "l"   '(:ignore t :which-key "layout")
    "ls"  #'dirvish-layout-switch
    "lt"  #'dirvish-layout-toggle
    "m"   #'dirvish-mark-menu
    "s"   #'dirvish-quicksort
    "S"   #'dirvish-setup-menu
    "y"   #'dirvish-yank-menu
    "n"   #'dirvish-narrow))

(use-package dired-rsync
  :if (executable-find "rsync")
  :defer t
  :straight (:build t)
  :general
  (dqv/evil
    :keymaps 'dired-mode-map
    :packages 'dired-rsync
    "C-r" #'dired-rsync))

(use-package compile
  :defer t
  :straight (compile :type built-in)
  :hook (compilation-mode . colorize-compilation-buffer)
  :init
  (require 'ansi-color)
  (defun colorize-compilation-buffer ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max))))
  :general
  (dqv/evil
    :keymaps 'compilation-mode-map
    "g" nil
    "r" nil
    "R" #'recompile
    "h" nil)
  (dqv/leader-key
    "R" #'recompile)
  :config
  (setq compilation-scroll-output t))

(use-package eshell
  :defer t
  :straight (:type built-in :build t)
  :config
  (setq eshell-prompt-function
        (lambda ()
          (concat (abbreviate-file-name (eshell/pwd))
                  (if (= (user-uid) 0) " # " " λ ")))
        eshell-prompt-regexp "^[^#λ\n]* [#λ] ")
  (setq eshell-aliases-file (expand-file-name "eshell-alias" user-emacs-directory))
  (defun phundrak/concatenate-shell-command (&rest command)
    "Concatenate an eshell COMMAND into a single string.
  All elements of COMMAND will be joined in a single
  space-separated string."
    (mapconcat #'identity command " "))
  (defalias 'open #'find-file)
  (defalias 'openo #'find-file-other-window)
  (defalias 'eshell/clear #'eshell/clear-scrollback)
  (defalias 'list-buffers 'ibuffer)
  (defun eshell/emacs (&rest file)
    "Open each FILE and kill eshell.
  Old habits die hard."
    (when file
      (dolist (f (reverse file))
        (find-file f t))))
  (defun eshell/mkcd (dir)
    "Create the directory DIR and move there.
  If the directory DIR doesn’t exist, create it and its parents
  if needed, then move there."
    (mkdir dir t)
    (cd dir))
  :general
  (dqv/evil
    :keymaps 'eshell-mode-map
    [remap evil-collection-eshell-evil-change] #'evil-backward-char
    "c" #'evil-backward-char
    "t" #'evil-next-visual-line
    "s" #'evil-previous-visual-line
    "r" #'evil-forward-char
    "h" #'evil-collection-eshell-evil-change)
  (general-define-key
   :keymaps 'eshell-mode-map
   :states 'insert
   "C-a" #'eshell-bol
   "C-e" #'end-of-line))

(use-package esh-autosuggest
  :defer t
  :after eshell
  :straight (:build t)
  :hook (eshell-mode . esh-autosuggest-mode)
  :general
  (:keymaps 'esh-autosuggest-active-map
   "C-e" #'company-complete-selection))

(defadvice find-file (around find-files activate)
  "Also find all files within a list of files. This even works recursively."
  (if (listp filename)
      (cl-loop for f in filename do (find-file f wildcards))
    ad-do-it))

(defun eshell-new ()
  "Open a new instance of eshell."
  (interactive)
  (eshell 'N))

(use-package eshell-z
  :defer t
  :after eshell
  :straight (:build t)
  :hook (eshell-mode . (lambda () (require 'eshell-z))))

(setenv "DART_SDK" "/opt/dart-sdk/bin")
(setenv "ANDROID_HOME" (concat (getenv "HOME") "/Android/Sdk/"))

(setenv "EDITOR" "emacsclient -c -a emacs")

(setenv "SHELL" "/bin/zsh")

(use-package eshell-info-banner
  :after (eshell)
  :defer t
  :straight (eshell-info-banner :build t
                                :type git
                                :host github
                                :protocol ssh
                                :repo "phundrak/eshell-info-banner.el")
  :hook (eshell-banner-load . eshell-info-banner-update-banner)
  :config
  (setq eshell-info-banner-width 80
        eshell-info-banner-partition-prefixes '("/dev" "zroot" "tank")))

(use-package eshell-syntax-highlighting
  :after (esh-mode eshell)
  :defer t
  :straight (:build t)
  :config
  (eshell-syntax-highlighting-global-mode +1))

(use-package powerline-eshell
  :if (string= (string-trim (shell-command-to-string "uname -n")) "leon")
  :load-path "~/fromGIT/emacs-packages/powerline-eshell.el/"
  :after eshell)

(use-package eww
  :defer t
  :straight (:type built-in)
  :config
  (setq eww-auto-rename-buffer 'title))

(setq image-use-external-converter t)

(use-package info
  :defer t
  :straight (info :type built-in :build t)
  :general
  (dqv/evil
    :keymaps 'Info-mode-map
    "c" #'Info-prev
    "t" #'evil-scroll-down
    "s" #'evil-scroll-up
    "r" #'Info-next)
  (dqv/major-leader-key
    :keymaps 'Info-mode-map
    "?" #'Info-toc
    "b" #'Info-history-back
    "f" #'Info-history-forward
    "m" #'Info-menu
    "t" #'Info-top-node
    "u" #'Info-up))

(use-package tramp
  :straight (tramp :type built-in :build t)
  :config
  (add-to-list 'tramp-methods
                     '("yadm"
                       (tramp-login-program "yadm")
                       (tramp-login-args (("enter")))
                       (tramp-login-env (("SHELL") ("/bin/zsh")))
                       (tramp-remote-shell "/bin/zsh")
                       (tramp-remote-shell-args ("-c"))))
  (csetq tramp-ssh-controlmaster-options nil
         tramp-verbose 0
         tramp-auto-save-directory (locate-user-emacs-file "tramp/")
         tramp-chunksize 2000)
  (add-to-list 'backup-directory-alist ; deactivate auto-save with TRAMP
               (cons tramp-file-name-regexp nil)))

(defun my/yadm ()
  "Manage my dotfiles through TRAMP."
  (interactive)
  (magit-status "/yadm::"))

(use-package bufler
  :straight (:build t)
  :bind (("C-M-j" . bufler-switch-buffer)
         ("C-M-k" . bufler-workspace-frame-set))
  :config
  (evil-collection-define-key 'normal 'bufler-list-mode-map
    (kbd "RET")   'bufler-list-buffer-switch
    (kbd "M-RET") 'bufler-list-buffer-peek
    "D"           'bufler-list-buffer-kill)

  (setf bufler-groups
        (bufler-defgroups
          ;; Subgroup collecting all named workspaces.
          (group (auto-workspace))
          ;; Subgroup collecting buffers in a projectile project.
          (group (auto-projectile))
          ;; Grouping browser windows
          (group
           (group-or "Browsers"
                     (name-match "Vimb" (rx bos "vimb"))
                     (name-match "Qutebrowser" (rx bos "Qutebrowser"))
                     (name-match "Chromium" (rx bos "Chromium"))))
          (group
           (group-or "Chat"
                     (mode-match "Telega" (rx bos "telega-"))))
          (group
           ;; Subgroup collecting all `help-mode' and `info-mode' buffers.
           (group-or "Help/Info"
                     (mode-match "*Help*" (rx bos (or "help-" "helpful-")))
                     ;; (mode-match "*Helpful*" (rx bos "helpful-"))
                     (mode-match "*Info*" (rx bos "info-"))))
          (group
           ;; Subgroup collecting all special buffers (i.e. ones that are not
           ;; file-backed), except `magit-status-mode' buffers (which are allowed to fall
           ;; through to other groups, so they end up grouped with their project buffers).
           (group-and "*Special*"
                      (name-match "**Special**"
                                  (rx bos "*" (or "Messages" "Warnings" "scratch" "Backtrace" "Pinentry") "*"))
                      (lambda (buffer)
                        (unless (or (funcall (mode-match "Magit" (rx bos "magit-status"))
                                             buffer)
                                    (funcall (mode-match "Dired" (rx bos "dired"))
                                             buffer)
                                    (funcall (auto-file) buffer))
                          "*Special*"))))
          ;; Group remaining buffers by major mode.
          (auto-mode))))

(use-package helpful
  :straight (:build t)
  :after (counsel ivy)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key]      . helpful-key))

(use-package auctex
  :defer t
  :straight (:build t)
  :hook (tex-mode . lsp-deferred)
  :hook (latex-mode . lsp-deferred)
  :init
  (setq TeX-command-default   (if (executable-find "latexmk") "LatexMk" "LaTeX")
        TeX-engine            (if (executable-find "xetex")   'xetex    'default)
        TeX-auto-save                     t
        TeX-parse-self                    t
        TeX-syntactic-comment             t
        TeX-auto-local                    ".auctex-auto"
        TeX-style-local                   ".auctex-style"
        TeX-source-correlate-mode         t
        TeX-source-correlate-method       'synctex
        TeX-source-correlate-start-server nil
        TeX-electric-sub-and-superscript  t
        TeX-fill-break-at-separators      nil
        TeX-save-query                    t)
  :config
  (setq font-latex-match-reference-keywords
        '(;; BibLaTeX.
          ("printbibliography" "[{") ("addbibresource" "[{")
          ;; Standard commands.
          ("cite" "[{")       ("citep" "[{")
          ("citet" "[{")      ("Cite" "[{")
          ("parencite" "[{")  ("Parencite" "[{")
          ("footcite" "[{")   ("footcitetext" "[{")
          ;; Style-specific commands.
          ("textcite" "[{")   ("Textcite" "[{")
          ("smartcite" "[{")  ("Smartcite" "[{")
          ("cite*" "[{")      ("parencite*" "[{")
          ("supercite" "[{")
          ;; Qualified citation lists.
          ("cites" "[{")      ("Cites" "[{")
          ("parencites" "[{") ("Parencites" "[{")
          ("footcites" "[{")  ("footcitetexts" "[{")
          ("smartcites" "[{") ("Smartcites" "[{")
          ("textcites" "[{")  ("Textcites" "[{")
          ("supercites" "[{")
          ;; Style-independent commands.
          ("autocite" "[{")   ("Autocite" "[{")
          ("autocite*" "[{")  ("Autocite*" "[{")
          ("autocites" "[{")  ("Autocites" "[{")
          ;; Text commands.
          ("citeauthor" "[{") ("Citeauthor" "[{")
          ("citetitle" "[{")  ("citetitle*" "[{")
          ("citeyear" "[{")   ("citedate" "[{")
          ("citeurl" "[{")
          ;; Special commands.
          ("fullcite" "[{")
          ;; Cleveref.
          ("cref" "{")          ("Cref" "{")
          ("cpageref" "{")      ("Cpageref" "{")
          ("cpagerefrange" "{") ("Cpagerefrange" "{")
          ("crefrange" "{")     ("Crefrange" "{")
          ("labelcref" "{")))
  
  (setq font-latex-match-textual-keywords
        '(;; BibLaTeX brackets.
          ("parentext" "{") ("brackettext" "{")
          ("hybridblockquote" "[{")
          ;; Auxiliary commands.
          ("textelp" "{")   ("textelp*" "{")
          ("textins" "{")   ("textins*" "{")
          ;; Subcaption.
          ("subcaption" "[{")))
  
  (setq font-latex-match-variable-keywords
        '(;; Amsmath.
          ("numberwithin" "{")
          ;; Enumitem.
          ("setlist" "[{")     ("setlist*" "[{")
          ("newlist" "{")      ("renewlist" "{")
          ("setlistdepth" "{") ("restartlist" "{")
          ("crefname" "{")))
  (setq TeX-master t)
  (setcar (cdr (assoc "Check" TeX-command-list)) "chktex -v6 -H %s")
  (add-hook 'TeX-mode-hook (lambda ()
                             (setq ispell-parser          'tex
                                   fill-nobreak-predicate (cons #'texmathp fill-nobreak-predicate))))
  (add-hook 'TeX-mode-hook #'visual-line-mode)
  (add-hook 'TeX-update-style-hook #'rainbow-delimiters-mode)
  :general
  (dqv/major-leader-key
    :packages 'auctex
    :keymaps  '(latex-mode-map LaTeX-mode-map)
    "v" '(TeX-view            :which-key "View")
    "c" '(TeX-command-run-all :which-key "Compile")
    "m" '(TeX-command-master  :which-key "Run a command")))

(use-package tex-mode
  :defer t
  :straight (:type built-in)
  :config
  (setq LaTeX-section-hook '(LaTeX-section-heading
                             LaTeX-section-title
                             LaTeX-section-toc
                             LaTeX-section-section
                             LaTeX-section-label)
        LaTeX-fill-break-at-separators nil
        LaTeX-item-indent              0))

(use-package preview
  :defer t
  :straight (:type built-in)
  :config
  (add-hook 'LaTeX-mode-hook #'LaTeX-preview-setup)
  (setq-default preview-scale 1.4
                preview-scale-function
                (lambda () (* (/ 10.0 (preview-document-pt)) preview-scale)))
  (setq preview-auto-cache-preamble nil)
  (dqv/major-leader-key
    :packages 'auctex
    :keymaps '(latex-mode-map LaTeX-mode-map)
    "p" #'preview-at-point
    "P" #'preview-clearout-at-point))

(use-package cdlatex
  :defer t
  :after auctex
  :straight (:build t)
  :hook (LaTeX-mode . cdlatex-mode)
  :hook (org-mode   . org-cdlatex-mode)
  :config
  (setq cdlatex-use-dollar-to-ensure-math nil)
  :general
  (dqv/major-leader-key
    :packages 'cdlatex
    :keymaps 'cdlatex-mode-map
    "$" nil
    "(" nil
    "{" nil
    "[" nil
    "|" nil
    "<" nil
    "^" nil
    "_" nil
    [(control return)] nil))

(use-package adaptive-wrap
  :defer t
  :after auctex
  :straight (:build t)
  :hook (LaTeX-mode . adaptative-wrap-prefix-mode)
  :init (setq-default adaptative-wrap-extra-indent 0))

(use-package auctex-latexmk
  :after auctex
  :defer t
  :straight (:build t)
  :init
  (setq auctex-latexmk-inherit-TeX-PDF-mode t)
  (add-hook 'LaTeX-mode (lambda () (setq TeX-command-default "LatexMk")))
  :config
  (auctex-latexmk-setup))

(use-package company-auctex
  :defer t
  :after (company auctex)
  :straight (:build t)
  :config
  (company-auctex-init))

(use-package company-math
  :defer t
  :straight (:build t)
  :after (company auctex)
  :config
  (defun my-latex-mode-setup ()
    (setq-local company-backends
                (append '((company-math-symbols-latex company-latex-commands))
                        company-backends)))
  (add-hook 'TeX-mode-hook #'my-latex-mode-setup))

(use-package tree-sitter
  :defer t
  :straight (:build t)
  :init (global-tree-sitter-mode))
(use-package tree-sitter-langs
  :defer t
  :after tree-sitter
  :straight (:build t))

(use-package emacsql-psql
  :defer t
  :after (emacsql)
  :straight (:build t))

(with-eval-after-load 'emacsql
  (dqv/major-leader-key
    :keymaps 'emacs-lisp-mode-map
    :packages '(emacsql)
    "E" #'emacsql-fix-vector-indentation))

(use-package flycheck
  :straight (:build t)
  :defer t
  :init
  (global-flycheck-mode)
  :config
  (setq flycheck-emacs-lisp-load-path 'inherit)

  ;; Rerunning checks on every newline is a mote excessive.
  (delq 'new-line flycheck-check-syntax-automatically)
  ;; And don’t recheck on idle as often
  (setq flycheck-idle-change-delay 2.0)

  ;; For the above functionality, check syntax in a buffer that you
  ;; switched to on briefly. This allows “refreshing” the syntax check
  ;; state for several buffers quickly after e.g. changing a config
  ;; file.
  (setq flycheck-buffer-switch-check-intermediate-buffers t)

  ;; Display errors a little quicker (default is 0.9s)
  (setq flycheck-display-errors-delay 0.2))

(use-package flycheck-popup-tip
  :straight (:build t)
  :after (flycheck evil)
  :hook (flycheck-mode . flycheck-popup-tip-mode)
  :config
  (setq flycheck-popup-tip-error-prefix "X ")
  (with-eval-after-load 'evil
    (add-hook 'evil-insert-state-entry-hook
              #'flycheck-popup-tip-delete-popup)
    (add-hook 'evil-replace-state-entry-hook
              #'flycheck-popup-tip-delete-popup)))

(use-package flycheck-posframe
  :straight (:build t)
  :hook (flycheck-mode . flycheck-posframe-mode)
  :config
  (setq flycheck-posframe-warning-prefix "! "
        flycheck-posframe-info-prefix    "··· "
        flycheck-posframe-error-prefix   "X "))

(use-package langtool
  :defer t
  :straight (:build t)
  :commands (langtool-check
             langtool-check-done
             langtool-show-message-at-point
             langtool-correct-buffer)
  :custom
  (langtool-default-language "en-US")
  (langtool-mother-tongue "fr")
  :config
  (setq langtool-java-classpath (string-join '("/usr/share/languagetool"
                                               "/usr/share/java/languagetool/*")
                                             ":"))
  ;;:general
  ;; (dqv/leader-key
  ;;   :packages 'langtool
  ;;   :infix "l"
  ;;   ""  '(:ignore t :which-key "LangTool")
  ;;   "B" #'langtool-correct-buffer
  ;;   "b" #'langtool-check-buffer
  ;;   "c" #'langtool-check
  ;;   "d" #'langtool-check-done
  ;;   "l" #'langtool-switch-default-language
  ;;   "p" #'langtool-show-message-at-point)
)

(use-package writegood-mode
  :defer t
  :straight (:build t)
  :hook org-mode latex-mode
  :general
  (dqv/major-leader-key
    :keymaps 'writegood-mode-map
    "g" #'writegood-grade-level
    "r" #'writegood-reading-ease))

(use-package ispell
  :if (executable-find "aspell")
  :defer t
  :straight (:type built-in)
  :config
  (add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_EXAMPLE" . "#\\+END_EXAMPLE"))
  (setq ispell-program-name "aspell"
        ispell-extra-args   '("--sug-mode=ultra" "--run-together")
        ispell-aspell-dict-dir (ispell-get-aspell-config-value "dict-dir")
        ispell-aspell-data-dir (ispell-get-aspell-config-value "data-dir")
        ispell-personal-dictionary (expand-file-name (concat "ispell/" ispell-dictionary ".pws")
                                                     user-emacs-directory)))

(use-package flyspell
  :defer t
  :straight (:type built-in)
  :ghook 'org-mode 'markdown-mode 'TeX-mode
  :init
  (defhydra flyspell-hydra ()
    "
Spell Commands^^           Add To Dictionary^^              Other
--------------^^---------- -----------------^^------------- -----^^---------------------------
[_b_] check whole buffer   [_B_] add word to dict (buffer)  [_t_] toggle spell check
[_r_] check region         [_G_] add word to dict (global)  [_q_] exit
[_d_] change dictionary    [_S_] add word to dict (session) [_Q_] exit and disable spell check
[_n_] next error
[_c_] correct before point
[_s_] correct at point
"
    ("B" nil)
    ("b" flyspell-buffer)
    ("r" flyspell-region)
    ("d" ispell-change-dictionary)
    ("G" nil)
    ("n" flyspell-goto-next-error)
    ("c" flyspell-correct-wrapper)
    ("Q" flyspell-mode :exit t)
    ("q" nil :exit t)
    ("S" nil)
    ("s" flyspell-correct-at-point)
    ("t" nil))
  :config
  (provide 'ispell) ;; force loading ispell
  (setq flyspell-issue-welcome-flag nil
        flyspell-issue-message-flag nil))

(use-package flyspell-correct
  :defer t
  :straight (:build t)
  :general ([remap ispell-word] #'flyspell-correct-at-point)
  :config
  (require 'flyspell-correct-ivy nil t))

(use-package flyspell-correct-ivy
  :defer t
  :straight (:build t)
  :after flyspell-correct)

(use-package flyspell-lazy
  :defer t
  :straight (:build t)
  :after flyspell
  :config
  (setq flyspell-lazy-idle-seconds 1
        flyspell-lazy-window-idle-seconds 3)
  (flyspell-lazy-mode +1))

(use-package lsp-mode
  :defer t
  :straight (:build t)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((c-mode          . lsp-deferred)
         (c++-mode        . lsp-deferred)
         (html-mode       . lsp-deferred)
         (sh-mode         . lsp-deferred)
         (rustic-mode     . lsp-deferred)
         (json-mode     . lsp-deferred)
         (typescript-mode . lsp-deferred)
         (lsp-mode        . lsp-enable-which-key-integration)
         (lsp-mode        . lsp-ui-mode))
  :commands (lsp lsp-deferred)
  :custom
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-use-plist t)
  :config
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-tramp-connection "shellcheck")
                    :major-modes '(sh-mode)
                    :remote? t
                    :server-id 'shellcheck-remote)))

(use-package lsp-ui
  :after lsp
  :defer t
  :straight (:build t)
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable t)
  :general
  (dqv/major-leader-key
    :keymaps 'lsp-ui-peek-mode-map
    :packages 'lsp-ui
    "h" #'lsp-ui-pook--select-prev-file
    "j" #'lsp-ui-pook--select-next
    "k" #'lsp-ui-pook--select-prev
    "l" #'lsp-ui-pook--select-next-file))

(use-package lsp-ivy
  :straight (:build t)
  :defer t
  :after lsp
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :defer t
  :straight (:build t)
  :requires treemacs
  :config
  (treemacs-resize-icons 15))

(use-package exec-path-from-shell
  :defer t
  :straight (:build t)
  :init (exec-path-from-shell-initialize))

(use-package consult-lsp
  :defer t
  :after lsp
  :straight (:build t)
  :general
  (dqv/evil
    :keymaps 'lsp-mode-map
    [remap xref-find-apropos] #'consult-lsp-symbols))

(use-package dap-mode
  :after lsp
  :defer t
  :straight (:build t)
  :config
  (dap-ui-mode)
  (dap-ui-controls-mode 1)

  (require 'dap-lldb)
  (require 'dap-gdb-lldb)

  (dap-gdb-lldb-setup)
  (dap-register-debug-template
   "Rust::LLDB Run Configuration"
   (list :type "lldb"
         :request "launch"
         :name "LLDB::Run"
         :gdbpath "rust-lldb"
         :target nil
         :cwd nil)))

(defun my/local-tab-indent ()
  (setq-local indent-tabs-mode 1))

(add-hook 'makefile-mode-hook #'my/local-tab-indent)

(use-package caddyfile-mode
  :defer t
  :straight (:build t)
  :mode (("Caddyfile\\'" . caddyfile-mode)
         ("caddy\\.conf\\'" . caddyfile-mode)))

(use-package cmake-mode
  :defer t
  :straight (:build t))

(use-package company-cmake
  :straight (company-cmake :build t
                           :type git
                           :host github
                           :repo "purcell/company-cmake")
  :after cmake-mode
  :defer t)

(use-package cmake-font-lock
  :defer t
  :after cmake-mode
  :straight (:build t))

(use-package eldoc-cmake
  :straight (:build t)
  :defer t
  :after cmake-mode)

(use-package csv-mode
  :straight (:build t)
  :defer t
  :general
  (dqv/major-leader-key
    :keymaps 'csv-mode-map
    "a"  #'csv-align-fields
    "d"  #'csv-kill-fields
    "h"  #'csv-header-line
    "i"  #'csv-toggle-invisibility
    "n"  #'csv-forward-field
    "p"  #'csv-backward-field
    "r"  #'csv-reverse-region
    "s"  '(:ignore t :wk "sort")
    "sf" #'csv-sort-fields
    "sn" #'csv-sort-numeric-fields
    "so" #'csv-toggle-descending
    "t"  #'csv-transpose
    "u"  #'csv-unalign-fields
    "y"  '(:ignore t :wk yank)
    "yf" #'csv-yank-fields
    "yt" #'csv-yank-as-new-table))

(use-package dotenv-mode
  :defer t
  :straight (:build t))

(use-package gnuplot
  :straight (:build t)
  :defer t)

(use-package graphviz-dot-mode
  :defer t
  :straight (:build t)
  :after org
  :mode (("\\.diag\\'"      . graphviz-dot-mode)
         ("\\.blockdiag\\'" . graphviz-dot-mode)
         ("\\.nwdiag\\'"    . graphviz-dot-mode)
         ("\\.rackdiag\\'"  . graphviz-dot-mode)
         ("\\.dot\\'"       . graphviz-dot-mode)
         ("\\.gv\\'"        . graphviz-dot-mode))
  :init
  (setq graphviz-dot-indent-width tab-width)
  (with-eval-after-load 'org
      (defalias 'org-babel-execute:graphviz-dot #'org-babel-execute:dot)
      (add-to-list 'org-babel-load-languages '(dot . t))
      (require 'ob-dot)
      (setq org-src-lang-modes
            (append '(("dot" . graphviz-dot))
                    (delete '("dot" . fundamental) org-src-lang-modes))))

  :general
  (dqv/major-leader-key
    :keymaps 'graphviz-dot-mode-map
    "=" #'graphviz-dot-indent-graph
    "c" #'compile)
  :config
  (setq graphviz-dot-indent-width 4))

(use-package markdown-mode
  :defer t
  :straight t
  :mode
  (("\\.mkd\\'" . markdown-mode)
   ("\\.mdk\\'" . markdown-mode)
   ("\\.mdx\\'" . markdown-mode))
  :hook (markdown-mode . orgtbl-mode)
  :hook (markdown-mode . visual-line-mode)
  :general
  (dqv/evil
    :keymaps 'markdown-mode-map
    :packages '(markdown-mode evil)
    "M-RET" #'markdown-insert-list-item
    "M-c"   #'markdown-promote
    "M-t"   #'markdown-move-down
    "M-s"   #'markdown-move-up
    "M-r"   #'markdown-demote
    "t"     #'evil-next-visual-line
    "s"     #'evil-previous-visual-line)
  (dqv/major-leader-key
    :keymaps 'markdown-mode-map
    :packages 'markdown-mode
    "{"   #'markdown-backward-paragraph
    "}"   #'markdown-forward-paragraph
    "]"   #'markdown-complete
    ">"   #'markdown-indent-region
    "»"   #'markdown-indent-region
    "<"   #'markdown-outdent-region
    "«"   #'markdown-outdent-region
    "n"   #'markdown-next-link
    "p"   #'markdown-previous-link
    "f"   #'markdown-follow-thing-at-point
    "k"   #'markdown-kill-thing-at-point
    "c"   '(:ignore t :which-key "command")
    "c]"  #'markdown-complete-buffer
    "cc"  #'markdown-check-refs
    "ce"  #'markdown-export
    "cm"  #'markdown-other-window
    "cn"  #'markdown-cleanup-list-numbers
    "co"  #'markdown-open
    "cp"  #'markdown-preview
    "cv"  #'markdown-export-and-preview
    "cw"  #'markdown-kill-ring-save
    "h"   '(:ignore t :which-key "headings")
    "hi"  #'markdown-insert-header-dwim
    "hI"  #'markdown-insert-header-setext-dwim
    "h1"  #'markdown-insert-header-atx-1
    "h2"  #'markdown-insert-header-atx-2
    "h3"  #'markdown-insert-header-atx-3
    "h4"  #'markdown-insert-header-atx-4
    "h5"  #'markdown-insert-header-atx-5
    "h6"  #'markdown-insert-header-atx-6
    "h!"  #'markdown-insert-header-setext-1
    "h@"  #'markdown-insert-header-setext-2
    "i"   '(:ignore t :which-key "insert")
    "i-"  #'markdown-insert-hr
    "if"  #'markdown-insert-footnote
    "ii"  #'markdown-insert-image
    "il"  #'markdown-insert-link
    "it"  #'markdown-insert-table
    "iw"  #'markdown-insert-wiki-link
    "l"   '(:ignore t :which-key "lists")
    "li"  #'markdown-insert-list-item
    "T"   '(:ignore t :which-key "toggle")
    "Ti"  #'markdown-toggle-inline-images
    "Tu"  #'markdown-toggle-url-hiding
    "Tm"  #'markdown-toggle-markup-hiding
    "Tt"  #'markdown-toggle-gfm-checkbox
    "Tw"  #'markdown-toggle-wiki-links
    "t"   '(:ignore t :which-key "table")
    "tc"  #'markdown-table-move-column-left
    "tt"  #'markdown-table-move-row-down
    "ts"  #'markdown-table-move-row-up
    "tr"  #'markdown-table-move-column-right
    "ts"  #'markdown-table-sort-lines
    "tC"  #'markdown-table-convert-region
    "tt"  #'markdown-table-transpose
    "td"  '(:ignore t :which-key "delete")
    "tdc" #'markdown-table-delete-column
    "tdr" #'markdown-table-delete-row
    "ti"  '(:ignore t :which-key "insert")
    "tic" #'markdown-table-insert-column
    "tir" #'markdown-table-insert-row
    "x"   '(:ignore t :which-key "text")
    "xb"  #'markdown-insert-bold
    "xB"  #'markdown-insert-gfm-checkbox
    "xc"  #'markdown-insert-code
    "xC"  #'markdown-insert-gfm-code-block
    "xi"  #'markdown-insert-italic
    "xk"  #'markdown-insert-kbd
    "xp"  #'markdown-insert-pre
    "xP"  #'markdown-pre-region
    "xs"  #'markdown-insert-strike-through
    "xq"  #'markdown-blockquote-region)
  :config
  (setq markdown-fontify-code-blocks-natively t))

(use-package gh-md
  :defer t
  :after markdown-mode
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :packages 'gh-md
    :keymaps 'markdown-mode-map
    "cr" #'gh-md-render-buffer))

(use-package ox-gfm
  :straight (:build t)
  :defer t
  :after (org ox))

(use-package mdc-mode
  :defer t
  :after markdown-mode
  :straight (mdc-mode :type git
                      :host github
                      :repo "Phundrak/mdc-mode"
                      :build t))

(use-package markdown-toc
  :defer t
  :after markdown-mode
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :packages 'markdown-toc
    :keymaps 'markdown-mode-map
    "iT" #'markdown-toc-generate-toc))

(use-package vmd-mode
  :defer t
  :after markdown-mode
  :straight (:build t)
  :custom ((vmd-binary-path (executable-find "vmd")))
  :general
  (dqv/major-leader-key
    :packages 'vmd-mode
    :keymaps 'markdown-mode-map
    "cP" #'vmd-mode))

(use-package edit-indirect
  :straight (:build t)
  :defer t)

(use-package nginx-mode
  :straight (:build t)
  :defer t)

(use-package company-nginx
  :straight (company-nginx :build t
                           :type git
                           :host github
                           :repo "emacsmirror/company-nginx")
  :defer t
  :config
  (add-hook 'nginx-mode-hook (lambda ()
                               (add-to-list 'company-backends #'company-nginx))))

(use-package pkgbuild-mode
  :straight (:build t)
  :defer t
  :general
  (dqv/major-leader-key
    :keymaps 'pkgbuild-mode-map
    "c"  #'pkgbuild-syntax-check
    "i"  #'pkgbuild-initialize
    "I"  #'pkgbuild-increase-release-tag
    "m"  #'pkgbuild-makepkg
    "u"  '(:ignore :wk "update")
    "us" #'pkgbuild-update-sums-line
    "uS" #'pkgbuild-update-srcinfo))

(use-package plantuml-mode
  :defer t
  :straight (:build t)
  :mode ("\\.\\(pum\\|puml\\)\\'" . plantuml-mode)
  :after ob
  :init
  (add-to-list 'org-babel-load-languages '(plantuml . t))
  :general
  (dqv/major-leader-key
   :keymaps 'plantuml-mode-map
   :packages 'plantuml-mode
   "c"  '(:ignore t :which-key "compile")
   "cc" #'plantuml-preview
   "co" #'plantuml-set-output-type)
  :config
  (setq plantuml-default-exec-mode 'jar
        plantuml-jar-path "~/.local/bin/plantuml.jar"
        org-plantuml-jar-path "~/.local/bin/plantuml.jar"))

(use-package fish-mode
  :straight (:build t)
  :defer t)

(use-package shell
  :defer t
  :straight (:type built-in)
  :hook (shell-mode . tree-sitter-hl-mode))

(use-package solidity-mode
  :defer t
  :straight (:build t)
  :config
  (csetq solidity-comment-style 'slash))

(use-package ssh-config-mode
  :defer t
  :straight (:build t))

(use-package systemd
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :keymaps '(systemd-mode-map)
    "d" '(systemd-doc-directives :which-key "directives manpage")
    "o" 'systemd-doc-open))

(use-package json-mode
  :straight (:build t)
  :mode "\\.json$"
  :config
  (add-to-list 'flycheck-disabled-checkers 'json-python-json))

(use-package toml-mode
  :straight (:build t)
  :defer t
  :mode "/\\(Cargo.lock\\|\\.cargo/config\\)\\'")

(use-package yaml-mode
  :defer t
  :straight (:build t)
  :mode "\\.yml\\'"
  :mode "\\.yaml\\'")

(use-package move-mode
  :straight (:build t :host github :repo "amnn/move-mode" :branch "main"))

(use-package cc-mode
  :straight (:type built-in)
  :defer t
  :init
  (put 'c-c++-backend 'safe-local-variable 'symbolp)
  (add-hook 'c-mode-hook #'tree-sitter-hl-mode)
  (add-hook 'c++-mode-hook #'tree-sitter-hl-mode)
  :config
  (require 'compile)
  :general
  (dqv/underfine
    :keymaps '(c-mode-map c++-mode-map)
    ";" nil)
  (dqv/major-leader-key
   :keymaps '(c-mode-map c++-mode-map)
   "l"  '(:keymap lsp-command-map :which-key "lsp" :package lsp-mode))
  (dqv/evil
   :keymaps '(c-mode-map c++-mode-map)
   "ga" #'projectile-find-other-file
   "gA" #'projectile-find-other-file-other-window))

(use-package clang-format+
  :straight (:build t)
  :defer t
  :init
  (add-hook 'c-mode-common-hook #'clang-format+-mode))

(use-package modern-cpp-font-lock
  :straight (:build t)
  :defer t
  :hook (c++-mode . modern-c++-font-lock-mode))

(use-package lisp-mode
  :straight (:type built-in)
  :defer t
  :after parinfer-rust-mode
  :hook (lisp-mode . parinfer-rust-mode)
  :config
  (put 'defcommand 'lisp-indent-function 'defun)
  (setq inferior-lisp-program "/usr/bin/sbcl --noinform"))

(use-package stumpwm-mode
  :straight (:build t)
  :defer t
  :hook lisp-mode
  :config
  (dqv/major-leader-key
   :keymaps 'stumpwm-mode-map
   :packages 'stumpwm-mode
   "e"  '(:ignore t :which-key "eval")
   "ee" #'stumpwm-eval-last-sexp
   "ed" #'stumpwm-eval-defun
   "er" #'stumpwm-eval-region))

(use-package sly
  :defer t
  :straight (:build t))

(use-package dart-mode
  :straight (:build t)
  :defer t
  :hook (dart-mode . lsp-deferred)
  :mode "\\.dart\\'")

(use-package lsp-dart
  :straight (:build t)
  :defer t)

(use-package eldoc
  :defer t
  :after company
  :init
  (eldoc-add-command 'company-complete-selection
                     'company-complete-common
                     'company-capf
                     'company-abort))

(add-hook 'emacs-lisp-mode-hook (lambda () (smartparens-mode -1)))

(use-package elisp-demos
  :defer t
  :straight (:build t)
  :config
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

(use-package epdh
  :straight (epdh :type git
                  :host github
                  :repo "alphapapa/emacs-package-dev-handbook"
                  :build t)
  :defer t)

(dqv/major-leader-key
 :keymaps 'emacs-lisp-mode-map
 "'"   #'ielm
 "c"   '(emacs-lisp-byte-compile :which-key "Byte compile")
 "C"   '(:ignore t :which-key "checkdoc")
 "Cc"  #'checkdoc
 "Cs"  #'checkdoc-start
 "e"   '(:ignore t :which-key "eval")
 "eb"  #'eval-buffer
 "ed"  #'eval-defun
 "ee"  #'eval-last-sexp
 "er"  #'eval-region

 "h"   '(:ignore t :which-key "help")
 "hh"  #'helpful-at-point

 "t"   '(:ignore t :wk "toggle")
 "tP"  '(:ignore t :wk "parinfer")
 "tPs" #'parinfer-rust-switch-mode
 "tPd" #'parinfer-rust-mode-disable
 "tPp" #'parinfer-rust-toggle-paren-mode)

(use-package package-lint
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :keymaps 'emacs-lisp-mode-map
    :packages 'package-lint
    "l" #'package-lint-current-buffer))

(use-package cask-mode
  :defer t
  :straight (:build t))

(use-package eask-api
  :defer t
  :straight (eask-api :type git
                      :host github
                      :repo "emacs-eask/eask-api"))

(use-package eask-mode
  :defer t
  :straight (eask-mode :type git
                       :host github
                       :repo "emacs-eask/eask-mode"))

(use-package python
  :defer t
  :straight (:build t)
  :after ob
  :mode (("SConstruct\\'" . python-mode)
         ("SConscript\\'" . python-mode)
         ("[./]flake8\\'" . conf-mode)
         ("/Pipfile\\'"   . conf-mode))
  :init
  (setq python-indent-guess-indent-offset-verbose nil)
  (add-hook 'python-mode-local-vars-hook #'lsp)
  :config
  (setq python-indent-guess-indent-offset-verbose nil)
  (when (and (executable-find "python3")
           (string= python-shell-interpreter "python"))
    (setq python-shell-interpreter "python3")))

(use-package pytest
  :defer t
  :straight (:build t)
  :commands (pytest-one
             pytest-pdb-one
             pytest-all
             pytest-pdb-all
             pytest-last-failed
             pytest-pdb-last-failed
             pytest-module
             pytest-pdb-module)
  :config
  (add-to-list 'pytest-project-root-files "setup.cfg")
  :general
  (dqv/major-leader-key
   :keymaps 'python-mode-map
   :infix "t"
   :packages 'pytest
   ""  '(:ignore t :which-key "test")
   "a" #'python-pytest
   "f" #'python-pytest-file-dwim
   "F" #'python-pytest-file
   "t" #'python-pytest-function-dwim
   "T" #'python-pytest-function
   "r" #'python-pytest-repeat
   "p" #'python-pytest-dispatch))

(use-package poetry
  :defer t
  :straight (:build t)
  :commands (poetry-venv-toggle
             poetry-tracking-mode)
  :config
  (setq poetry-tracking-strategy 'switch-buffer)
  (add-hook 'python-mode-hook #'poetry-tracking-mode))

(use-package pip-requirements
  :defer t
  :straight (:build t))

(use-package pippel
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
   :keymaps 'python-mode-map
   :packages 'pippel
   "P" #'pippel-list-packages))

(use-package pipenv
  :defer t
  :straight (:build t)
  :commands (pipenv-activate
             pipenv-deactivate
             pipenv-shell
             pipenv-open
             pipenv-install
             pipenv-uninstall)
  :hook (python-mode . pipenv-mode)
  :init (setq pipenv-with-projectile nil)
  :general
  (dqv/major-leader-key
   :keymaps 'python-mode-map
   :packages 'pipenv
   :infix "e"
   ""  '(:ignore t :which-key "pipenv")
   "a" #'pipenv-activate
   "d" #'pipenv-deactivate
   "i" #'pipenv-install
   "l" #'pipenv-lock
   "o" #'pipenv-open
   "r" #'pipenv-run
   "s" #'pipenv-shell
   "u" #'pipenv-uninstall))

(use-package pyenv
  :defer t
  :straight (:build t)
  :config
  (add-hook 'python-mode-hook #'pyenv-track-virtualenv)
  (add-to-list 'global-mode-string
               '(pyenv-virtual-env-name (" venv:" pyenv-virtual-env-name " "))
               'append))

(use-package pyenv-mode
  :defer t
  :after python
  :straight (:build t)
  :if (executable-find "pyenv")
  :commands (pyenv-mode-versions)
  :general
  (dqv/major-leader-key
    :packages 'pyenv-mode
    :keymaps 'python-mode-map
    :infix "v"
    "u" #'pyenv-mode-unset
    "s" #'pyenv-mode-set))

(use-package pyimport
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
    :packages 'pyimport
    :keymaps 'python-mode-map
    :infix "i"
    ""  '(:ignore t :which-key "imports")
    "i" #'pyimport-insert-missing
    "r" #'pyimport-remove-unused))

(use-package py-isort
  :defer t
  :straight (:build t)
  :general
  (dqv/major-leader-key
   :keymaps 'python-mode-map
   :packages 'py-isort
   :infix "i"
   ""  '(:ignore t :which-key "imports")
   "s" #'py-isort-buffer
   "R" #'py-isort-region))

(use-package counsel-pydoc
  :defer t
  :straight (:build t))

(use-package sphinx-doc
  :defer t
  :straight (:build t)
  :init
  (add-hook 'python-mode-hook #'sphinx-doc-mode)
  :general
  (dqv/major-leader-key
   :keymaps 'python-mode-map
   :packages 'sphinx-doc
   :infix "S"
   ""  '(:ignore t :which-key "sphinx-doc")
   "e" #'sphinx-doc-mode
   "d" #'sphinx-doc))

(use-package cython-mode
  :defer t
  :straight (:build t)
  :mode "\\.p\\(yx\\|x[di]\\)\\'"
  :config
  (setq cython-default-compile-format "cython -a %s")
  :general
  (dqv/major-leader-key
   :keymaps 'cython-mode-map
   :packages 'cython-mode
   :infix "c"
   ""  '(:ignore t :which-key "cython")
   "c" #'cython-compile))

(use-package flycheck-cython
  :defer t
  :straight (:build t)
  :after cython-mode)

(use-package blacken
  :defer t
  :straight (:build t)
  :init
  (add-hook 'python-mode-hook #'blacken-mode))

(use-package lsp-pyright
  :after lsp-mode
  :defer t
  :straight (:buidl t))

(use-package rustic
  :defer t
  :straight (:build t)
  :mode ("\\.rs\\'" . rustic-mode)
  :hook (rustic-mode-local-vars . rustic-setup-lsp)
  :hook (rustic-mode . lsp-deferred)
  :init
  (with-eval-after-load 'org
    (defalias 'org-babel-execute:rust #'org-babel-execute:rustic)
    (add-to-list 'org-src-lang-modes '("rust" . rustic)))
  (setq rustic-lsp-client 'lsp-mode)
  (add-hook 'rustic-mode-hook #'tree-sitter-hl-mode)
  :general
  (general-define-key
   :keymaps 'rustic-mode-map
   :packages 'lsp
   "M-t" #'lsp-ui-imenu
   "M-?" #'lsp-find-references)
  (dqv/major-leader-key
   :keymaps 'rustic-mode-map
   :packages 'rustic
   "b"  '(:ignore t :which-key "build")
   "bb" #'rustic-cargo-build
   "bB" #'rustic-cargo-bench
   "bc" #'rustic-cargo-check
   "bC" #'rustic-cargo-clippy
   "bd" #'rustic-cargo-doc
   "bf" #'rustic-cargo-fmt
   "bn" #'rustic-cargo-new
   "bo" #'rustic-cargo-outdated
   "br" #'rustic-cargo-run
   "l"  '(:ignore t :which-key "lsp")
   "la" #'lsp-execute-code-action
   "lr" #'lsp-rename
   "lq" #'lsp-workspace-restart
   "lQ" #'lsp-workspace-shutdown
   "ls" #'lsp-rust-analyzer-status
   "t"  '(:ignore t :which-key "cargo test")
   "ta" #'rustic-cargo-test
   "tt" #'rustic-cargo-current-test)
  :config
  (setq rustic-indent-method-chain    t
        rustic-babel-format-src-block nil
        rustic-format-trigger         nil)
  (remove-hook 'rustic-mode-hook #'flycheck-mode)
  (remove-hook 'rustic-mode-hook #'flymake-mode-off)
  (remove-hook 'rustic-mode-hook #'rustic-setup-lsp))

(use-package emmet-mode
  :straight (:build t)
  :defer t
  :hook ((css-mode  . emmet-mode)
         (html-mode . emmet-mode)
         (web-mode  . emmet-mode)
         (sass-mode . emmet-mode)
         (scss-mode . emmet-mode)
         (web-mode  . emmet-mode))
  :config
  (general-define-key
   :keymaps 'emmet-mode-keymap
   "M-RET" #'emmet-expand-yas)
  (dqv/major-leader-key
    :keymaps 'web-mode-map
    :packages '(web-mode emmet-mode)
    "e" '(:ignore t :which-key "emmet")
    "ee" #'emmet-expand-line
    "ep" #'emmet-preview
    "eP" #'emmet-preview-mode
    "ew" #'emmet-wrap-with-markup))

(use-package impatient-mode
  :straight (:build t)
  :defer t)

(use-package web-mode
  :defer t
  :straight (:build t)
  :hook html-mode
  :hook (web-mode . prettier-js-mode)
  :hook (web-mode . lsp-deferred)
  :mode (("\\.phtml\\'"      . web-mode)
         ("\\.tpl\\.php\\'"  . web-mode)
         ("\\.twig\\'"       . web-mode)
         ("\\.xml\\'"        . web-mode)
         ("\\.html\\'"       . web-mode)
         ("\\.htm\\'"        . web-mode)
         ("\\.[gj]sp\\'"     . web-mode)
         ("\\.as[cp]x?\\'"   . web-mode)
         ("\\.eex\\'"        . web-mode)
         ("\\.erb\\'"        . web-mode)
         ("\\.mustache\\'"   . web-mode)
         ("\\.handlebars\\'" . web-mode)
         ("\\.hbs\\'"        . web-mode)
         ("\\.eco\\'"        . web-mode)
         ("\\.ejs\\'"        . web-mode)
         ("\\.svelte\\'"     . web-mode)
         ("\\.ctp\\'"        . web-mode)
         ("\\.djhtml\\'"     . web-mode)
         ("\\.vue\\'"        . web-mode))
  :config
  (csetq web-mode-markup-indent-offset 2
         web-mode-code-indent-offset   2
         web-mode-css-indent-offset    2
         web-mode-style-padding        0
         web-mode-script-padding       0)
  :general
  (dqv/major-leader-key
   :keymaps 'web-mode-map
   :packages 'web-mode
   "="  '(:ignore t :which-key "format")
   "E"  '(:ignore t :which-key "errors")
   "El" #'web-mode-dom-errors-show
   "gb" #'web-mode-element-beginning
   "g"  '(:ignore t :which-key "goto")
   "gc" #'web-mode-element-child
   "gp" #'web-mode-element-parent
   "gs" #'web-mode-element-sibling-next
   "h"  '(:ignore t :which-key "dom")
   "hp" #'web-mode-dom-xpath
   "r"  '(:ignore t :which-key "refactor")
   "rc" #'web-mode-element-clone
   "rd" #'web-mode-element-vanish
   "rk" #'web-mode-element-kill
   "rr" #'web-mode-element-rename
   "rw" #'web-mode-element-wrap
   "z"  #'web-mode-fold-or-unfold)
  (dqv/major-leader-key
    :keymaps 'web-mode-map
    :packages '(lsp-mode web-mode)
    "l" '(:keymap lsp-command-map :which-key "lsp")))

(use-package company-web
  :defer t
  :straight (:build t)
  :after (emmet-mode web-mode))

(use-package css-mode
  :defer t
  :straight (:type built-in)
  :hook (css-mode . smartparens-mode)
  :hook (css-mode . lsp-deferred)
  :hook (scss-mode . prettier-js-mode)
  :init
  (put 'css-indent-offset 'safe-local-variable #'integerp)
  :general
  (dqv/major-leader-key
    :keymaps 'css-mode-map
    :packages 'css-mode
    "=" '(:ignore :wk "format")
    "g" '(:ignore :wk "goto")))

(use-package scss-mode
  :straight (:build t)
  :hook (scss-mode . smartparens-mode)
  :hook (scss-mode . lsp-deferred)
  :hook (scss-mode . prettier-js-mode)
  :defer t
  :mode "\\.scss\\'")

(use-package counsel-css
  :straight (:build t)
  :defer t
  :init
  (cl-loop for (mode-map . mode-hook) in '((css-mode-map  . css-mode-hook)
                                           (scss-mode-map . scss-mode-hook))
           do (add-hook mode-hook #'counsel-css-imenu-setup)
           (dqv/major-leader-key
            :keymaps mode-map
            "gh" #'counsel-css)))

(use-package less-css-mode
  :straight  (:type built-in)
  :defer t
  :mode "\\.less\\'"
  :hook (less-css-mode . smartparens-mode)
  :hook (less-css-mode . lsp-deferred)
  :hook (less-css-mode . prettier-js-mode))

(use-package rjsx-mode
  :defer t
  :straight (:build t)
  :after compile
  :mode "\\.[mc]?jsx?\\'"
  :mode "\\.es6\\'"
  :mode "\\.pac\\'"
  :interpreter "node"
  :hook (rjsx-mode . rainbow-delimiters-mode)
  :hook (rjsx-mode . lsp-deferred)
  :init
  (add-to-list 'compilation-error-regexp-alist 'node)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(node "^[[:blank:]]*at \\(.*(\\|\\)\\(.+?\\):\\([[:digit:]]+\\):\\([[:digit:]]+\\)"
                      2 3 4))
  :general
  (dqv/major-leader-key
    :keymaps 'rjsx-mode-map
    :infix "a"
    ""  '(:keymap lsp-command-map :which-key "lsp")
    "=" '(:ignore t :wk "format")
    "a" '(:ignore t :which-key "actions"))
  :config
  (setq js-chain-indent                  t
        js2-basic-offset                 2
        ;; ignore shebangs
        js2-skip-preprocessor-directives t
        ;; Flycheck handles this already
        js2-mode-show-parse-errors       nil
        js2-mode-show-strict-warnings    nil
        ;; conflicting with eslint, Flycheck already handles this
        js2-strict-missing-semi-warning  nil
        js2-highlight-level              3
        js2-idle-timer-delay             0.15))

(use-package js2-refactor
  :defer t
  :straight (:build t)
  :after (js2-mode rjsx-mode)
  :hook (js2-mode . js2-refactor-mode)
  :hook (rjsx-mode . js2-refactor-mode))

(use-package npm-transient
  :defer t
  :straight (npm-transient :build t
                           :type git
                           :host github
                           :repo "Phundrak/npm-transient"))
  ;; :general
  ;; (dqv/major-leader-key
  ;;   :packages '(npm-transient rjsx-mode web-mode)
  ;;   :keymaps '(rjsx-mode-map web-mode-map)
  ;;   "n" #'npm-transient))

(use-package prettier-js
  :defer t
  :straight (:build t)
  :after (rjsx-mode web-mode typescript-mode)
  :hook ((rjsx-mode typescript-mode) . prettier-js-mode)
  :config
  (csetq prettier-js-args '("--single-quote" "--jsx-single-quote")))

(use-package typescript-mode
  :defer t
  :straight (:build t)
  :hook (typescript-mode     . rainbow-delimiters-mode)
  :hook (typescript-mode     . lsp-deferred)
  :hook (typescript-tsx-mode . rainbow-delimiters-mode)
  :hook (typescript-tsx-mode . lsp-deferred)
  :commands typescript-tsx-mode
  :after flycheck
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
  :general
  (dqv/major-leader-key
    :packages 'lsp
    :keymaps '(typescript-mode-map typescript-tsx-mode-map)
    :infix "a"
    ""  '(:keymap lsp-command-map :which-key "lsp")
    "=" '(:ignore t :wk "format")
    "a" '(:ignore t :which-key "actions"))
  (dqv/major-leader-key
    :packages 'typescript-mode
    :keymaps '(typescript-mode-map typescript-tsx-mode-map)
    "n" '(:keymap npm-mode-command-keymap :which-key "npm"))
  :config
  (setq typescript-indent-level 2)
  (with-eval-after-load 'flycheck
    (flycheck-add-mode 'javascript-eslint 'web-mode)
    (flycheck-add-mode 'javascript-eslint 'typescript-mode)
    (flycheck-add-mode 'javascript-eslint 'typescript-tsx-mode)
    (flycheck-add-mode 'typescript-tslint 'typescript-tsx-mode))
  (when (fboundp 'web-mode)
    (define-derived-mode typescript-tsx-mode web-mode "TypeScript-TSX"))
  (autoload 'js2-line-break "js2-mode" nil t))

(use-package tide
  :defer t
  :straight (:build t)
  :hook (tide-mode . tide-hl-identifier-mode)
  :config
  (setq tide-completion-detailed              t
        tide-always-show-documentation        t
        tide-server-may-response-length       524288
        tide-completion-setup-company-backend nil)

  (advice-add #'tide-setup :after #'eldoc-mode)

  :general
  (dqv/major-leader-key
    :keymaps 'tide-mode-map
    "R"   #'tide-restart-server
    "f"   #'tide-format
    "rrs" #'tide-rename-symbol
    "roi" #'tide-organize-imports))

(use-package zig-mode
  :defer t
  :straight (:build t)
  :after flycheck
  :hook (zig-mode . lsp-deferred)
  :config
  ;; This is from DoomEmacs
  (flycheck-define-checker zig
    "A zig syntax checker using the zig-fmt interpreter."
    :command ("zig" "fmt" (eval (buffer-file-name)))
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": error: " (mesage) line-end))
    :modes zig-mode)
  (add-to-list 'flycheck-checkers 'zig)
  :general
  (dqv/major-leader-key
    :packages 'zig-mode
    :keymaps 'zig-mode-map
    "c" #'zig-compile
    "f" #'zig-format-buffer
    "r" #'zig-run
    "t" #'zig-test-buffer))

(use-package git-gutter-fringe
  :straight (:build t)
  :hook ((prog-mode     . git-gutter-mode)
         (org-mode      . git-gutter-mode)
         (markdown-mode . git-gutter-mode)
         (latex-mode    . git-gutter-mode))
  :config
  (setq git-gutter:update-interval 2)
  ;; These characters are used in terminal mode
  (setq git-gutter:modified-sign "≡")
  (setq git-gutter:added-sign "≡")
  (setq git-gutter:deleted-sign "≡")
  (set-face-foreground 'git-gutter:added "LightGreen")
  (set-face-foreground 'git-gutter:modified "LightGoldenrod")
  (set-face-foreground 'git-gutter:deleted "LightCoral"))

(use-package all-the-icons
  :defer t
  :straight t)

(defun prog-mode-set-symbols-alist ()
  (setq prettify-symbols-alist '(("lambda"  . ?λ)
                                 ("null"    . ?∅)
                                 ("NULL"    . ?∅)))
  (prettify-symbols-mode 1))

(add-hook 'prog-mode-hook #'prog-mode-set-symbols-alist)

(setq-default lisp-prettify-symbols-alist '(("lambda"    . ?λ)
                                            ("defun"     . ?𝑓)
                                            ("defvar"    . ?𝑣)
                                            ("defcustom" . ?𝑐)
                                            ("defconst"  . ?𝐶)))

(defun lisp-mode-prettify ()
  (setq prettify-symbols-alist lisp-prettify-symbols-alist)
  (prettify-symbols-mode -1)
  (prettify-symbols-mode 1))

(dolist (lang '(emacs-lisp lisp common-lisp scheme))
  (add-hook (intern (format "%S-mode-hook" lang))
            #'lisp-mode-prettify))

(setq prettify-symbols-unprettify-at-point t)

(use-package ligature
  :straight (ligature :type git
                      :host github
                      :repo "mickeynp/ligature.el"
                      :build t)
  :config
  (ligature-set-ligatures 't
                          '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures '(eww-mode org-mode elfeed-show-mode)
                          '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode
                          '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                            ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                            "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                            "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                            "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                            "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                            "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                            "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                            ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                            "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                            "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                            "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                            "\\\\" "://"))
  (global-ligature-mode t))

(use-package doom-modeline
  :straight (:build t)
  :defer t
  :init (doom-modeline-mode 1)
  :config
  (csetq doom-modeline-height 15
         doom-modeline-enable-word-count t
         doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)
         doom-modeline-env-version t))

(use-package valign
  :defer t
  :straight (:build t)
  :after (org markdown-mode)
  ;; :hook ((org-mode markdown-mode) . valign-mode)
  :custom ((valign-fancy-bar t)))

(use-package redacted-mode
  :defer t
  :straight (secret-mode :build t
                         :type git
                         :host github
                         :repo "bkaestner/redacted.el"))

(use-package solaire-mode
  :defer t
  :straight (:build t)
  :init (solaire-global-mode +1))

(use-package modus-themes
  :straight (:build t)
  :commands (Appearance_/load-operandi load-operandi )
  :init
  (defun load-operandi ()
    (interactive)
    (progn
      (reset-themes)
      (load-theme 'modus-operandi t)
      (stylize-operandi)));end load-operandi
  :config
  (defun stylize-operandi ()
    (interactive)
    (progn
                                        ;tab-bar
      (set-face-attribute 'tab-bar nil :background "#ffffff" :foreground "#808080" :box '(:line-width 1 :color "#373b49" :style pressed-button))
      (set-face-attribute 'tab-bar-tab-inactive nil :background "#ffffff" :foreground "#808080" :underline nil :box '(:line-width 1 :color "#373b49" :style pressed-button))
      (set-face-attribute 'tab-bar-tab nil :background "#ffffff" :foreground "#a61fde" :width 'expanded :box  '(:line-width 1 :color "#373b49" :style pressed-button))
      (set-face-attribute 'fixed-pitch nil :font "Consolas" :height 140 :weight 'regular)
      (set-face-attribute 'all-the-icons-dired-dir-face nil :background "#ffffff" :foreground "#03163c")
      (set-face-attribute 'dired-filetype-execute nil :background "#ffffff" :foreground "#335ea8")
      (set-face-attribute 'dired-filetype-xml nil :background "#ffffff" :foreground "#a61fde")
      (set-face-attribute 'dired-filetype-js nil :background "#ffffff" :foreground "#a0132f" :weight 'normal)
      (set-face-attribute 'dired-filetype-common nil :background "#ffffff" :foreground "#EA0E0E")
      (set-face-attribute 'dired-filetype-image nil :background "#ffffff" :foreground "#650aae")
      (set-face-attribute 'dired-filetype-source nil :background "#ffffff" :foreground "#315b00")
      (set-face-attribute 'dired-filetype-link nil :background "#ffffff" :foreground "#005a5f")
      (set-face-attribute 'dired-filetype-plain nil :background "#ffffff" :foreground "#005f88")
      (set-face-attribute 'diredp-dir-name nil :background "#ffffff" :foreground "#03163c")
      (set-face-attribute 'dired-filetype-mytype nil :background "#ffffff" :foreground "#b5006a")
                                        ;font-lock
      (set-face-attribute 'font-lock-comment-face nil :background "#f3f3ff" :foreground "#5f6368")
                                        ;(set-face-attribute 'font-lock-function-name-face nil :background "#1b1d1e" :foreground "#5f6368")
      (set-face-attribute 'font-lock-builtin-face nil :background "#f3f3ff" :foreground "#8f0075")

      (set-face-attribute 'default nil :background "#ffffff")

                                        ;org-block
      (set-face-attribute 'org-document-title nil :background "#ffffff" :foreground "#093060" :height 230)
      (set-face-attribute 'org-block nil :background "#f3f3ff"  :foreground "#000000" :extend t)
      (set-face-attribute 'org-block-end-line nil :background "#ffffff" :foreground "#808080")
      (set-face-attribute 'org-block-begin-line nil :background "#ffffff" :foreground "#808080")
      (set-face-attribute 'org-level-1 nil :background "#ffffff" :foreground "#0a0a0a")
      (set-face-attribute 'org-level-2 nil :background "#ffffff" :foreground "#8f0075")
      (set-face-attribute 'org-level-3 nil :background "#ffffff" :foreground "#093060")
      (set-face-attribute 'org-level-4 nil :background "#ffffff" :foreground "#184034")
      (set-face-attribute 'org-meta-line nil :background "#ffffff" )
                                        ;(set-face-attribute 'org-level-2 nil :background "#ffffff" :foreground "#8f0075")
      (set-face-attribute 'org-meta-line nil :background "#ffffff" :foreground "#5f6368")
                                        ;(set-face-attribute 'org-code nil :background "#e8f1d4" :foreground "#0b0b0b")

                                        ;default
      (set-face-attribute 'region nil :background "#efefef" :foreground "#061229")
                                        ;(set-face-attribute 'highlight-parentheses-highlight nil :background "#e8f1d4" :foreground "#061229")
                                        ;show parens
      (set-face-attribute 'show-paren-match nil :background "#f8ddea" :foreground "#ba86ef" :inherit nil)
      (set-face-attribute 'show-paren-match-expression nil :background "#f8ddea" :foreground "#ba86ef" :inherit nil)
                                        ;webmode
      (set-face-attribute 'web-mode-html-attr-value-face nil :background "y" :foreground "#99bf52")
      (set-face-attribute 'web-mode-comment-face nil :background "#ffffff" :foreground "#608fb1")
      (set-face-attribute 'web-mode-html-attr-name-face nil :background "#ffffff" :foreground "#3c5be9")
      (set-face-attribute 'web-mode-style-face nil :background "#ffffff" :foreground "#a61fde")
      (set-face-attribute 'web-mode-variable-name-face nil :background "#ffffff" :foreground  "#3c5be9")
      (set-face-attribute 'web-mode-script-face nil :background "#ffffff" :foreground "#b77fdb" )
      (set-face-attribute 'web-mode-html-tag-face nil :background "#ffffff" )
      (set-face-attribute 'web-mode-current-element-highlight-face nil :background "#cfe8cf" )
      (set-face-attribute 'web-mode-current-column-highlight-face nil :background "#cfe8cf" :foreground "#242924")
      (set-face-attribute 'web-mode-html-tag-bracket-face nil :background "#ffffff" :foreground "#dc322f")
                                        ;hydra-posframe
      (set-face-attribute 'hydra-posframe-border-face nil :background "#ffffff"  :foreground "#ffffff")
      (set-face-attribute 'hydra-posframe-face nil :background "#ffffff"  :foreground "#242924")
                                        ; hydra faces
      (set-face-attribute 'pretty-hydra-toggle-off-face nil :background "#ffffff" :foreground "#770077")
      (set-face-attribute 'pretty-hydra-toggle-on-face nil :background "#ffffff" :foreground "#770077")
                                        ;rainbow-delimeters
                                        ;(set-face-attribute 'rainbow-delimiters-unmatched-face nil :background "#ffffff"  :foreground "#e6193c" )
                                        ;(set-face-attribute 'rainbow-delimiters-mismatched-face nil :background "#ffffff"  :foreground "#e619c3")
                                        ;company
                                        ;company background
      (set-face-attribute 'company-tooltip nil :background "#efefef"  :foreground "#000000" :inherit nil)
      (set-face-background 'company-tooltip "#efefef")
      (set-face-foreground 'company-tooltip "#000000")
      (setq pbg-swap '(background-color . "#efefef"))
      (setq pfg-swap '(foreground-color . "#000000"))
      (and (not (equal pbg-color pbg-swap)) (not (equal pfg-color pfg-swap))
           (progn
             (replace-element-in-list pbg-color pbg-swap  company-box-frame-parameters)
             (replace-element-in-list pfg-color pfg-swap  company-box-frame-parameters)
             ));end check frame swap loop
      (setq pbg-color '(background-color . "#efefef"))
      (setq pfg-color '(foreground-color . "#000000"))
      (set-face-attribute 'company-tooltip-common nil :background "#efefef"  :foreground "#a61fde" :inherit nil )
      (set-face-attribute 'company-box-candidate nil :background "#efefef"  :foreground "#ff6fff" :inherit nil)
      (set-face-attribute 'company-box-annotation nil :background "#efefef"  :foreground "#e0a3ff" :inherit nil)
      (set-face-attribute 'company-tooltip-common-selection t :background "#efefef"  :foreground "#a61fde" :inherit nil)
      (set-face-attribute 'company-box-selection nil :background "#dde3f4"  :foreground "#000000" :inherit nil )
      (set-face-attribute 'company-box-scrollbar t :background "#efefef" :foreground "#dde3f4" :inherit nil)
                                        ;neo
                                        ;(set-face-attribute 'neo-file-link-face nil :background "#fdf6e3" :foreground "#8D8D84")
                                        ;(set-face-attribute 'neo-dir-link-face nil :background "#fdf6e3" :foreground "#0000FF")
                                        ;(set-face-attribute 'neo-root-dir-face nil :background "#fdf6e3" :foreground "#BA36A5")
                                        ;(set-face-attribute 'neo-root-dir-face nil :background "#fdf6e3" :foreground "#fff")
                                        ;rainbow identifiers
      (set-face-attribute 'rainbow-identifiers-identifier-1 nil  :background "#ffffff" :foreground "#ff6fff")
      (set-face-attribute 'rainbow-identifiers-identifier-2 nil  :background "#ffffff" :foreground "#2C942C")
      (set-face-attribute 'rainbow-identifiers-identifier-3 nil  :background "#ffffff" :foreground "#b5006a")
      (set-face-attribute 'rainbow-identifiers-identifier-4 nil  :background "#ffffff" :foreground "#5B6268")
      (set-face-attribute 'rainbow-identifiers-identifier-5 nil  :background "#ffffff" :foreground "#0C4EA0")
      (set-face-attribute 'rainbow-identifiers-identifier-6 nil  :background "#ffffff" :foreground "#99bf52")
      (set-face-attribute 'rainbow-identifiers-identifier-7 nil  :background "#ffffff" :foreground "#a61fde")
      (set-face-attribute 'rainbow-identifiers-identifier-8 nil  :background "#ffffff" :foreground "#dc322f")
      (set-face-attribute 'rainbow-identifiers-identifier-9 nil  :background "#ffffff" :foreground "#00aa80")
      (set-face-attribute 'rainbow-identifiers-identifier-11 nil  :background "#ffffff" :foreground "#bbfc20")
      (set-face-attribute 'rainbow-identifiers-identifier-12 nil  :background "#ffffff" :foreground "#6c9ef8")
      (set-face-attribute 'rainbow-identifiers-identifier-13 nil  :background "#ffffff" :foreground "#dd8844")
      (set-face-attribute 'rainbow-identifiers-identifier-14 nil  :background "#ffffff" :foreground "#991613")
      (set-face-attribute 'rainbow-identifiers-identifier-15 nil  :background "#ffffff" :foreground "#242924")
      (setq zoom-window-mode-line-color "#8f0075")
                                        ;calendar
                                        ;(set-face-attribute 'cfw:face-title nil :background "#ffffff" :foreground "#bbfc20" :height 8 :weight 'bold)
      (set-face-attribute 'cfw:face-header nil :background "#ffffff" :foreground "#000000" )
      (set-face-attribute 'cfw:face-sunday nil :foreground "#991613" :background "#ffffff" :weight 'bold)
      (set-face-attribute 'cfw:face-saturday nil :foreground "#b5006a" :background "#ffffff"  :weight 'bold)
      (set-face-attribute 'cfw:face-holiday nil :background "#ffffff" :foreground "#06c6f5" :weight 'bold)
      (set-face-attribute 'cfw:face-grid nil :foreground "DarkGrey")
      (set-face-attribute 'cfw:face-default-content nil :foreground "#bfebbf")
      (set-face-attribute 'cfw:face-periods nil :foreground "cyan")
      (set-face-attribute 'cfw:face-day-title nil :background "#ffffff" )
      (set-face-attribute 'cfw:face-default-day nil :weight 'bold :inherit 'cfw:face-day-title)
      (set-face-attribute 'cfw:face-annotation nil :foreground "RosyBrown" :inherit  'cfw:face-day-title)
      (set-face-attribute 'cfw:face-disable nil :foreground "DarkGray" :inherit 'cfw:face-day-title)
      (set-face-attribute 'cfw:face-today-title nil :background "#f8ddea" :weight 'bold)
      (set-face-attribute 'cfw:face-today nil :background "#f8ddea" :weight 'bold)
      (set-face-attribute 'cfw:face-select nil :background "#bbfc20")
      (set-face-attribute 'cfw:face-toolbar nil :background "#ffffff" :foreground "#081530" )
      (set-face-attribute 'cfw:face-toolbar-button-off nil :background "#ffffff" :foreground "#5B6268" :weight 'bold)
      (set-face-attribute 'cfw:face-toolbar-button-on nil :background "#ffffff" :foreground "#608fb1" :weight 'bold)
      );end progn
    );end modus-operandi
  (setq
   modus-operandi-theme-slanted-constructs t
   modus-operandi-theme-bold-constructs t
   modus-operandi-theme-fringes 'subtle ; {nil,'subtle,'intense}
   modus-operandi-theme-3d-modeline t
   modus-operandi-theme-subtle-diffs t
   modus-operandi-theme-intense-hl-line t
   modus-operandi-theme-intense-standard-completions t
   modus-operandi-theme-org-blocks 'greyscale ; {nil,'greyscale,'rainbow}
   modus-operandi-theme-variable-pitch-headings t
   modus-operandi-theme-rainbow-headings t
   modus-operandi-theme-section-headings t
   modus-operandi-theme-scale-headings t
   modus-operandi-theme-scale-1 1.4
   modus-operandi-theme-scale-2 1.3
   modus-operandi-theme-scale-3 1.2
   modus-operandi-theme-scale-4 1.1
   modus-operandi-theme-scale-5 1))

(use-package modus-themes
  :straight (:build t)
  :commands (Appearance_/load-vivendi load-vivendi)
  :init
  (defun load-vivendi ()
    (interactive)
    (progn
      (reset-themes)
      (load-theme 'modus-vivendi t)
      (stylize-vivendi)))
                                        ;end load-leuven
  :config
  (defun stylize-vivendi ()
    (interactive)
    (progn
                                        ;tabar
      (set-face-attribute 'tab-bar nil :background "#081530" :foreground "#808080" :box '(:line-width 4 :color "#373b49" :style pressed-button))
      (set-face-attribute 'tab-bar nil :background "#081530" :foreground "#808080" :box '(:line-width 1 :color "#808080" :style pressed-button))
      (set-face-attribute 'tab-bar-tab-inactive nil :background "#081530" :foreground "#808080" :underline nil :box '(:line-width 4 :color "#373b49" :style pressed-button))
      (set-face-attribute 'tab-bar-tab nil :background "#081530" :foreground "white" :width 'semi-expanded :box  '(:line-width 4 :color "#373b49" :style pressed-button))

                                        ;dired
      (set-face-attribute 'all-the-icons-dired-dir-face nil :background "#1b1d1e" :foreground "#ff6fff")
      (set-face-attribute 'dired-filetype-execute nil :background "#1b1d1e" :foreground "#89A3B1")
      (set-face-attribute 'dired-filetype-xml nil :background "#1b1d1e" :foreground "#0C4EA0")
      (set-face-attribute 'dired-filetype-js nil :background "#1b1d1e" :foreground "#2C942C")
      (set-face-attribute 'dired-filetype-common nil :background "#1b1d1e" :foreground "#EA0E0E")
      (set-face-attribute 'dired-filetype-image nil :background "#1b1d1e" :foreground "#EA0E0E")
      (set-face-attribute 'dired-filetype-source nil :background "#1b1d1e" :foreground "#a61fde")
      (set-face-attribute 'dired-filetype-link nil :background "#1b1d1e" :foreground "#d02b61")
      (set-face-attribute 'dired-filetype-plain nil :background "#1b1d1e" :foreground "#a61fde")
      (set-face-attribute 'diredp-dir-name nil :background "#e8f1d4" :foreground "#0b0b0b")
      (set-face-attribute 'dired-filetype-mytype nil :background "#1b1d1e" :foreground "#b5006a")
                                        ;font-lock
      (set-face-attribute 'font-lock-comment-face nil :background "#1b1d1e" :foreground "#5f6368")
      (set-face-attribute 'font-lock-function-name-face nil :background "#1b1d1e" :foreground "#5f6368")
      (set-face-attribute 'font-lock-builtin-face nil :background "#1b1d1e" :foreground "#608fb1")
                                        ;org-block
      (set-face-attribute 'org-document-title nil :background "#1b1d1e" :foreground "#ff6fff")
      (set-face-attribute 'org-block nil :background "#1b1d1e" :foreground "#dddddd")
      (set-face-attribute 'org-block-end-line nil :background "#1b1d1e" :foreground "#808080")
      (set-face-attribute 'org-code nil :background "#e8f1d4" :foreground "#0b0b0b")
      (set-face-attribute 'org-level-2 nil :background "#f4fbf4" :foreground "#a61fde")
      (set-face-attribute 'org-meta-line nil :background "#f4fbf4" :foreground "#5f6368")
                                        ;default
      (set-face-attribute 'region nil :background "#262829" :foreground "#dddddd")
      (set-face-attribute 'highlight-parentheses-highlight nil :background "#e8f1d4" :foreground "#061229")
                                        ;webmode
      (set-face-attribute 'web-mode-html-attr-value-face nil :background "#1b1d1e" :foreground "#99bf52")
      (set-face-attribute 'web-mode-comment-face nil :background "#1b1d1e" :foreground "#608fb1")
      (set-face-attribute 'web-mode-html-attr-name-face nil :background "#1b1d1e" :foreground "#3c5be9")
      (set-face-attribute 'web-mode-style-face nil :background "#1b1d1e" :foreground "#a61fde")
      (set-face-attribute 'web-mode-variable-name-face nil :background "#1b1d1e" :foreground  "#3c5be9")
      (set-face-attribute 'web-mode-script-face nil :background "#1b1d1e" :foreground "#b77fdb" )
      (set-face-attribute 'web-mode-html-tag-face nil :background "#1b1d1e" )
      (set-face-attribute 'web-mode-current-element-highlight-face nil :background "#cfe8cf" )
      (set-face-attribute 'web-mode-current-column-highlight-face nil :background "#cfe8cf" :foreground "#242924")
      (set-face-attribute 'web-mode-html-tag-bracket-face nil :background "#f4fbf4" :foreground "#dc322f")
                                        ;hydra-posframe
      (set-face-attribute 'hydra-posframe-border-face nil :background "#ffffff"  :foreground "#ffffff" )
      (set-face-attribute 'hydra-posframe-face nil :background "#1b1d1e"  :foreground "#dddddd" )
                                        ; hydra faces
      (set-face-attribute 'pretty-hydra-toggle-off-face nil :background "#EAF1EA" :foreground "#43852e")
      (set-face-attribute 'pretty-hydra-toggle-on-face nil :background "#EAF1EA" :foreground "#43852e")
                                        ;rainbow-delimeters
      (set-face-attribute 'rainbow-delimiters-unmatched-face nil :background "#d02b61"  :foreground "#1b1d1e" )
      (set-face-attribute 'rainbow-delimiters-mismatched-face nil :background "#061229"  :foreground "#2C942C")
                                        ;company background
      (set-face-attribute 'company-tooltip nil :background "#263145"  :foreground "#dddddd" :inherit nil)
      (set-face-background 'company-tooltip "#263145")
      (set-face-foreground 'company-tooltip "#dddddd")
      (setq pbg-swap '(background-color . "#263145"))
      (setq pfg-swap '(foreground-color . "#dddddd"))
      (and (not (equal pbg-color pbg-swap)) (not (equal pfg-color pfg-swap))
           (progn
             (replace-element-in-list pbg-color pbg-swap  company-box-frame-parameters)
             (replace-element-in-list pfg-color pfg-swap  company-box-frame-parameters)
             ));end check frame swap loop
                                        ;update color so next function can take it out
      (setq pbg-color '(background-color . "#EAF1EA"))
      (setq pfg-color '(foreground-color . "#242924"))
                                        ;company
      (set-face-attribute 'company-tooltip-common t :background "#263145"  :foreground "#61284f" :inherit nil )
      (set-face-attribute 'company-box-candidate t :background "#263145"  :foreground "#7f002f" :inherit nil)
      (set-face-attribute 'company-box-annotation t :background "#263145"  :foreground "#61284f" :inherit nil)
      (set-face-attribute 'company-tooltip-common-selection t :background "#4d5666"  :foreground "#99bf52" :inherit nil)
      (set-face-attribute 'company-box-selection t :background "#464f60"  :foreground "#dddddd" :inherit nil )
      (set-face-attribute 'company-box-scrollbar t :background "#263145" :foreground "#d02b61" :inherit nil)
                                        ;neo
      (set-face-attribute 'neo-file-link-face nil :background "#fdf6e3" :foreground "#8D8D84")
      (set-face-attribute 'neo-dir-link-face nil :background "#fdf6e3" :foreground "#0000FF")
      (set-face-attribute 'neo-root-dir-face nil :background "#fdf6e3" :foreground "#BA36A5")
      (set-face-attribute 'neo-root-dir-face nil :background "#fdf6e3" :foreground "#fff")
                                        ;rainbow identifiers
      (set-face-attribute 'rainbow-identifiers-identifier-1 nil  :background "#f4fbf4" :foreground "#ff6fff")
      (set-face-attribute 'rainbow-identifiers-identifier-2 nil  :background "#f4fbf4" :foreground "#2C942C")
      (set-face-attribute 'rainbow-identifiers-identifier-3 nil  :background "#f4fbf4" :foreground "#b5006a")
      (set-face-attribute 'rainbow-identifiers-identifier-4 nil  :background "#f4fbf4" :foreground "#5B6268")
      (set-face-attribute 'rainbow-identifiers-identifier-5 nil  :background "#f4fbf4" :foreground "#0C4EA0")
      (set-face-attribute 'rainbow-identifiers-identifier-6 nil  :background "#f4fbf4" :foreground "#99bf52")
      (set-face-attribute 'rainbow-identifiers-identifier-7 nil  :background "#f4fbf4" :foreground "#a61fde")
      (set-face-attribute 'rainbow-identifiers-identifier-8 nil  :background "#f4fbf4" :foreground "#dc322f")
      (set-face-attribute 'rainbow-identifiers-identifier-9 nil  :background "#f4fbf4" :foreground "#00aa80")
      (set-face-attribute 'rainbow-identifiers-identifier-11 nil  :background "#f4fbf4" :foreground "#bbfc20")
      (set-face-attribute 'rainbow-identifiers-identifier-12 nil  :background "#f4fbf4" :foreground "#6c9ef8")
      (set-face-attribute 'rainbow-identifiers-identifier-13 nil  :background "#f4fbf4" :foreground "#dd8844")
      (set-face-attribute 'rainbow-identifiers-identifier-14 nil  :background "#f4fbf4" :foreground "#991613")
      (set-face-attribute 'rainbow-identifiers-identifier-15 nil  :background "#f4fbf4" :foreground "#242924")
      (setq zoom-window-mode-line-color "#242924")
      );end progn
    );end modus-vivendi
  :config
  (setq
   modus-operandi-theme-slanted-constructs t
   modus-operandi-theme-bold-constructs t
   modus-operandi-theme-fringes 'subtle ; {nil,'subtle,'intense}
   modus-operandi-theme-3d-modeline t
   modus-operandi-theme-subtle-diffs t
   modus-operandi-theme-intense-hl-line t
   modus-operandi-theme-intense-standard-completions t
   modus-operandi-theme-org-blocks 'rainbow ; {nil,'greyscale,'rainbow}
   modus-operandi-theme-variable-pitch-headings t
   modus-operandi-theme-rainbow-headings t
   modus-operandi-theme-section-headings t
   modus-operandi-theme-scale-headings t
   modus-operandi-theme-scale-1 1.5
   modus-operandi-theme-scale-2 1.4
   modus-operandi-theme-scale-3 1.3
   modus-operandi-theme-scale-4 1.2
   modus-operandi-theme-scale-5 1.1))

(defun my-setup-color-theme ()
  (interactive)
    (modus-themes-load-vivendi))
(use-package modus-themes :config (my-setup-color-theme))

(use-package rainbow-delimiters
  :straight (:build t)
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package info-colors
  :straight (:build t)
  :commands info-colors-fnontify-node
  :hook (Info-selection . info-colors-fontify-node)
  :hook (Info-mode      . mixed-pitch-mode))

(use-package avy
  :defer t
  :straight t
  :config
  (csetq avy-keys           '(?a ?u ?i ?e ?c ?t ?s ?r ?n)
         avy-dispatch-alist '((?x . avy-action-kill-move)
                              (?X . avy-action-kill-stay)
                              (?T . avy-action-teleport)
                              (?m . avy-action-mark)
                              (?C . avy-action-copy)
                              (?y . avy-action-yank)
                              (?Y . avy-action-yank-line)
                              (?I . avy-action-ispell)
                              (?z . avy-action-zap-to-char)))
  (defun my/avy-goto-url ()
    "Jump to url with avy."
    (interactive)
    (avy-jump "https?://"))
  (defun my/avy-open-url ()
    "Open url selected with avy."
    (interactive)
    (my/avy-goto-url)
    (browse-url-at-point))
  :general
  (dqv/evil
    :pakages 'avy
    "gc" #'evil-avy-goto-char-timer
    "gl" #'evil-avy-goto-line)
  (dqv/leader-key
    :packages 'avy
    :infix "j"
    "b" #'avy-pop-mark
    "c" #'evil-avy-goto-char-timer
    "l" #'avy-goto-line)
  (dqv/leader-key
    :packages 'avy
    :infix "A"
    "c"  '(:ignore t :which-key "copy")
    "cl" #'avy-copy-line
    "cr" #'avy-copy-region
    "k"  '(:ignore t :which-key "kill")
    "kl" #'avy-kill-whole-line
    "kL" #'avy-kill-ring-save-whole-line
    "kr" #'avy-kill-region
    "kR" #'avy-kill-ring-save-region
    "m"  '(:ignore t :which-key "move")
    "ml" #'avy-move-line
    "mr" #'avy-move-region
    "mt" #'avy-transpose-lines-in-region
    "n"  #'avy-next
    "p"  #'avy-prev
    "u"  #'my/avy-goto-url
    "U"  #'my/avy-open-url)
  (dqv/major-leader-key
    :packages '(avy org)
    :keymaps 'org-mode-map
    "A" '(:ignore t :which-key "avy")
    "Ar" #'avy-org-refile-as-child
    "Ah" #'avy-org-goto-heading-timer))

(setq calc-angle-mode    'rad
      calc-symbolic-mode t)

(use-package elcord
  :straight (:built t)
  :defer t
  :config
  (csetq elcord-use-major-mode-as-main-icon t
         elcord-refresh-rate                5
         elcord-boring-buffers-regexp-list  `("^ "
                                              ,(rx "*" (+ any) "*")
                                              ,(rx bol (or "Re: "
                                                           "Fwd: ")))))

(use-package ivy-quick-find-files
  :defer t
  :straight (ivy-quick-find-files :type git
                                  :host github
                                  :repo "phundrak/ivy-quick-find-files.el"
                                  :build t)
  :config
  (setq ivy-quick-find-files-program 'fd
        ivy-quick-find-files-dirs-and-exts '(("~/org"                  . "org")
                                             ("~/Documents/conlanging" . "org")
                                             ("~/Documents/university" . "org"))))

(use-package keycast
  :defer t
  :straight (:build t)
  :config
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (add-hook 'pre-command-hook 'keycast--update t)
      (remove-hook 'pre-command-hook 'keycast--update)))
  (add-to-list 'global-mode-string '("" mode-line-keycast " ")))

(use-package keyfreq
  :straight (:build t)
  :init
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1)
  :config
  (setq keyfreq-excluded-commands '(self-insert-command org-self-insert-command
                                    evil-previous-visual-line evil-next-visual-line
                                    ivy-next-line evil-backward-char evil-forward-char
                                    evil-next-line evil-previous-line evil-normal-state
                                    text-scale-pinch)))

(use-package sicp
  :straight (:build t)
  :defer t)

(use-package winum
  :straight (:build t)
  :init (winum-mode))

(define-key evil-normal-state-map (kbd "C-M-s-p") 'scroll-half-page-up)
(define-key evil-normal-state-map (kbd "C-M-s-n") 'scroll-half-page-down)
  (general-define-key
   :keymaps 'global-map
   "<mouse-2>" nil
   "<mouse-3>" nil)

  (dqv/evil
    :packages '(counsel)
    "U"   #'evil-redo
    "C-a" #'beginning-of-line
    "C-e" #'end-of-line
    "C-y" #'yank
    "M-y" #'counsel-yank-pop)

(dqv/leader-key
  "SPC" '(counsel-M-x :wk "M-x")
  "."  '(dired-jump :which-key "Dired Jump")
  "'"   #'shell-pop
  ","   #'magit-status
  "j" '(bufler-switch-buffer :which-key "Switch Buffer")
  "k" '(dqv/switch-to-previous-buffer :wk "Switch to previous buffer")
  "oa" '(org-agenda :wk "Agenda")

  "a" '(:ignore t :wk "apps")
  "ac" #'calc
  "ad" #'docker
  "aE" #'elfeed
  "ae" '(:ignore t :wk "email")
  "aec" #'mu4e-compose-new
  "aem" #'mu4e
  "ak" #'keycast-mode
  "aK" #'keycast-log-mode
  "aT" #'tetris
  "aw" #'wttrin
  "aC" #'calendar
  "as" '(:ignore t :wk "shells")
  "ase" #'eshell-new
  "asv" #'vterm
  "asV" #'multi-vterm
  "m" '(:ignore t :wk "treemacs")
  "mc" '(:ignore t :wk "create")
  "mcd" #'treemacs-create-dir
  "mcf" #'treemacs-create-file
  "mci" #'treemacs-create-icon
  "mct" #'treemacs-create-theme
  "mcw" #'treemacs-create-workspace
  "md" #'treemacs-delete-file
  "mf" '(:ignore t :wk "files")
  "mff" #'treemacs-find-file
  "mft" #'treemacs-find-tag
  "ml" '(:ignore t :wk "lsp")
  "mls" #'treemacs-expand-lsp-symbol
  "mld" #'treemacs-expand-lsp-treemacs-deps
  "mlD" #'treemacs-collapse-lsp-treemacs-deps
  "mlS" #'treemacs-collapse-lsp-symbol
  "mp" '(:ignore t :wk "projects")
  "mpa" #'treemacs-add-project
  "mpf" #'treemacs-project-follow-mode
  "mpn" #'treemacs-project-of-node
  "mpp" #'treemacs-project-at-point
  "mpr" #'treemacs-remove-project-from-workspace
  "mpt" #'treemacs-move-project-down
  "mps" #'treemacs-move-project-up
  "mr" '(:ignore t :wk "rename")
  "mrf" #'treemacs-rename-file
  "mrp" #'treemacs-rename-project
  "mrr" #'treemacs-rename
  "mrw" #'treemacs-rename-workspace
  "mt" #'treemacs
  "mT" '(:ignore t :wk "toggles")
  "mTd" #'treemacs-toggle-show-dotfiles
  "mTn" #'treemacs-toggle-node
  "mv" '(:ignore t :wk "visit node")
  "mva" #'treemacs-visit-node-ace
  "mvc" #'treemacs-visit-node-close-treemacs
  "mvn" #'treemacs-visit-node-default
  "my" '(:ignore t :wk "yank")
  "mya" #'treemacs-copy-absolute-path-at-point
  "myp" #'treemacs-copy-project-path-at-point
  "myr" #'treemacs-copy-relative-path-at-point
  "myf" #'treemacs-copy-file

  "b" '(:ignore t :wk "buffers")
  "bb" #'bufler-switch-buffer
  "bB" #'bury-buffer
  "bc" #'clone-indirect-buffer
  "bC" #'clone-indirect-buffer-other-window
  "bl" #'bufler
  "bk" #'kill-this-buffer
  "bD" #'kill-buffer
  "bh" #'dashboard-refresh-buffer
  "bm" #'switch-to-messages-buffer
  "bn" #'next-buffer
  "bp" #'previous-buffer
  "br" #'counsel-buffer-or-recentf
  "bs" #'switch-to-scratch-buffer

  "c"   '(:ignore t :wk "code")
  "cl"  #'evilnc-comment-or-uncomment-lines

  "e"  '(:ignore t :which-key "errors")
  "e." '(hydra-flycheck/body :wk "hydra")
  "el" #'counsel-flycheck
  "ee" '(:keymap flycheck-command-map :wk "flycheck")
  "ef" '(:keymap flyspell-mode-map :wk "flyspell")
  "eF" #'flyspell-hydra/body

  "f" '(:ignore t :wk "files")
  "ff" #'counsel-find-file
  "fD" #'dqv/delete-this-file
  "fF" #'ivy-quick-find-files
  "fh" #'hexl-find-file
  "fr" #'counsel-recentf
  "fs" #'save-buffer
  "fc"  '((lambda ()
            (interactive)
            (find-file "~/.emacs.d/vugomars.org"))
          :wk "emacs.org")
  
  "fi"  '((lambda ()
            (interactive)
            (find-file (concat user-emacs-directory "init.el")))
          :which-key "init.el")
  "fR"  '((lambda ()
            (interactive)
            (counsel-find-file ""
                               (concat user-emacs-directory
                                      (file-name-as-directory "straight")
                                      (file-name-as-directory "repos"))))
          :which-key "straight package")
  
  "owg"  '((lambda ()
            (interactive)
            (browse-url "https://github.com/vugomars"))
          :wk "My Github")
  
  "owc"  '((lambda ()
            (interactive)
            (browse-url "https://calendar.google.com/calendar/u/0/r?pli=1"))
          :wk "My Calender")
  

  "h" '(:ignore t :wk "help")
  "hk" #'which-key-show-top-level
  "hi" #'info
  "hI" #'info-display-manual
  "hd" '(:ignore t :wk "describe")
  "hdc" #'describe-char
  "hdC" #'helpful-command
  "hdf" #'helpful-callable
  "hdi" #'describe-input-method
  "hdk" #'helpful-key
  "hdm" #'helpful-macro
  "hdM" #'helpful-mode
  "hdp" #'describe-package
  "hds" #'helpful-symbol
  "hdv" #'helpful-variable

  "i"   '(:ignore t :wk "insert")
  "iu"  #'counsel-unicode-char



  "t" '(:ignore t :wk "toggles")
  "tt" #'my/modify-frame-alpha-background/body
  "tT" #'counsel-load-theme
  "tml" '(modus-themes-load-operandi :wk "Light Theme")
  "tmd" '(modus-themes-load-vivendi :wk "Dark Theme")
  "td" '(:ignore t :wk "debug")
  "tde" #'toggle-debug-on-error
  "tdq" #'toggle-debug-on-quit
  "ti" '(:ignore t :wk "input method")
  "tit" #'toggle-input-method
  "tis" #'set-input-method

  "T" '(:ignore t :wk "text")
  "Te" #'string-edit-at-point
  "Tu" #'downcase-region
  "TU" #'upcase-region
  "Tz" #'hydra-zoom/body

  "w" '(:ignore t :wk "windows")
  "wh" #'evil-window-left
  "wj" #'evil-window-down
  "wk" #'evil-window-up
  "wl" #'evil-window-right
  "w." #'windows-adjust-size/body
  "ws" #'split-window-below-and-focus
  "wv" #'split-window-right-and-focus
  "wi" #'winum-select-window-by-number
  "w0" '(winum-select-window-0-or-10 :wk t)
  "w1" '(winum-select-window-1 :wk t)
  "w2" '(winum-select-window-2 :wk t)
  "w3" '(winum-select-window-3 :wk t)
  "w4" '(winum-select-window-4 :wk t)
  "w5" '(winum-select-window-5 :wk t)
  "w6" '(winum-select-window-6 :wk t)
  "w7" '(winum-select-window-7 :wk t)
  "w8" '(winum-select-window-8 :wk t)
  "w9" '(winum-select-window-9 :wk t)
  "wc" #'kill-buffer-and-delete-window
  "wd" #'delete-window
  "wO" #'dqv/kill-other-buffers
  "wo" #'delete-other-windows

  "a" '(:ignore t :wk "quit")
  "agp" #'org-gcal-post-at-point
  "agR" '(org-gcal-reload-client-id-secret :wk "Reload Id")
  "ags" '(org-gcal-sync :wk "Sync Everything")
  "agS" '(org-gcal-sync-buffer :wk "Sync This Buffer")
  "agf" #'org-gcal-fetch
  "agF" #'org-gcal-fetch-buffer
  "agd" #'org-gcal-delete-at-point
  "agr" #'org-gcal-request-token
  "agt" #'org-gcal-toggle-debug

  "n" '(:ignore t :wk "quit")
  "nn" #'org-roam-node-find
  "naa" '(org-roam-alias-add :wk "Alias Add")
  "nar" '(org-roam-alias-remove :wk "Alias Remove")
  "ni" #'org-roam-node-insert
  "nl" #'org-roam-buffer-toggle
  "nct" #'org-roam-dailies-capture-today
  "ncT" #'org-roam-dailies-capture-tomorrow
  "nfd" #'org-roam-dailies-find-date
  "nft" #'org-roam-dailies-find-today
  "nfy" #'org-roam-dailies-find-yesterday
  "nfT" #'org-roam-dailies-find-tomorrow
  "ng" #'org-roam-graph
  "nbs" #'bookmark-set
  "nbj" #'bookmark-jump
  "nbi" #'bookmark-insert
  "nbl" #'bookmark-bmenu-list

  "a" '(:ignore t :wk "quit")
  "all" #'leetcode
  "ald" #'leetcode-daily
  "alo" #'leetcode-show-problem-in-browser
  "alO" #'leetcode-show-problem-by-slub
  "alS" #'leetcode-submit
  "als" #'leetcode-show-problem
  "l" '(:ignore t :wk "quit")
  "ll" #'lsp
  "lts" #'lsp-treemacs-symbols
  "lte" #'lsp-treemacs-errors-list
  "ltr" #'lsp-treemacs-references
  "ld" #'xref-find-definitions
  "lr" #'xref-find-references
  "lD" #'lsp-find-declaration

  "u"   #'universal-argument
  "U"   #'undo-tree-visualize)

(defhydra hydra-flycheck
  (:pre (flycheck-list-errors)
   :post (quit-windows-on "*Flycheck errors*")
   :hint nil)
  ("f" flycheck-error-list-set-filter "Filter")
  ("t" flycheck-next-error "Next")
  ("s" flycheck-previous-error "Previous")
  ("gg" flycheck-first-error "First")
  ("G" (progn (goto-char (point-max)) (flycheck-previous-error)) "Last")
  ("q" nil))
