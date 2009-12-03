;;; #{app['basename']} --- Interactive functions to aid the development of webOS apps
;; #{timestamp}
(defconst mojo-version "#{app['version']}")

(require 'json)

#{files['COPYRIGHT']}

;;; Commentary:
(defgroup mojo '()
  "Interactive functions to aid the development of webOS apps.

This package is in early beta.  I am open to any contributions or
ideas.  Send me a pull request on github if you hack on mojo.el.")

;;; Installation:
;;
#{files['INSTALL']}


;;; Commands:
;;
#{files['COMMANDS']}

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
