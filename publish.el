;; for github action by : maker2413/OrgRoamPublish@v1.0.1
(package-initialize)

;; Install use-package for easy package installs
(require 'use-package)

;; Install htmlize to export org files to html
(use-package htmlize
  :ensure t)

;; Install and Configure the org-roam package
(use-package org-roam
  :ensure t
  :init
  ;; Disable v2 warning message
  (setq org-roam-v2-ack t)
  :custom
  ;; Roam Notes directory
  (org-roam-directory "/opt/OrgFiles")
  :config
  (org-roam-setup))

(require 'ox-html)
(require 'ox-publish)

;; Don't create backup files (those ending with ~) during the publish process.
(setq make-backup-files nil)

;; Configure Packages
(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq c-basic-offset 2)
(setq sh-basic-offset 2)

(add-hook 'python-mode-hook
          (lambda()
            (setq tab-width 2)
            (setq python-indent-offset 2)))

;; Set Defaults
(setq base-dir "/opt/OrgFiles")
(setq images-dir (concat base-dir "/Content/images"))
(setq notes-dir (concat base-dir "/Content"))
(setq output-dir "/opt/OrgFiles/_site")
(setq static-dir (concat base-dir "/Static"))
(setq images-output-dir (concat output-dir "/images"))

;; org-collect-keyword-value allows me to grab information from a files keywords
(defun org-collect-keyword-value (key)
  "Get value of org property KEY of current buffer."
  (setq key-value (nth 1 (car (org-collect-keywords (list key)))))
  (if key-value key-value))

;; buffer-file-shortname allows me to grab just the file name of the current buffer
(defun buffer-file-shortname ()
  "Get the filename of the current buffer without the full path"
  (nth (- (length (split-string (buffer-file-name) "/")) 1)
       (split-string (buffer-file-name) "/")))

;; Set html header information
(setq maker/header "<link rel='stylesheet' type='text/css' href='/css/style_custom.css'/>
<link rel='stylesheet' type='text/css' href='https://unpkg.com/tippy.js@6/themes/light-border.css'/>
<script src='https://unpkg.com/@popperjs/core@2'></script>
<script src='https://unpkg.com/tippy.js@6'></script>
<script src='/js/script.js'></script>
<script src='/js/URI.js'></script>
<link rel='shortcut icon' type='image/png' href='./images/me.svg'/>\n
")

;; Set html footer information
(defun maker/footer ()
  (concat "Tags:" (or (org-collect-keyword-value "filetags") "none")))

(defun add-analytics-tracker (analytics-id)
  (format "<!-- Google tag (gtag.js) -->
<script async src='https://www.googletagmanager.com/gtag/js?id=%s'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', '%s');
</script>" analytics-id analytics-id))

;; Add roam files to list of files to search IDs for
(setq org-id-extra-files (org-roam-list-files))

;; Define the publishing project
(setq org-publish-project-alist
      ;; org-notes is used for the actual org files
      `(("buffer"
         :auto-sitemap t
	 :sitemap-title "Site Map"
	 :sitemap-ignore-case t
	 :sitemap-file-entry-format  "%t-%d"
         :base-directory ,notes-dir
         :base-extension "org"
         :html-doctype "html5"
         :html-head-extra ,maker/header
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-table-use-header-tags-for-first-column t
         :html-validation-link nil
	 :html-allow-name-attribute-in-anchors t
         :publishing-directory ,output-dir
         :publishing-function org-html-publish-to-html
         :section-numbers t
         :recursive t
         :with-author nil
         :with-toc t
	 :with-date t
	 :with-footnotes t)
        ;; static is used for the static assets in "Static"
        ("static"
         :base-directory ,static-dir
         :base-extension "css\\|js\\|html\\|txt"
         :publishing-directory ,output-dir
         :publishing-function org-publish-attachment
         :recursive t)
        ;; images is used for the images directory
        ("images"
         :base-directory ,images-dir
         :base-extension "png\\|svg"
         :publishing-directory ,images-output-dir
         :publishing-function org-publish-attachment
         :recursive t)
        ;; publish all above
        ("website"
         :components ("buffer" "static" "images"))))

;; Overwrite default HTML output template
(eval-after-load "ox-html"
  '(defun org-html-template (contents info)
     (concat (org-html-doctype info)
             "\n<html lan=\"en\">\n"
             "<head>\n"
             (org-html--build-meta-info info)
             (org-html--build-head info)
             (org-html--build-mathjax-config info)
	     "<script defer src='https://us.umami.is/script.js' data-website-id='6258a166-e351-495d-ab76-a530d85f93cf'></script>"
             "</head>\n"
             "<body>\n"
             "<header>\n"
             "<div class='navigation'>\n"
	     "<div class='header-title'>\n"
	     (format "((Bit-Mage) 'buffer) :: ")
	     "</div>\n"
             "<form action='/'>\n"
             "<input type='submit' value='Root'>\n"
             "</form>\n"
             "<form action='/sitemap'>\n"
             "<input type='submit' value='Explore'>\n"
             "</form>\n"
             "<form action='https://thebitmage.com'>\n"
             "<input type='submit' value='Blog'>\n"
             "</form>\n"
             ;; "<form action='https://cloud.umami.is/share/M9yHECVhEaGXHvAS/buffer.thebitmage.com'>\n"
             ;; "<input type='submit' value='Analytics'>\n"
             ;; "</form>\n"
             ;"<form id='search' autocomplete='on' class='search-box' action=/search.html>\n"
             ;"<label hidden for='search-input'></label>\n"
             ;"<input type='text' id='search-input' name='query' placeholder='Type here to search'>\n"
             ;"<input type='submit' value='search'>\n"
             ;"</form>\n"
             "</div>\n"
             "</header>\n"
             "<div class='notes-container'>\n"
             "<div class='notes'>\n"
             "<div class='note'>\n"
             ;; Document contents.
             (let ((div (assq 'content (plist-get info :html-divs))))
               (format "<%s class=\"%s\">\n" (nth 1 div) (nth 2 div)))
             ;; Document title.
             (when (plist-get info :with-title)
               (let ((title (and (plist-get info :with-title)
                                 (plist-get info :title)))
                     (subtitle (plist-get info :subtitle))
                     (html5-fancy (org-html--html5-fancy-p info)))
                 (when title
                   (format
                    (if html5-fancy
                        "<header>\n<h1 class=\"title\">%s</h1>\n%s</header>"
                      "<h1 class=\"title\">%s%s</h1>\n")
                    (org-export-data title info)
                    (if subtitle
                        (format
                         (if html5-fancy
                             "<p class=\"subtitle\">%s</p>\n"
                           (concat "\n" (org-html-close-tag "br" nil info) "\n"
                                   "<span class=\"subtitle\">%s</span>\n"))
                         (org-export-data subtitle info))
                      "")))))
             contents
             (format "</%s>\n" (nth 1 (assq 'content (plist-get info :html-divs))))
             "<div class='postamble'>\n"
             ;; Postamble.
             (maker/footer)
             "</div>\n"
             "</div>\n"
             "</div>\n"
             "</div>\n"
             "</body>\n"
             "</html>\n"
             )))

;; Generate the site output
(org-publish-all t)
