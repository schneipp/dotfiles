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

;(use-package! copilot
;  :hook (prog-mode . copilot-mode)
;  :bind (:map copilot-completion-map
;              ("C-l" . 'copilot-accept-completion)
;              ))

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

(use-package! org
  :config
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
  ;; Use a more robust Angular Language Server configuration
  (setq lsp-clients-angular-language-server-command
        `(,(let ((root (or (locate-dominating-file default-directory "node_modules")
                           default-directory)))
             (expand-file-name "node_modules/.bin/ngserver" root))
          "--stdio"
          "--tsProbeLocations" ,(let ((root (or (locate-dominating-file default-directory "node_modules")
                                                default-directory)))
                                  (expand-file-name "node_modules" root))
          "--ngProbeLocations" ,(let ((root (or (locate-dominating-file default-directory "node_modules")
                                                default-directory)))
                                  (expand-file-name "node_modules" root))))

  ;; Make sure Angular client is registered with the proper activation conditions
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection (lambda () lsp-clients-angular-language-server-command))
    :major-modes '(typescript-mode typescript-tsx-mode web-mode html-mode)
    :priority -1
    :activation-fn (lambda (&rest _)
                     (and (lsp-workspace-root)
                          (or (locate-dominating-file default-directory "angular.json")
                              (locate-dominating-file default-directory ".angular-cli.json"))))
    :server-id 'angular-ls)))
;;force sqls!
(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(sql-mode . "sql"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "sqls")
    :major-modes '(sql-mode sql-interactive-mode)
    :server-id 'sqls)))

;;disable the shitty one
(setq lsp-disabled-clients '(sql-ls))

(use-package aider
  :config
  (setq aider-args '("--model" "gpt-4.1-mini"))
  (require 'aider-doom))

(defun rams/toggle-fixed-window-width ()
  "Toggle whether the current buffer's windows have a fixed width."
  (interactive)
  (if (eq window-size-fixed 'width)
      (progn
        ;; turn it off
        (kill-local-variable 'window-size-fixed)
        (kill-local-variable 'window-min-width)
        (message "🔓 window width unlocked"))
    ;; turn it on
    (let ((w (window-total-width)))
      ;; fix the width at its current value...
      (setq-local window-size-fixed 'width)
      ;; …and prevent it from ever shrinking below that
      (setq-local window-min-width w)
      (message "🔒 window width locked at %d columns" w))))


(defun rams/window-or-frame-right ()
  "Move to the window on the right, or to the next frame if there is none."
  (interactive)
  (if (windmove-find-other-window 'right)
      (windmove-right)
    (other-frame 1)))

(defun rams/window-or-frame-left ()
  "Move to the window on the left, or to the previous frame if there is none."
  (interactive)
  (if (windmove-find-other-window 'left)
      (windmove-left)
    (other-frame -1)))

(defun rams/window-or-frame-up ()
  "Move to the window above, or wrap around to the last frame."
  (interactive)
  (if (windmove-find-other-window 'up)
      (windmove-up)
    (other-frame -1)))

(defun rams/window-or-frame-down ()
  "Move to the window below, or wrap around to the next frame."
  (interactive)
  (if (windmove-find-other-window 'down)
      (windmove-down)
    (other-frame 1)))

(map! :map evil-window-map
      "f" #'other-frame)

(after! circe
  (set-irc-server! "localhost"
    `(:tls t
      :port 6667
      :nick "rams"
                                        ;      :sasl-username "myusername"
                                        ;      :sasl-password "mypassword"
      :channels ("#ayb"))))

;;
;; SQL Configuration
(use-package! sql
  :config
  (setq sql-postgres-program "psql") ; Ensure psql is used
  (setq sql-connection-alist
        '((postgresdb-postgres
           (sql-product 'postgres)
           (sql-user "postgres")
           (sql-database "postgres")
           (sql-server "172.17.0.1")
           (sql-port 5432))
          (postgresdb-hrcore
           (sql-product 'postgres)
           (sql-user "postgres")
           (sql-password "${POSTGRES_PASSWORD}") ; For org-babel
           (sql-database "hrcore")
           (sql-server "172.17.0.1")
           (sql-port 5432)))))

;; LSP for SQL
(use-package! lsp-mode
  :hook (sql-mode . lsp)
  :config
  (setq lsp-sqls-workspace-config-path nil)
  (setq lsp-sqls-connections
        '(((driver . "postgresql")
           (dataSourceName . "host=172.17.0.1 port=5432 user=postgres password=${POSTGRES_PASSWORD} dbname=hrcore sslmode=disable"))))
  ;; Ensure LSP logs for debugging
  (setq lsp-log-io t))

