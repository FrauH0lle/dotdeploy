;; site-lisp/init.el -*- lexical-binding: t; no-byte-compile: t; -*-

(modules!

 :completion
 vertico
 ;; company
 (corfu +icons)

 :ui
 doom-dashboard
 doom-theming
 hl-todo
 modeline
 popup
 vc-gutter
 ;; workspaces
 ;; zen

 :checkers
 grammar
 spell
 syntax

 :editor
 evil
 format
 word-wrap
 multiple-cursors
 fold
 rotate-text
 file-templates

 :emacs
 electric
 undo
 org
 vc

 :tools
 tree-sitter
 magit
 arch-linux
 ;; copy-as-format
 ;; direnv
 editorconfig
 (lsp)
 ;; pdf

 ;; :org
 ;; (org
 ;;  +dragndrop
 ;;  +present
 ;;  +tufte)

 :lang
 ;; ;; common-lisp
 data
 emacs-lisp
 (ess +lsp)
 ;; (latex
 ;;  +fold
 ;;  +latexmk)
 markdown
 (python)
 (rust +lsp +tree-sitter)
 (sh +lsp +tree-sitter)
 ;; (scheme
 ;;  +racket)

 :config
 (default +bindings +smartparens)
 compile
 )
