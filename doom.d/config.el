(setq user-full-name "Ramon Ott"
      user-mail-address "ramon@julith.gmbh")
(setq doom-theme 'doom-monokai-classic doom-font (font-spec :family "JetBrainsMono NF" :size 12.0)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono NF" :size 12.0))

(setq display-line-numbers-type 'relative)
(setq doom-font-increment 1)
(setq org-directory "~/org/")
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.0))))
 '(org-level-4 ((t (:inherit outline-4 :height 0.9))))
 '(org-level-5 ((t (:inherit outline-5 :height 0.8))))
 )

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("C-l" . 'copilot-accept-completion)
              ))

;;(use-package! ob-async)
(require 'ob-async)

(setq tramp-default-method "sshx")

(set-frame-parameter (selected-frame) 'alpha '(99 99))
(add-to-list 'default-frame-alist '(alpha 99 99))

;; (when (eq emacs-major-version 30)
;;   (package! eldoc :built-in t))

(after! org
  (setq org-directory "~/Documents/allthethings"
        org-default-notes-file (expand-file-name "notes.org" org-directory)
        org-ellipsis " ▼ "
        org-superstar-headline-bullets-list '("◉" "●" "○" "◆" "●" "○" "◆")
        org-superstar-itembullet-alist '((?+ . ?➤) (?- . ?✦)) ; changes +/- symbols in item lists
        org-log-done 'time
        org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]
        org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
        '(("google" . "http://www.google.com/search?q=")
          ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
          ("ddg" . "https://duckduckgo.com/?q=")
          ("wiki" . "https://en.wikipedia.org/wiki/"))
        org-table-convert-region-max-lines 20000
        org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
        '((sequence
           "TODO(t)"           ; A task that is ready to be tackled
           "IDEA(i)"           ; Ideas
           "PROJ(p)"           ; A project that contains other tasks
           "VIDEO(v)"          ; Video assignments
           "WAIT(w)"           ; Something is holding up this task
           "|"                 ; The pipe necessary to separate "active" states and "inactive" states
           "DONE(d)"           ; Task has been completed
           "CANCELLED(c)" )))) ; Task has been cancelled

(after! org (setq org-agenda-files '("~/org/agenda.org")))

;;Set org roam directory
(setq org-roam-directory "~/Documents/allthethings/roam")

(setq
 ;; org-fancy-priorities-list '("[A]" "[B]" "[C]")
 ;; org-fancy-priorities-list '("❗" "[B]" "[C]")
 org-fancy-priorities-list '("🟥" "🟧" "🟨")
 org-priority-faces
 '((?A :foreground "#ff6c6b" :weight bold)
   (?B :foreground "#98be65" :weight bold)
   (?C :foreground "#c678dd" :weight bold))
 org-agenda-block-separator 8411)

(setq org-agenda-custom-commands
      '(("v" "A better agenda view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (tags "PRIORITY=\"B\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Medium-priority unfinished tasks:")))
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority unfinished tasks:")))
          (tags "customtag"
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Tasks marked with customtag:")))

          (agenda "")
          (alltodo "")))))

(define-key evil-visual-state-map "K"
            (concat ":m '<-2" (kbd "RET") "gv=gv"))
(define-key evil-visual-state-map "J"
            (concat ":m '>+1" (kbd "RET") "gv=gv"))
