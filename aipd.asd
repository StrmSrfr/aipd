;;;; aipd.asd

(asdf:defsystem #:aipd
  :serial t
  :depends-on (#:alexandria
               #:cl-json
               #:cl-who
               #:eager-future2
               #:hunchentoot
               #:monkeylib-bcrypt
               #:parenscript
               #:ssmt
               #:bordeaux-threads)
  :components ((:file "package")
               (:file "user")
               (:file "round")
               (:file "aipd")))

