;; site-lisp/init.el -*- lexical-binding: t; -*-

(modules!

 :completion
 (company
  +childframe)

 :ui
 doom-theming
 modeline
 zen

 :checkers
 grammar
 spelling
 syntax

 :editor
 format
 word-wrap

 :tools
 copy-as-format

 :org
 (org
  +dragndrop
  +present
  +tufte)

 :lang
 data
 ess
 (latex
  +fold
  +latexmk)
 markdown)
