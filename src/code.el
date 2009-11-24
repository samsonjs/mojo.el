
(defcustom mojo-sdk-directory
  (case system-type
	((windows-nt) "c:/progra~1/palm/sdk")
	((darwin) "/opt/PalmSDK/Current")
	(t ""))
  "Path to where the mojo SDK is.

Note, using the old-school dos name of progra~1 was the only way i could make
this work."
  :type 'directory
  :group 'mojo)

(defcustom mojo-project-directory ""
  "Directory where all your Mojo projects are located."
  :type 'directory
  :group 'mojo)

(defcustom mojo-build-directory ""
  "Directory where built projects are saved."
  :type 'directory
  :group 'mojo)

;;* debug
(defcustom mojo-debug t
  "Run Mojo in debug mode.  Assumed true while in such an early version."
  :type 'boolean
  :group 'mojo)
 

;;* interactive generate
(defun mojo-generate (title directory)
  "Generate a new Mojo application in the `mojo-project-directory'.

TITLE is the name of the application.
DIRECTORY is the directory where the files are stored."
  ;;TODO handle existing directories (use --overwrite)
  (interactive "sTitle: \nsDirectory Name (inside of mojo-project-directory): \n")
  (let ((mojo-dir (expand-file-name (concat mojo-project-directory "/" directory))))
	(when (file-exists-p mojo-dir)
		  (error "Cannot mojo-generate onto an existing directory! (%s)" mojo-dir))
	(make-directory mojo-dir)
	(mojo-cmd "palm-generate" (list "-p" (format "\"{'title':'%s'}\"" title)
					mojo-dir))
	(find-file (concat mojo-dir "/appinfo.json"))))

;;* interactive
(defun mojo-generate-scene (name)
  "Generate a new Mojo scene for the current application.

NAME is the name of the scene."
  (interactive "sScene Name: \n")
  (let ((mojo-dir (mojo-root)))
    (mojo-cmd "palm-generate" (list "-t" "new_scene"
				    "-p" (format "name=%s" name) mojo-dir))
    (find-file (format "%s/app/assistants/%s-assistant.js" mojo-dir name))
    (find-file (format "%s/app/views/%s/%s-scene.html" mojo-dir name name))))

;;* interactive 
(defun mojo-emulate ()
  "Launch the palm emulator."
  (interactive)
  (unless (mojo-emulator-running-p)
    (mojo-cmd "palm-emulator" nil)))

;;* interactive 
(defun mojo-package ()
  "Package the current application into `MOJO-BUILD-DIRECTORY'."
  (interactive)
  (mojo-cmd "palm-package" (list "-o" (expand-file-name mojo-build-directory)
				 (mojo-root))))

;;* interactive 
(defun mojo-install ()
  "Install the package named by `MOJO-PACKAGE-FILENAME'. The emulator needs to be running."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-install" (list (expand-file-name (mojo-read-package-filename))))
  (mojo-invalidate-app-cache))

;;* interactive 
(defun mojo-list ()
  "List all installed packages."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-install" (list "--list")))

;;* interactive 
(defun mojo-delete ()
  "Remove the current application using `MOJO-APP-ID'."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-install" (list "-r" (mojo-read-app-id)))
  (mojo-invalidate-app-cache))

;;* interactive
(defun mojo-ensure-emulator-is-running ()
  "Launch the current application, and the emulator if necessary."
  (interactive)
  (if (string= "tcp" *mojo-target*)
      (progn
	(when (not (mojo-emulator-running-p))
	  (mojo-emulate)
	  (print "Launching the emulator, this will take a minute..."))
	(while (not (mojo-emulator-responsive-p))
	  (sleep-for 3))
	(print "Emulator has booted!"))
    (print "Connect your device if necessary.")))

;;* interactive 
(defun mojo-launch ()
  "Launch the current application in the emulator."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-launch" (list (mojo-read-app-id))))

;;* interactive 
(defun mojo-close ()
  "Close launched application."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-launch" (list "-c" (mojo-read-app-id))))

;;* launch interactive
(defun mojo-inspect ()
  "Run the DOM inspector on the current application."
  (interactive)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-launch" (list "-i" (mojo-read-app-id))))

;;* emulator interactive
(defun mojo-hard-reset ()
  "Perform a hard reset, clearing all data."
  (interactive)
  (mojo-cmd "palm-emulator" (list "--reset")))

(defun mojo-browse ()
  "Use `browse-url' to visit your application with Palm Host."
  (browse-url "http://localhost:8888"))


;;* interactive 
(defun mojo-package-install-and-inspect ()
  "Package, install, and launch the current application for inspection."
  (interactive)
  (mojo-package)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-install" (list (expand-file-name (mojo-package-filename))))
  (mojo-cmd-with-target "palm-launch" (list "-i" (mojo-app-id))))

;;* interactive 
(defun mojo-package-install-and-launch ()
  "Package, install, and launch the current application."
  (interactive)
  (mojo-package)
  (mojo-ensure-emulator-is-running)
  (mojo-cmd-with-target "palm-install" (list (expand-file-name (mojo-package-filename))))
  (mojo-cmd-with-target "palm-launch" (list (mojo-app-id))))


;;* interactive
(defun mojo-target-device ()
  "Specify that Mojo commands should target a real device.

Sets `*mojo-target*' to \"usb\"."
  (interactive)
  (setq *mojo-target* "usb"))

;;* interactive
(defun mojo-target-emulator ()
  "Specify that Mojo commands should target a real device.

Sets `*mojo-target*' to \"tcp\"."
  (interactive)
  (setq *mojo-target* "tcp"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some support functions that grok the basics of a Mojo project. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun drop-last-path-component (path)
  "Get the head of a path by dropping the last component."
  (if (< (length path) 2)
      path
    (substring path 0 (- (length path)
			 (length (last-path-component path))
			 1)))) ;; subtract one more for the trailing slash

(defun last-path-component (path)
  "Get the tail of a path, i.e. the last component."
  (if (< (length path) 2)
      path
    (let ((start -2))
      (while (not (string= "/" (substring path start (+ start 1))))
	(setq start (- start 1)))
      (substring path (+ start 1)))))

(defvar *mojo-last-root* ""
  "Last Mojo root found by `MOJO-ROOT'.")

(defun mojo-root ()
  "Find a Mojo project's root directory starting with `DEFAULT-DIRECTORY'."
  (let ((last-component (last-path-component default-directory))
	(dir-prefix default-directory))
    ;; remove last path element until we find appinfo.json
    (while (and (not (file-exists-p (concat dir-prefix "/appinfo.json")))
		(not (< (length dir-prefix) 2)))
      (setq last-component (last-path-component dir-prefix))
      (setq dir-prefix (drop-last-path-component dir-prefix)))

    ;; If no Mojo root found, ask for a directory.
    (if (< (length dir-prefix) 2)
	(setq dir-prefix (mojo-read-root)))

    ;; Invalidate cached values when changing projects.
    (if (or (blank *mojo-last-root*)
	    (not (string= dir-prefix *mojo-last-root*)))
	(progn
	  (setq *mojo-last-root* dir-prefix)
	  (setq *mojo-package-filename* nil)
	  (setq *mojo-app-id* nil)))

    dir-prefix))

(defun read-json-file (filename)
  "Parse the JSON in FILENAME and return the result."
  (save-excursion
    (let ((origbuffer (current-buffer))
	  (filebuffer (find-file-noselect filename)))
      (set-buffer filebuffer)
      (let ((text (buffer-string)))
	(switch-to-buffer origbuffer)
        (json-read-from-string text)))))

(defun mojo-app-version ()
  "Parse the project version from the appinfo.json file in `MOJO-ROOT'."
  (let ((appinfo (read-json-file (concat (mojo-root) "/appinfo.json"))))
	(cdr (assoc 'version appinfo))))

(defun mojo-app-id ()
  "Parse the project id from the appinfo.json file in `MOJO-ROOT'."
  (let ((appinfo (read-json-file (concat (mojo-root) "/appinfo.json"))))
    (cdr (assoc 'id appinfo))))

(defun mojo-package-filename ()
  "Get the package filename for the specified application."
  (format "%s/%s_%s_all.ipk" (expand-file-name mojo-build-directory)
	  (mojo-app-id) (mojo-app-version)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; app listing and completion ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *mojo-app-cache-filename* nil)
(defun mojo-app-cache-file (&optional force-reload)
  "Cache the list of applications in a temporary file.  Return the filename."
  (when (or force-reload
	  (not *mojo-app-cache-filename*))
    (setq *mojo-app-cache-filename* (make-temp-file "mojo-app-list-cache"))
    (save-excursion
      (let ((buffer (find-file-noselect *mojo-app-cache-filename*))
	    (apps (mojo-fetch-app-list)))
	(set-buffer buffer)
	(insert (string-join "\n" apps))
	(basic-save-buffer)
	(kill-buffer buffer))))
  *mojo-app-cache-filename*)

(defvar *mojo-app-id* nil
  "Most recently used application id.")

(defvar *mojo-package-filename* nil
  "Most recently used package file.")

(defvar *mojo-app-history* nil
  "List of the most recently used application ids.")

;; cache expires hourly by default
(defvar *mojo-app-cache-ttl* 3600
  "The minimum age of a stale cache file, in seconds.")

(defvar *mojo-package-history* nil
  "List of the most recently used package filenames.")

;; this is from rails-lib.el in the emacs-rails package
(defun string-join (separator strings)
  "Join all STRINGS using SEPARATOR."
  (mapconcat 'identity strings separator))

(defun blank (thing)
  "Return T if THING is nil or an empty string, otherwise nil."
  (or (null thing)
      (and (stringp thing)
           (= 0 (length thing)))))

(defun mojo-read-root ()
  "Get the path to a Mojo application, prompting with completion and
  history."
  (read-file-name "Mojo project: " (expand-file-name (concat mojo-project-directory "/"))))

(defun mojo-read-package-filename ()
  "Get the filename of a packaged application, prompting with completion and
  history.

The app id is stored in *mojo-package-filename* unless it was blank."
  (let* ((default (or *mojo-package-filename*
		      (mojo-package-filename)))
         (package (read-file-name (format "Package file (default: %s): " default)
				  (concat mojo-build-directory "/") default t)))
    (setq *mojo-package-filename* (last-path-component package))
    (expand-file-name package)))

(defun mojo-read-app-id (&optional prompt)
  "Get the id of an existing application, prompting with completion and
  history.

The app id is stored in *mojo-app-id* unless it was blank."
  (let* ((default (or *mojo-app-id* (mojo-app-id)))
         (prompt (or prompt
		     (format "App id (default: %s): " default)))
         (app-id (completing-read prompt
				  (mojo-app-list t)
				  nil
				  t
				  nil
				  '*mojo-app-history*
				  default)))
    (when (blank app-id)
      (setq app-id (mojo-app-id)))
    (setq *mojo-app-id* app-id)
    app-id))

(defun mojo-app-list (&optional fetch-if-missing-or-stale)
  "Get a list of installed Mojo applications."
  (cond ((and (file-readable-p (mojo-app-cache-file))
              (not (mojo-app-cache-stale-p)))
         (save-excursion
           (let* ((buffer (find-file (mojo-app-cache-file)))
                  (apps (split-string (buffer-string))))
             (kill-buffer buffer)
             apps)))
        (fetch-if-missing-or-stale
         (mojo-app-cache-file t) ;; force reload
         (mojo-app-list)) ;; guaranteed cache hit this time
        (t nil)))

(defun mojo-fetch-app-list ()
  "Fetch a fresh list of all applications."
  (mojo-ensure-emulator-is-running)
  (let* ((raw-list (nthcdr 7 (split-string (mojo-cmd-to-string "palm-install" (list "--list")))))
	 (apps (list))
	 (appname-regex "^[^0-9][^.]+\\(\\.[^.]+\\)+$")
	 (item (pop raw-list)))
    (while item
	(if (string-match appname-regex item) ;; liberal regex for simplicity
	  (push item apps)
	(print (concat "discarding " item)))
	(setq item (pop raw-list)))
    (nreverse apps)))

(defun mojo-app-cache-stale-p ()
  "Non-nil if the cache in `MOJO-APP-CACHE-FILE' is more than
  *mojo-app-cache-ttl* seconds old.

If the cache file does not exist then it is considered stale."
  (or (null (file-exists-p (mojo-app-cache-file)))
      (let* ((now (float-time (current-time)))
             (last-mod (float-time (sixth (file-attributes
             (mojo-app-cache-file)))))
             (age (- now last-mod)))
        (> age *mojo-app-cache-ttl*))))

(defun mojo-invalidate-app-cache ()
  "Delete the app list cache."
  (delete-file (mojo-app-cache-file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;* lowlevel luna
(defun mojo-luna-send (url data)
  "Send something through luna.

Luna-send is a program to send things like incoming calls, GPS status, SMS,
etc.  to your emulator.

This is a low level Emacs interface to luna-send.
URL is the luna url, and DATA is the data."
  (mojo-cmd "luna-send" (list "-n" "1" url data)))

(defvar *mojo-target* "tcp"
  "Used to specify the target platform, \"usb\" for the device
  and \"tcp\" for the emulator.  Deaults to \"tcp\".")

(defun mojo-emulator-running-p ()
  "Determine if the webOS emulator is running or not.

This command only works on Unix-like systems."
  (= 0 (shell-command "ps x | fgrep 'Palm SDK' | fgrep -v fgrep >/dev/null 2>&1")))

(defun mojo-emulator-responsive-p ()
  "Determine if the webOS emulator is able to respond to commands yet
 (i.e. if it's done booting)."
  (= 0 (shell-command "palm-install -d tcp --list >/dev/null 2>&1")))

(defun mojo-path-to-cmd (cmd)
  "Return the absolute path to a Mojo SDK command line program."
  (case system-type
    ((windows-nt) (concat mojo-sdk-directory "/bin/" cmd ".bat"))
    (t (concat mojo-sdk-directory "/bin/" cmd))))

;;* lowlevel cmd
(defun mojo-cmd (cmd args)
  "General interface for running mojo-sdk commands.

CMD is the name of the command (without path or extension) to execute.
 Automagically shell quoted.
ARGS is a list of all arguments to the command.
 These arguments are NOT shell quoted."
  (let ((cmd (mojo-path-to-cmd cmd))
	(args (string-join " " args)))
    (if mojo-debug (message "running %s with args %s " cmd args))
    (shell-command (concat cmd " " args))))

;;* lowlevel cmd
(defun mojo-cmd-with-target (cmd args &optional target)
  "General interface for running mojo-sdk commands that accept a target device.

CMD is the name of the command (without path or extension) to
 execute.  Automagically shell quoted.  ARGS is a list of all
 arguments to the command.  These arguments are NOT shell quoted.
 TARGET specifies the target device, \"tcp\" or \"usb\"."
  (let ((args (cons "-d" (cons (or target *mojo-target*) args))))
    (mojo-cmd cmd args)))

;;* lowlevel cmd
(defun mojo-cmd-to-string (cmd args &optional target)
  "General interface for running mojo-sdk commands and capturing the output
   to a string.

CMD is the name of the command (without path or extension) to execute.
 Automatically shell quoted.
ARGS is a list of all arguments to the command.
 These arguments are NOT shell quoted."
  (let ((cmd (mojo-path-to-cmd cmd))
	(args (concat "-d " (or target *mojo-target*) " "
		       (string-join " " args))))
    (if mojo-debug (message "running %s with args %s " cmd args))
    (shell-command-to-string (concat cmd " " args))))

(provide 'mojo)
