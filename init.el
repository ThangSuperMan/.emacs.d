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

  (set-fontset-font t 'symbol "Noto Color Emoji")
  (set-fontset-font t 'symbol "Symbola" nil 'append)

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

(defun dqv/replace-unicode-font-mapping (block-name old-font new-font)
  (let* ((block-idx (cl-position-if
                         (lambda (i) (string-equal (car i) block-name))
                         unicode-fonts-block-font-mapping))
         (block-fonts (cadr (nth block-idx unicode-fonts-block-font-mapping)))
         (updated-block (cl-substitute new-font old-font block-fonts :test 'string-equal)))
    (setf (cdr (nth block-idx unicode-fonts-block-font-mapping))
          `(,updated-block))))

(use-package unicode-fonts
  :custom
  (unicode-fonts-skip-font-groups '(low-quality-glyphs))
  :config
  ;; Fix the font mappings to use the right emoji font
  (mapcar
    (lambda (block-name)
      (dqv/replace-unicode-font-mapping block-name "Apple Color Emoji" "Noto Color Emoji"))
    '("Dingbats"
      "Emoticons"
      "Miscellaneous Symbols and Pictographs"
      "Transport and Map Symbols"))
  (unicode-fonts-setup))

(setq frame-title-format
      '(""
        "%b"
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p) " ◉ %s" "  ●  %s - Emacs") project-name))))))

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

(defhydra writeroom-buffer-width ()
  "
^Width^        ^Other
^^^^^^^^-----------------------
[_j_] enlarge  [_r_/_0_] adjust
[_k_] shrink   [_q_]^^   quit
"
  ("q" nil :exit t)
  ("j" writeroom-increase-width "enlarge")
  ("k" writeroom-decrease-width "shrink")
  ("r" writeroom-adjust-width   "adjust")
  ("0" writeroom-adjust-width   "adjust"))

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

(defun dqv/kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

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
          org-directory                      "~/org"
          org-default-notes-file             (expand-file-name "notes.org" org-directory))
    (with-eval-after-load 'oc
     (setq org-cite-global-bibliography '("~/org/bibliography/references.bib")))
    (setq org-agenda-files (list "~/Dropbox/Org/" "~/Dropbox/Roam/"))
    (add-hook 'org-mode-hook (lambda ()
                               (interactive)
                               (electric-indent-local-mode -1)))
    (defvar org-conlanging-file "~/Dropbox/Org/conlanging.org")
    (defvar org-notes-file "~/Dropbox/Org/notes.org")
    (defvar org-journal-file "~/Dropbox/Org/journal.org")
    (defvar org-linguistics-file "~/Dropbox/Org/linguistics.org")
    (defvar org-novel-file "~/Dropbox/Org/novel.org")
    (defvar org-agenda-file "~/Dropbox/Org/agenda/private.org")
    (defvar org-school-file "~/Dropbox/Org/agenda/school.org")
    (defvar org-worldbuilding-file "~/Dropbox/Org/worldbuilding.org")
    (setq org-capture-templates
          '(
            ("e" "Email")
            ("ew" "Write Email" entry
              (file+headline org-default-notes-file "Emails")
              (file "~/.emacs.d/capture/email.orgcaptmpl"))
            ("j" "Journal" entry
              (file+datetree org-journal-file ##)
              (file "~/.emacs.d/capture/journal.orgcaptmpl"))
            ("l" "Link")
            ("ll" "General" entry
              (file+headline org-default-notes-file "General")
              (file "~/.emacs.d/capture/link.orgcaptmpl"))
            ("ly" "YouTube" entry
              (file+headline org-default-notes-file "YouTube")
              (file "~/.emacs.d/capture/youtube.orgcaptmpl"))
            ("L" "Protocol Link" entry
              (file+headline org-default-notes-file "Link")
              (file "~/.emacs.d/capture/protocol-link.orgcaptmpl"))
            ("n" "Notes")
            ("nc" "Conlanging" entry
              (file+headline org-conlanging-file "Note")
              (file "~/.emacs.d/capture/notes.orgcaptmpl"))
            ("nn" "General" entry
              (file+headline org-default-notes-file "General")
              (file "~/.emacs.d/capture/notes.orgcaptmpl"))
            ("nN" "Novel" entry
              (file+headline org-novel-notes-file "Note")
              (file "~/.emacs.d/capture/notes.orgcaptmpl"))
            ("nq" "Quote" entry
              (file+headline org-default-notes-file "Quote")
              (file "~/.emacs.d/capture/notes-quote.orgcaptmpl"))
            ("nw" "Worldbuilding" entry
              (file+headline org-wordbuilding-file "Note")
              (file "~/.emacs.d/capture/notes.orgcaptmpl"))
            ("N" "Novel")
            ("Ni" "Ideas" entry
              (file+headline org-novel-notes-file "Ideas")
              (file "~/.emacs.d/capture/notes.orgcaptmpl"))
            ("p" "Protocol" entry
              (file+headline org-default-notes-file "Link")
              (file "~/.emacs.d/capture/protocol.orgcaptmpl"))
            ("r" "Resources")
            ("rc" "Conlanging" entry
              (file+headline org-conlanging-file "Resources")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("re" "Emacs" entry
              (file+headline org-default-notes-file "Emacs")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("ri" "Informatique" entry
              (file+headline org-default-notes-file "Informatique")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("rl" "Linguistics" entry
              (file+headline org-default-notes-file "Linguistics")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("rL" "Linux" entry
              (file+headline org-default-notes-file "Linux")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("rw" "Worldbuilding" entry
              (file+headline org-wordbuilding-file "Resources")
              (file "~/.emacs.d/capture/resource.orgcaptmpl"))
            ("t" "Tasks")
            ("tb" "Birthday" entry
              (file+headline org-private-agenda-file "Birthday")
              (file "~/.emacs.d/capture/birthday.orgcaptmpl"))
            ("te" "Event" entry
              (file+headline org-private-agenda-file "Event")
              (file "~/.emacs.d/capture/event.orgcaptmpl"))
            ("th" "Health" entry
              (file+headline org-private-agenda-file "Health")
              (file "~/.emacs.d/capture/health.orgcaptmpl"))
            ("ti" "Informatique" entry
              (file+headline org-private-agenda-file "Informatique")
              (file "~/.emacs.d/capture/informatique.orgcaptmpl"))))
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
      "TT" #'org-todo)
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

  (use-package conlanging
    :straight (conlanging :build t
                          :type git
                          :repo "https://labs.phundrak.com/phundrak/conlanging.el")
    :after org
    :defer t)

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

(use-package org-unique-id
  :straight (org-unique-id :build t
                           :type git
                           :host github
                           :repo "Phundrak/org-unique-id")
  :defer t
  :after org
  :init (add-hook 'before-save-hook #'org-unique-id-maybe))

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

(use-package elfeed
  :defer t
  :straight (:build t)
  :config
  (defun my/elfeed-filter-youtube-videos (orig-fun &rest args)
    "Open with mpv the video leading to PATH"
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
        (if (string-match-p ".*youtube\.com.*watch.*" link)
            ;; This is a YouTube video, open it with mpv
            (progn
              (require 'ytplay)
              (ytplay link))
          (apply orig-fun args)))))
  
  (advice-add 'elfeed-show-visit :around #'my/elfeed-filter-youtube-videos)
  :custom
  ((elfeed-search-filter "@6-months-ago")
   (elfeed-db-directory  (expand-file-name ".elfeed-db"
                                           user-emacs-directory))))

(defun my/elfeed-filter-youtube-videos (orig-fun &rest args)
  "Open with mpv the video leading to PATH"
  (let ((link (elfeed-entry-link elfeed-show-entry)))
    (when link
      (if (string-match-p ".*youtube\.com.*watch.*" link)
          ;; This is a YouTube video, open it with mpv
          (progn
            (require 'ytplay)
            (ytplay link))
        (apply orig-fun args)))))

(advice-add 'elfeed-show-visit :around #'my/elfeed-filter-youtube-videos)

(use-package elfeed-goodies
  :defer t
  :after elfeed
  :commands elfeed-goodies/setup
  :straight (:build t)
  :init
  (elfeed-goodies/setup)
  :general
  (dqv/underfine
    :keymaps '(elfeed-show-mode-map elfeed-search-mode-map)
    :packages 'elfeed
    "DEL" nil
    "s"   nil)
  (dqv/evil
    :keymaps 'elfeed-show-mode-map
    :packages 'elfeed
    "+" #'elfeed-show-tag
    "-" #'elfeed-show-untag
    "«" #'elfeed-show-prev
    "»" #'elfeed-show-next
    "b" #'elfeed-show-visit
    "C" #'elfeed-kill-link-url-at-point
    "d" #'elfeed-show-save-enclosure
    "l" #'elfeed-show-next-link
    "o" #'elfeed-goodies/show-ace-link
    "q" #'elfeed-kill-buffer
    "S" #'elfeed-show-new-live-search
    "u" #'elfeed-show-tag--unread
    "y" #'elfeed-show-yank)
  (dqv/evil
    :keymaps 'elfeed-search-mode-map
    :packages 'elfeed
    "«" #'elfeed-search-first-entry
    "»" #'elfeed-search-last-entry
    "b" #'elfeed-search-browse-url
    "f" '(:ignore t :wk "filter")
    "fc" #'elfeed-search-clear-filter
    "fl" #'elfeed-search-live-filter
    "fs" #'elfeed-search-set-filter
    "u" '(:ignore t :wk "update")
    "us" #'elfeed-search-fetch
    "uS" #'elfeed-search-update
    "uu" #'elfeed-update
    "uU" #'elfeed-search-update--force
    "y" #'elfeed-search-yank)
  (dqv/major-leader-key
    :keymaps 'elfeed-search-mode-map
    :packages 'elfeed
    "c" #'elfeed-db-compact
    "t" '(:ignore t :wk "tag")
    "tt" #'elfeed-search-tag-all-unread
    "tu" #'elfeed-search-untag-all-unread
    "tT" #'elfeed-search-tag-all
    "tU" #'elfeed-search-untag-all))

(use-package elfeed-org
  :defer t
  :after elfeed
  :straight (:build t)
  :init
  (elfeed-org)
  :config
  (setq rmh-elfeed-org-files '("~/org/elfeed.org")))

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
  (csetq magit-todos-ignore-case t))

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

(use-package vterm
  :defer t
  :straight t
  :config
  (setq vterm-shell "/usr/bin/fish"))

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

(use-package writeroom-mode
  :defer t
  :straight (:build t)
  :init (global-writeroom-mode 1)
  :config
  (setq writeroom-mode-line         t
        writeroom-major-modes       '(text-mode org-mode markdown-mode nov-mode Info-mode)))

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

(setenv "SHELL" "/bin/sh")

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
                       (tramp-login-env (("SHELL") ("/bin/sh")))
                       (tramp-remote-shell "/bin/sh")
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
  :straight (bufler :build t
                    :files (:defaults (:exclude "helm-bufler.el")))
  :defer t
  :general
  (dqv/evil
   :keymaps  'bufler-list-mode-map
   :packages 'bufler
   "?"   #'hydra:bufler/body
   "g"   #'bufler
   "f"   #'bufler-list-group-frame
   "F"   #'bufler-list-group-make-frame
   "N"   #'bufler-list-buffer-name-workspace
   "k"   #'bufler-list-buffer-kill
   "p"   #'bufler-list-buffer-peek
   "s"   #'bufler-list-buffer-save
   "RET" #'bufler-list-buffer-switch))

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

(use-package appwrite
  :defer t
  :straight (appwrite :build t
                      :type git
                      :host github
                      :repo "Phundrak/appwrite.el")
  :config
  (csetq appwrite-endpoint "https://appwrite.phundrak.com"
         appwrite-devel t))

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
  :general
  (dqv/leader-key
    :packages 'langtool
    :infix "l"
    ""  '(:ignore t :which-key "LangTool")
    "B" #'langtool-correct-buffer
    "b" #'langtool-check-buffer
    "c" #'langtool-check
    "d" #'langtool-check-done
    "l" #'langtool-switch-default-language
    "p" #'langtool-show-message-at-point))

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

(use-package toml-mode
  :straight (:build t)
  :defer t
  :mode "/\\(Cargo.lock\\|\\.cargo/config\\)\\'")

(use-package yaml-mode
  :defer t
  :straight (:build t)
  :mode "\\.yml\\'"
  :mode "\\.yaml\\'")

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

(use-package dashboard
  :straight (:build t)
  :ensure t
  :after all-the-icons
  :config
  (setq dashboard-banner-logo-title "Vugomars’ Emacs"
        dashboard-startup-banner    'logo
        dashboard-center-content    t
        dashboard-show-shortcuts    t
        dashboard-set-navigator     t
        dashboard-set-heading-icons t
        dashboard-set-file-icons    t
        initial-buffer-choice       (lambda () (get-buffer "*dashboard*"))
        dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name)
  (setq dashboard-navigator-buttons
        `(((,(all-the-icons-faicon "language" :height 1.1 :v-adjust 0.0)
            "Vugomars' Website"
            ""
            (lambda (&rest _) (browse-url "https://vugomars.com"))))
          ((,(all-the-icons-faicon "level-up" :height 1.1 :v-adjust 0.0)
            "Update Packages"
            ""
            (lambda (&rest _) (progn
                                (require 'straight)
                                (straight-pull-all)
                                (straight-rebuild-all)))))))

  (setq dashboard-items '((recents  . 15)
                          (agenda   . 10)
                          (projects . 10)))
  (dashboard-setup-startup-hook)
  :init
  (add-hook 'after-init-hook 'dashboard-refresh-buffer))

(use-package git-gutter-fringe
  :straight (:build t)
  :hook ((prog-mode     . git-gutter-mode)
         (org-mode      . git-gutter-mode)
         (markdown-mode . git-gutter-mode)
         (latex-mode    . git-gutter-mode)))

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

(use-package secret-mode
  :defer t
  :straight (secret-mode :build t
                         :type git
                         :host github
                         :repo "bkaestner/secret-mode.el"))

(use-package solaire-mode
  :defer t
  :straight (:build t)
  :init (solaire-global-mode +1))

(use-package doom-themes
  :straight (:build t)
  :defer t
  :init (load-theme 'doom-nord-aurora t))

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
  "at" '(:ignore t :wk "treemacs")
  "atc" '(:ignore t :wk "create")
  "atcd" #'treemacs-create-dir
  "atcf" #'treemacs-create-file
  "atci" #'treemacs-create-icon
  "atct" #'treemacs-create-theme
  "atcw" #'treemacs-create-workspace
  "atd" #'treemacs-delete-file
  "atf" '(:ignore t :wk "files")
  "atff" #'treemacs-find-file
  "atft" #'treemacs-find-tag
  "atl" '(:ignore t :wk "lsp")
  "atls" #'treemacs-expand-lsp-symbol
  "atld" #'treemacs-expand-lsp-treemacs-deps
  "atlD" #'treemacs-collapse-lsp-treemacs-deps
  "atlS" #'treemacs-collapse-lsp-symbol
  "atp" '(:ignore t :wk "projects")
  "atpa" #'treemacs-add-project
  "atpf" #'treemacs-project-follow-mode
  "atpn" #'treemacs-project-of-node
  "atpp" #'treemacs-project-at-point
  "atpr" #'treemacs-remove-project-from-workspace
  "atpt" #'treemacs-move-project-down
  "atps" #'treemacs-move-project-up
  "atr" '(:ignore t :wk "rename")
  "atrf" #'treemacs-rename-file
  "atrp" #'treemacs-rename-project
  "atrr" #'treemacs-rename
  "atrw" #'treemacs-rename-workspace
  "att" #'treemacs
  "atT" '(:ignore t :wk "toggles")
  "atTd" #'treemacs-toggle-show-dotfiles
  "atTn" #'treemacs-toggle-node
  "atv" '(:ignore t :wk "visit node")
  "atva" #'treemacs-visit-node-ace
  "atvc" #'treemacs-visit-node-close-treemacs
  "atvn" #'treemacs-visit-node-default
  "aty" '(:ignore t :wk "yank")
  "atya" #'treemacs-copy-absolute-path-at-point
  "atyp" #'treemacs-copy-project-path-at-point
  "atyr" #'treemacs-copy-relative-path-at-point
  "atyf" #'treemacs-copy-file

  "b" '(:ignore t :wk "buffers")
  "bb" #'bufler-switch-buffer
  "bB" #'bury-buffer
  "bc" #'clone-indirect-buffer
  "bC" #'clone-indirect-buffer-other-window
  "bl" #'bufler
  "bd" #'kill-this-buffer
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
  "wb" #'kill-buffer-and-delete-window
  "wd" #'delete-window
  "wO" #'dqv/kill-other-buffers
  "wo" #'delete-other-windows
  "ww" '(:ignore t :wk "writeroom")
  "ww." #'writeroom-buffer-width/body
  "www" #'writeroom-mode

  "q" '(:ignore t :wk "quit")
  "qf" #'delete-frame
  "qq" #'save-buffers-kill-terminal
  "qQ" #'kill-emacs

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
