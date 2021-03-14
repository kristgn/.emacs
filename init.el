;; we can require features

(setq byte-compile-warnings '(cl-functions))

(require 'cl)
(require 'package)

;; GC boost
(setq startup/gc-cons-threshold gc-cons-threshold)
(setq gc-cons-threshold most-positive-fixnum)
(defun startup/reset-gc () (setq gc-cons-threshold startup/gc-cons-threshold))
(add-hook 'emacs-startup-hook 'startup/reset-gc)

;; add mirrors for list-packages
;;(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; needed to use things downloaded with the package manager
(package-initialize)

;; install some packages if missing
(let* ((packages '(auto-complete
                   ido-vertical-mode
                   afternoon-theme
                   multiple-cursors
                   undo-tree
                   ;; if you want more packages, add them here
                   ))
       (packages (remove-if 'package-installed-p packages)))
  (when packages
    (package-refresh-contents)
    (mapc 'package-install packages)))

;; no splash screen
(setq inhibit-splash-screen t)

;; set tab width to 4 spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; js2-mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;; show matching parenthesis
(show-paren-mode 1)

;; show column number in mode-line
(column-number-mode 1)

;; overwrite marked text
(delete-selection-mode 1)

;; enable ido-mode, changes the way files are selected in the minibuffer
(ido-mode 1)

;; use ido everywhere
(ido-everywhere 1)

;; show vertically
(ido-vertical-mode 1)

;; use undo-tree-mode globally
(global-undo-tree-mode 1)

;; stop blinking cursor
(blink-cursor-mode 0)

;; no menubar
(menu-bar-mode 0)

;; no toolbar either
(tool-bar-mode 0)

;; scrollbar? no
(scroll-bar-mode 0)

;; global-linum-mode shows line numbers in all buffers, exchange 0
;; with 1 to enable this feature
(global-linum-mode 0)

;; answer with y/n
(fset 'yes-or-no-p 'y-or-n-p)

;; choose a color-theme
(load-theme 'afternoon t)

;; get the default config for auto-complete (downloaded with
;; package-manager)
(require 'auto-complete-config)

;; load the default config of auto-complete
(ac-config-default)

;; kills the active buffer, not asking what buffer to kill.
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; remap other window to M-o
(global-set-key (kbd "M-o") 'other-window)

;; adds all autosave-files (i.e #test.txt#, test.txt~) in one
;; directory, avoid clutter in filesystem.
(defvar emacs-autosave-directory (concat user-emacs-directory "autosaves/"))
(setq backup-directory-alist
      `((".*" . ,emacs-autosave-directory))
      auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))

;; defining a function that sets more accessible keyboard-bindings to
;; hiding/showing code-blocs
(defun hideshow-on ()
  (local-set-key (kbd "C-c <right>") 'hs-show-block)
  (local-set-key (kbd "C-c <left>")  'hs-hide-block)
  (local-set-key (kbd "C-c <up>")    'hs-hide-all)
  (local-set-key (kbd "C-c <down>")  'hs-show-all)
  (hs-minor-mode t))


;; now we have to tell emacs where to load these functions. Showing
;; and hiding codeblocks could be useful for all c-like programming
;; (java is c-like) languages, so we add it to the c-mode-common-hook.
(add-hook 'c-mode-common-hook 'hideshow-on)

;; adding shortcuts to java-mode, writing the shortcut folowed by a
;; non-word character will cause an expansion.
(defun java-shortcuts ()
  (define-abbrev-table 'java-mode-abbrev-table
    '(("psv" "public static void main(String[] args) {" nil 0)
      ("sop" "System.out.printf" nil 0)
      ("flk" "for (int i = 0; i < .length; i++) {" nil 0)
      ("sopl" "System.out.println(" nil 0)))
  (abbrev-mode t))

;; the shortcuts are only useful in java-mode so we'll load them to
;; java-mode-hook.
(add-hook 'java-mode-hook 'java-shortcuts)

;; defining a function that guesses a compile command and bindes the
;; compile-function to C-c C-c
(defun java-setup ()
  (set (make-variable-buffer-local 'compile-command)
       (concat "javac " (buffer-name)))
  (local-set-key (kbd "C-c C-c") 'compile)
  (local-set-key (kbd "<Scroll_Lock>") 'compile)
  (setq c-basic-offset 4
        tab-width 4
        indent-tabs-mode t))

;; this is a java-spesific function, so we only load it when entering
;; java-mode
(add-hook 'java-mode-hook 'java-setup)

;; defining a function that sets the right indentation to the marked
;; text, or the entire buffer if no text is selected.
(defun tidy ()
  "Ident, untabify and unwhitespacify current buffer, or region if active."
  (interactive)
  (let ((beg (if (region-active-p) (region-beginning) (point-min)))
        (end (if (region-active-p) (region-end)       (point-max))))
    (whitespace-cleanup)
    (indent-region beg end nil)
    (untabify beg end)))

;; bindes the tidy-function to C-TAB
(global-set-key (kbd "<C-tab>") 'tidy)

;; multi cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;;pdfLaTeX
(setq TeX-PDF-mode t)

;; compile c code with C-c C-c
;; made obsolete by Makefile
(defun C-setup ()
  (set (make-variable-buffer-local 'compile-command)
       (concat "gcc " (buffer-name) " -o " (substring (buffer-name) 0 (- (length (buffer-name)) 2))))
  (local-set-key (kbd "C-c C-c") 'compile))

;; this is a C-spesific function, so we only load it when entering
;; C-mode
(add-hook 'c-mode-hook 'C-setup)

;; sets the standard window size to 100x70
(add-to-list 'default-frame-alist'(height . 70))
(add-to-list 'default-frame-alist'(width . 111))
(put 'upcase-region 'disabled nil)

;; spellchecker fra emacs boka
(add-hook 'tex-mode-hook
          #'(lambda () (setq ispell-parser 'tex)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(csharp-mode emmet-mode go-mode omnisharp company tide flycheck web-mode add-node-modules-path prettier-js rjsx-mode js-auto-beautify auctex xref-js2 js2-refactor js2-mode undo-tree multiple-cursors afternoon-theme ido-vertical-mode auto-complete))
 '(tab-width 4))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-delimiter-face ((t (:foreground "gray"))))
 '(font-lock-comment-face ((t (:foreground "gray")))))

;; Turn off mac scroll sound
(setq ring-bell-function #'ignore)

;; Fix for mac keyboard
;;(setq default-input-method "MacOSX")

;;(setq mac-command-modifier 'meta
;;      mac-option-modifier nil
;;      mac-allow-anti-aliasing t
;;      mac-command-key-is-meta t)

(defun setup-tide-mode ()
  "Setup function for tide."
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(setq company-tooltip-align-annotations t)

(add-hook 'js-mode-hook #'setup-tide-mode)
(add-hook 'js-mode-hook 'prettier-js-mode)

;; csharp mode
(add-hook 'csharp-mode-hook 'omnisharp-mode)

(eval-after-load
    'company
  '(add-to-list 'company-backends 'company-omnisharp))

(defun my-csharp-mode-setup ()
  (omnisharp-mode)
  (company-mode)
  (flycheck-mode)

  (setq indent-tabs-mode nil)
  (setq c-syntactic-indentation t)
  ;;(c-set-style "")
  (setq c-default-style "linux")
  (setq c-basic-offset 4)
  (setq truncate-lines t)
  (setq tab-width 4)
  (setq evil-shift-width 4))

(add-hook 'csharp-mode-hook 'my-csharp-mode-setup t)

(add-hook 'csharp-mode-hook #'company-mode)
(add-hook 'csharp-mode-hook #'flycheck-mode)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.cshtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(set-face-attribute 'web-mode-doctype-face nil :foreground "darkolivegreen3")
(set-face-attribute 'web-mode-html-tag-face nil :foreground "deepskyblue1")
(set-face-attribute 'web-mode-html-tag-bracket-face nil :foreground "white")
(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "white")
(set-face-attribute 'web-mode-html-attr-value-face nil :foreground "burlywood")

;; reactx
(add-to-list 'auto-mode-alist '("\\.jsx?$" . web-mode)) ;; auto-enable for .js/.jsx files
(setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))

(add-hook 'web-mode-hook
		  (lambda ()
			(setq web-mode-markup-indent-offset 4)
			(setq web-mode-css-indent-offset 4)
			(setq web-mode-code-indent-offset 4)))

(require 'flycheck)
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint json-jsonlist)))
;; Enable eslint checker for web-mode
(flycheck-add-mode 'javascript-eslint 'web-mode)
;; Enable flycheck globally
(add-hook 'after-init-hook #'global-flycheck-mode)
(defun web-mode-init-prettier-hook ()
  (add-node-modules-path)
  (prettier-js-mode))

;;(add-hook 'web-mode-hook  'web-mode-init-prettier-hook)
;;(add-hook 'web-mode-hook  'emmet-mode)

(add-hook 'python-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 4)
            (setq python-indent-offset 4)))
(put 'downcase-region 'disabled nil)

(deftheme afternoon-overrides)
(let ((class '((class color) (min-colors 257)))
      (terminal-class '((class color) (min-colors 89))))
  (custom-theme-set-faces
   'afternoon-overrides
   ;; Company tweaks.
   `(company-tooltip
     ((t :foreground "black"
         :background "#d3d3d2"
         :underline nil)))
   `(company-tooltip-selection
     ((t :background "#4581b3"
         :foreground "#F8F8F0")))
   `(company-tooltip-annotation
     ((t :inherit company-tooltip)))
   `(company-tooltip-annotation-selection
     ((t :inherit company-tooltip-selection)))
   `(company-preview
     ((t :inherit company-tooltip-selection)))
   `(company-preview-common
     ((t :inherit company-tooltip)))
   `(company-tooltip-search
     ((t :background "#349b8d"
         :foreground "#F8F8F0")))
   `(company-scrollbar-fg
     ((t :background "#4581b3")))
   `(company-scrollbar-bg
     ((t :background "#F8F8F0")))))