(define-key evil-normal-state-map "E"
            'er/expand-region)
(define-key evil-visual-state-map "E"
            'er/expand-region)
(define-key evil-normal-state-map "R"
            'er/contract-region)
(define-key evil-visual-state-map "R"
            'er/contract-region)
;;; Tree Sitter

(use-package! tree-sitter
  :hook (prog-mode . turn-on-tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (require 'tree-sitter-langs)
  ;; This makes every node a link to a section of code
  (setq tree-sitter-debug-jump-buttons t
        ;; and this highlights the entire sub tree in your code
        tree-sitter-debug-highlight-jump-region t))

(map! :leader (:prefix ("l" . "Lsp/Lump Menu")
                       (:desc "LSP Action" "a" #'lsp-execute-code-action)
                       (:desc "Cht.sh" "c" #'cheat-sh-search-topic)
                       (:desc "Inline Hints Toggle" "i" #'lsp-inline-hints-mode)
                       (:desc "Format Buffer" "f" #'+format/buffer)
                       )
      )
(map! :leader
      (:prefix ("e" . "Explore Menu")
       :desc "Toggle Treemacs" "e" #'treemacs))

(use-package! lsp-rust
  :config
  (setq! lsp-rust-analyzer-cargo-watch-enable t
         lsp-rust-analyzer-cargo-watch-command "clippy"
         lsp-rust-analyzer-proc-macro-enable t
         lsp-rust-analyzer-cargo-load-out-dirs-from-check t
         lsp-rust-analyzer-inlay-hints-mode t
         lsp-rust-analyzer-display-chaining-hints t
         lsp-rust-analyzer-display-parameter-hints t))

(lsp-headerline-breadcrumb-mode t)

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((sql . t))))

(setq shell-file-name "/bin/zsh")

(add-to-list 'load-path "/snap/maildir-utils/current/share/emacs/site-lisp/mu4e/")
;; (require! mu4e)

(setq
 mu4e-maildir "~/Mail/office365"
 mu4e-get-mail-command "mbsync office365"
 mu4e-update-interval 300
 mu4e-sent-folder "/Sent Items"
 mu4e-drafts-folder "/Drafts"
 mu4e-trash-folder "/Deleted Items"
 mu4e-refile-folder "/Archive"
 mu4e-maildir-shortcuts
 '(("/Inbox" . ?i)
   ("/Sent Items" . ?s)
   ("/Deleted Items" . ?t))
 mu4e-sent-messages-behavior 'sent
 message-send-mail-function 'message-send-mail-with-sendmail
 sendmail-program "/usr/bin/msmtp"
 message-sendmail-envelope-from 'header
 mail-user-agent 'mu4e-user-agent
 user-mail-address "ramon@julith.gmbh"
 user-full-name "Ramon Julith")

(after! mu4e
  ;; use msmtp as our sendmail
  (setq sendmail-program "/usr/bin/msmtp"
        message-send-mail-function 'message-send-mail-with-sendmail

        ;; tell msmtp to pull the envelope-from from the headers...
        ;;message-sendmail-extra-arguments '("--read-envelope-from")

        ;; ...but don’t have Emacs add its own -f flag
        message-sendmail-envelope-from nil))

;; update mu4e index every 5 minutes
(run-at-time nil (* 5 60) #'mu4e-update-index)

;; enable notifications when a new mail arrives
;;(after! mu4e
;;  (+mu4e-notifications-enable))


;; Toggle window dedication
(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"
  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window
                                 (not (window-dedicated-p window))))
       "Window '%s' is dedicated"
     "Window '%s' is normal")
   (current-buffer)))

;; Press [pause] key in each window you want to "freeze"
(global-set-key [pause] 'toggle-window-dedicated)

(after! lsp-mode
  (setq
   ;; explicitly point to the ngserver binary
   lsp-clients-angular-language-server-command
   '("ngserver" "--stdio"))

  ;; ensure ts/tsx/html buffers can activate the Angular server
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection
                     lsp-clients-angular-language-server-command)
    :activation-fn (lsp-activate-on "typescript" "typescript.tsx" "html")
    :priority -1
    :server-id 'angular-ls)))

(after! lsp-mode
  (setq lsp-clients-angular-language-server-command
        `(,(let ((root (or (locate-dominating-file default-directory "node_modules")
                           default-directory)))
             (expand-file-name "node_modules/.bin/ngserver" root))
          "--stdio"
          "--tsProbeLocations" ,(let ((root (locate-dominating-file default-directory "node_modules")))
                                  (expand-file-name "node_modules" root))
          "--ngProbeLocations" ,(let ((root (locate-dominating-file default-directory "node_modules")))
                                  (expand-file-name "node_modules" root)))))

(use-package aider
  :config
  (setq aider-args '("--model" "gpt-4.1-mini"))
  (require 'aider-doom))
