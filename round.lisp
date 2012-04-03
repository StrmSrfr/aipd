;;;; round.lisp

(in-package #:aipd)

(defclass challenge ()
  ((player1
    :accessor player1
    :initarg :player1
    :type user
    :documentation "Player who is initiating the challenge.")
   (player2
    :accessor player2
    :initarg :player2
    :type user
    :documentation "Player who is accepting the challenge.")
   (id
    :accessor id
    :initarg :id
    :initform (incf *round*)
    :type (integer 0))
   (player1-choice
    :accessor player1-choice
    :initarg :player1-choice
    :type (member :cooperate :defect))))

(defvar *round* 0)

(defvar *challenges* nil)

