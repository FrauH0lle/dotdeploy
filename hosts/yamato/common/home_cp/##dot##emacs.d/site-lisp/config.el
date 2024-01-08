;; site-lisp/config.el -*- lexical-binding: t; -*-

;;
;;; UI

;; Set font
(setq zenit-font (font-spec :family "PragmataPro Liga" :size 18 :weight 'regular)
      zenit-variable-pitch-font "Merriweather")

;;; Set theme
(setq zenit-theme 'doom-one)


;;
;;; Modules

;; :editor evil
;; Switch to the new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

;; :emacs org
(setq org-directory "~/Projekte/org/")

;; :lang ess
;; Mark flycheck lintr settings as safe
(after! ess
  (put 'flycheck-lintr-linters 'safe-local-variable #'stringp))

;; :checkers grammar
(after! langtool
  (setq langtool-java-classpath
        "/usr/share/languagetool:/usr/share/java/languagetool/*"))


;;
;;; Dotfiles

;; Ignore this directory in `+emacs-lisp-disable-flycheck-in-dirs'. Relevant if
;; the configuration in `+emacs-private-dir' is symlinked
(after! flycheck
  (cl-pushnew (directory-file-name (file-name-directory (file-truename (concat zenit-local-conf-dir "config.el"))))
              +emacs-lisp-disable-flycheck-in-dirs :test #'equal))

;; Dotfiles _init template
(when (modulep! :editor file-templates)
  (defun +file-templates-in-dotfiles-dir-p (file)
    "Returns t if FILE is in the Dotfiles directory."
    (file-in-directory-p file "~/.dotfiles"))

  (set-file-template! "_init" :when #'+file-templates-in-dotfiles-dir-p :trigger "__init" :mode 'sh-mode))
