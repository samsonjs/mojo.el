;;; #{app['filename']} --- Interactive functions to aid the development of webOS apps
;; #{timestamp}
(defconst mojo-version "#{app['version']}")

(require 'json)

;; Copyright (c)2008 Jonathan Arkell. (by)(nc)(sa)  Some rights reserved.
;;              2009 Sami Samhuri
;;
;; Authors: Jonathan Arkell <jonnay@jonnay.net>
;;          Sami Samhuri <sami.samhuri@gmail.com>
;;
;; Latest version is available on github:
;;     http://github.com/samsonjs/config/blob/master/emacs.d/mojo.el
;;
;; With sufficient interest mojo.el will get its own repo.

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation version 2.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; For a copy of the GNU General Public License, search the Internet,
;; or write to the Free Software Foundation, Inc., 59 Temple Place,
;; Suite 330, Boston, MA 02111-1307 USA

;;; Commentary:
(defgroup mojo '()
  "Interactive functions to aid the development of webOS apps.

This package is in early beta.  I am open to any contributions or
ideas.  Send me a pull request on github if you hack on mojo.el.")
  
;;; Installation:
;; 
;; 1. Put json.el and mojo.el somewhere in your load-path.
;;    (Use M-x show-variable RET load-path to see what your load path is.)
;; 
;; 2. Add this to your Emacs init file: (require 'mojo)
;; 
;; 3. Make sure you customize the variables:
;;    mojo-project-directory, mojo-sdk-directory and mojo-build-directory
;;    (Use M-x customize-group RET mojo RET)
;; 
;; (optional)
;; 
;; 4. I recommend that you define a few keyboard shortcuts in your Emacs init
;;    file. Maybe something like this:
;; 
;;     (global-set-key [f2] mojo-generate-scene)
;;     (global-set-key [f3] mojo-emulate)
;;     (global-set-key [f4] mojo-package)
;;     (global-set-key [f5] mojo-package-install-and-inspect)
;; 

;;; Commands:
;;
;; Below are complete command list:
;;
;;  `mojo-generate'
;;    Generate a new Mojo application in the `mojo-project-directory'.
;;  `mojo-generate-scene'
;;    Generate a new Mojo scene for the application in `mojo-root'.
;;  `mojo-emulate'
;;    Launch the palm emulator.
;;  `mojo-package'
;;    Package the current application.
;;  `mojo-install'
;;    Install the specified package for the current application.
;;    The emulator needs to be running.
;;  `mojo-list'
;;    List all installed packages.
;;  `mojo-delete'
;;    Remove application named APP-NAME.
;;  `mojo-launch'
;;    Launch the current application in an emulator.
;;  `mojo-close'
;;    Close launched application.
;;  `mojo-inspect'
;;    Run the dom inspector on the current application.
;;  `mojo-hard-reset'
;;    Perform a hard reset, clearing all data.
;;  `mojo-package-install-and-launch'
;;    Package, install, and launch the current app.
;;  `mojo-package-install-and-inspect'
;;    Package, install, and launch the current app for inspection.
;;  `mojo-target-device'
;;    Set the target to a USB device.
;;  `mojo-target-emulator'
;;    Set the target to the emulator.

;;; Customizable Options:
;;
;; Below are customizable option list:
;;
;;  `mojo-sdk-directory'
;;    Path to where the mojo SDK is.
;;    default = (case system-type
;;	                ((windows-nt) "c:/progra~1/palm/sdk")
;;	                ((darwin) "/opt/PalmSDK/Current")
;;	                (t ""))
;;  `mojo-project-directory'
;;    Directory where all your Mojo projects are located.
;;    default = ""
;;  `mojo-build-directory'
;;    Directory to build Mojo applications in.
;;  `mojo-debug'
;;    Run Mojo in debug mode.  Assumed true while in such an early version.
;;    default = t

#{files['CHANGELOG']}

;;; Code:

#{files['code.el']}

;;; mojo ends here
