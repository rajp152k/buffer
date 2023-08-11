(defvar bootstrap-version)
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

(straight-use-package 'use-package)
(setq straight-path "~/.emacs.d/straight/")

(use-package htmlize
  :straight t)

(use-package org-roam
  :straight t
  :init
  (setq org-roam-v2-ack t)
  :config
  (setq org-roam-directory "./notes")
  (setq org-roam-file-extensions '("org"))
  (org-roam-db-autosync-mode))


(use-package org-roam-ui
  :straight
  (:host github :repo "rajp152k/org-roam-ui" :branch "main" :files ("*.el" "out"))
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))


(defun github-org-roam-ui-export ()
  "Export `org-roam-ui's-data for usage as static webserver."
  (let* ((dir (read-file-name "org-roam-ui-export"))
         (graphdata-file (concat (file-name-as-directory dir) "graphdata.json"))
         (notes-dir (concat (file-name-as-directory dir) "notes/")))
    (org-roam-ui--export-graphdata graphdata-file)
    (make-directory notes-dir :parents)
    (mapcar (lambda (id)
              (let* ((cid (car id))
                     (content (org-roam-ui--get-text cid)))
                (write-region content nil (concat notes-dir cid) 'append)))
            (org-roam-db-query "select id from nodes;"))))


(defun main () 
  (github-org-roam-ui-export))

(main)