;; SQL Keyword Capitalization
(use-package! sqlup-mode
  :hook ((sql-mode sql-interactive-mode) . sqlup-mode)
  :config
  (setq sqlup-blacklist '("name")))

;; Org-mode for SQL
;; (use-package! org
;;   :config
;;   (org-babel-do-load-languages
;;    'org-babel-load-languages
;;    '((sql . t)))
;;   (add-to-list 'org-src-lang-modes '("sql" . sql))
;;   (defun my/org-edit-sql-src ()
;;     "Enable sql-mode and LSP in Org SQL source blocks."
;;     (let ((lang (org-element-property :language (org-element-context))))
;;       (when (string= lang "sql")
;;         (message "Activating sql-mode and LSP for SQL source block")
;;         (sql-mode)
;;         (lsp-deferred) ; Use lsp-deferred for asynchronous LSP startup
;;   :hook (org-edit-src-hook . my/org-edit-sql-src)) ; Use org-edit-src-hook instead
;;         (setq-local lsp-enabled-clients '(sqls))))) ; Explicitly enable sqls client

(defun my/org-sql-src-lsp-setup ()
  "Enable LSP and company in SQL source blocks in Org mode."
  (when (string= (file-name-extension (or (buffer-file-name) "")) "org")
    (when (and (derived-mode-p 'sql-mode)
               (fboundp 'lsp))
      (lsp)
      (company-mode 1))))

(add-hook 'org-src-mode-hook #'my/org-sql-src-lsp-setup)
(add-hook 'org-src-mode-hook #'company-mode)

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  ;; Optional: Customize org-modern settings
  (setq
   org-modern-table t           ; Enable modern table styling
   org-modern-star '("◉" "○" "✸" "✿") ; Customize headline stars
   org-modern-block-fringe nil  ; Adjust block appearance
   org-modern-todo t            ; Style TODO keywords
   org-modern-priority t        ; Style priority cookies
   org-modern-timestamp t       ; Style timestamps
   org-modern-tag t))           ; Style tags



;;by the power of emacs lisp, we can generate a config file for sqls on the fly
(defun my/generate-sqls-config-from-sql-connection (connection-name)
  "Generate .sqls/config.yml from CONNECTION-NAME in `sql-connection-alist`."
  (interactive
   (list (completing-read "Choose SQL connection: " (mapcar #'car sql-connection-alist))))
  (let* ((conn-info (cdr (assoc (intern connection-name) sql-connection-alist)))
         (get-val (lambda (keys)
                    (or (plist-get conn-info keys)
                        (when (assoc keys conn-info)
                          (cadr (assoc keys conn-info))))))
         (user (funcall get-val 'sql-user))
         (password (funcall get-val 'sql-password))
         (database (funcall get-val 'sql-database))
         (server (funcall get-val 'sql-server))
         (port (number-to-string (or (funcall get-val 'sql-port) 5432)))
         (config-yml
          (format "databases:\n  %s:\n    dialect: postgresql\n    host: %s\n    port: %s\n    user: %s\n    password: %s\n    database: %s\n"
                  connection-name server port user password database)))
    (make-directory "~/.sqls" t)
    (with-temp-file "~/.sqls/config.yml"
      (insert config-yml))
    (message "Wrote ~/.sqls/config.yml for %s" connection-name)))
;; tell lsp-sqls to use the config file
(setq lsp-sqls-workspace-config-path "~/.sqls/config.yml")


(use-package! eaf
  :commands (eaf-open-browser eaf-open)
  :custom
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  (browse-url-browser-function 'eaf-open-browser)
  :config
  (require 'eaf-browser)  ; Load browser module
  (when (featurep 'eaf-evil)  ; Load eaf-evil only if available
    (require 'eaf-evil)
    (define-key key-translation-map (kbd "SPC")
                (lambda (prompt)
                  (if (derived-mode-p 'eaf-mode)
                      (pcase eaf--buffer-app-name
                        ("browser" (if (string= (eaf-call-sync "call_function" eaf--buffer-id "is_focus") "True")
                                       (kbd "SPC")
                                     (kbd eaf-evil-leader-key)))
                        ("pdf-viewer" (kbd eaf-evil-leader-key))
                        ("image-viewer" (kbd eaf-evil-leader-key))
                        (_ (kbd "SPC")))
                    (kbd "SPC")))))
  (defalias 'browse-web #'eaf-open-browser))

;; (defun eaf-browser-defocus ()
;;   "Defocus the EAF browser and switch to another window."
;;   (interactive)
;;   (when (derived-mode-p 'eaf-mode)
;;     (eaf-call-async "call_function" eaf--buffer-id "blur")
;;     (other-window 1)))

;;(define-key eaf-mode-map (kbd "C-c") #'eaf-browser-defocus)

(defun my/sql-connect-advice (orig-fn &rest args)
  "Advice for `sql-connect` to auto-generate sqls config."
  (let ((connection-name (car args)))
    (apply orig-fn args)
    (my/generate-sqls-config-from-connection connection-name)))

(advice-add 'sql-connect :around #'my/sql-connect-advice)

(setq org-src-lang-modes (append '(("sql" . sql)) org-src-lang-modes))


;; Make sure vterm is loaded
(use-package! vterm :commands vterm)
(defun rams/hrcore-setup()
  "When switching to the project, open two vterm splits running Postgres and Angular."
  (when (and (projectile-project-p)
             (string-equal (projectile-project-name) "hrcore-php"))
    ;; start from a single window
    (delete-other-windows)
    ;; right split for Postgres shell
    (let ((docker-cmd "docker exec -it HRCORE-PG-RO bash")
          (angular-cmd "npm run startro"))
      (split-window-right)
      (other-window 1)
      (vterm)
      (vterm-send-string docker-cmd)
      (vterm-send-return)
      ;; below split for Angular
      (split-window-below)
      (other-window 1)
      (vterm)
      (vterm-send-string angular-cmd)
      (vterm-send-return)
      ;; go back to the left pane
      (other-window -2))))

;; hook it up so it runs whenever you switch projects
(add-hook 'projectile-after-switch-project-hook #'rams/hrcore-setup)

(use-package! evil-matchit
  :after evil
  :config
  (global-evil-matchit-mode 1))
