;; site-lisp/config.el -*- lexical-binding: t; -*-

;;
;;; UI

;; Set font
(setq +emacs-font (font-spec :family "FantasqueSansMono NF" :size 15)
      +emacs-variable-pitch-font (font-spec :family "Merriweather"))

;; Set theme
(setq +emacs-theme 'doom-one-light)


;;
;;; Modules

;; :editor evil
;; Switch to the new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

;; :lang org
(setq org-directory "~/Projekte/org/"
      org-archive-location (concat org-directory "archive/%s::")
      +org-agenda-local-files (list "~/.emacs.d/" "~/.dotfiles/"))


;;
;;; Dotfiles

;; Ignore this directory in `+emacs-lisp-disable-flycheck-in-dirs'. Relevant if the configuration in
;; `+emacs-private-dir' is symlinked
(cl-pushnew (directory-file-name (file-name-directory (file-truename (file!))))
         +emacs-lisp-disable-flycheck-in-dirs :test #'equal)

;; Dotfiles _init template
(defun +file-templates-in-dotfiles-dir-p (file)
  "Returns t if FILE is in the Dotfiles directory."
  (file-in-directory-p file "~/.dotfiles"))

(set-file-template! "_init" :when #'+file-templates-in-dotfiles-dir-p :trigger "__init" :mode 'sh-mode)



;; (when-let (dims (+emacs-cache-get 'last-frame-size))
;;   (cl-destructuring-bind ((left . top) width height fullscreen) dims
;;     (setq initial-frame-alist
;;           (append initial-frame-alist
;;                   `((left . ,left)
;;                     (top . ,top)
;;                     (width . ,width)
;;                     (height . ,height)
;;                     (fullscreen . ,fullscreen))))))

;; (defun save-frame-dimensions ()
;;   (+emacs-cache-set 'last-frame-size
;;                     (list (frame-position)
;;                           (frame-width)
;;                           (frame-height)
;;                           (frame-parameter nil 'fullscreen))))

;; (add-hook 'kill-emacs-hook #'save-frame-dimensions)
