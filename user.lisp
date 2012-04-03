;;;; user.lisp

(in-package #:aipd)

(defclass user ()
  ((username
    :accessor username
    :initarg :username
    :type string)
   (password-hash
    :accessor password-hash
    :initarg :password-hash
    :type string)
   (sentence
    :accessor sentence
    :initarg :sentence
    :initform 0
    :type (integer 0)
    :documentation "in months")
   (seen
    :accessor seen
    :initarg :seen
    :initform (get-universal-time)
    :type (integer 0)
    :documentation "when they were last on")))

(defvar *users* nil)

    

