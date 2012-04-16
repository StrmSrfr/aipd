;;;; aipd.lisp

(in-package #:aipd)

;;; "aipd" goes here. Hacks and glory await!

(defvar *acceptor*
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 13013)))

(hunchentoot:define-easy-handler (index :uri "/aipd/") ()
  (setf (hunchentoot:content-type*) "text/html")
  (cl-who:with-html-output-to-string (s)
    (:html
     (:head
      (:title "Asynchonous Iterated Prisoner's Dilemma"))
     (:body
      (:h1 "Asynchronous Iterated Prisoner's Dilemma")
      (:form :action "log-in" :method "post"
             (:label "Username*"
                     (:input :type "text" :name "username"))
             (:label "Password"
                     (:input :type "password" :name "password"))
             (:input :type :submit)
             (:p "* A new account will be created if you enter a username that does not exist."))))))


(hunchentoot:define-easy-handler (log-in :uri "/aipd/log-in") (username password)
  (let*((user (find username *users* :key 'username :test 'string=))
        (destination
         (cond
           ((null user); new user!
            (setf user (make-instance 'user :username username :password-hash (bcrypt:hash password)))
            (push user *users*)
            "/aipd/home")
           ((bcrypt:password= password (password-hash user)); password matches
            (setf (seen user) (get-universal-time))
            "/aipd/home")
           (t; bad password
            "/aipd/")))); TODO indicate bad password to user
    (setf (hunchentoot:session-value 'user) user)
    (hunchentoot:redirect destination)))
              
(hunchentoot:define-easy-handler (home :uri "/aipd/home") ()
  (setf (hunchentoot:content-type*) "text/html")
  (let*((user (hunchentoot:session-value 'user))
        (challenges (remove user *challenges* :key 'player2 :test-not #'eq)))
    (cl-who:with-html-output-to-string (s)
      (:html
       (:head
        (:title "Asynchonous Iterated Prisoner's Dilemma"))
       (:body
        (:div
         (:h2 (cl-who:fmt "You have ~A points."
                            (points user))))
        (:div
         (:h2 (cl-who:fmt "You have ~A challengers" (length challenges)))
         (:ul
          (loop for challenge in challenges
             do (cl-who:htm
                 (:li (:a :href (format nil "round?id=~A" (id challenge))
                          (cl-who:str (username (player1 challenge)))))))))
        (:div
         (:h2 "Choose an opponent")
         (:ul
          (loop for opponent in *users*
             unless (eq opponent user)
             do (cl-who:htm
                 (:li (:a :href (format nil "challenge?username=~A"
                                            (hunchentoot:url-encode (username opponent)))
                          (cl-who:str (username opponent)))))))))))))

(hunchentoot:define-easy-handler (challenge :uri "/aipd/challenge") (username)
  (setf (hunchentoot:content-type*) "text/html")
  (cl-who:with-html-output-to-string (s)
    (:html
     (:head
      (:title "Asynchronous Iterated Prisoner's Dilemma"))
     (:body
      (:div
       (:h2 "What do you do?")
       (:form :action "player1-choose" :method :post
              (:input :type :hidden :name "username" :value username)
              (:input :type :submit :name "cooperate" :value "cooperate")
              (:input :type :submit :name "defect" :value "defect")))))))
    
(hunchentoot:define-easy-handler (player1-choose :uri "/aipd/player1-choose") (username cooperate defect)
  (push (make-instance 'challenge
                       :player1 (hunchentoot:session-value 'user)
                       :player2 (find username *users* :key 'username :test #'string=)
                       :player1-choice (cond
                                         (cooperate :cooperate)
                                         (defect :defect)
                                         (t (error "Trying to take a third option."))))
        *challenges*)
  (hunchentoot:redirect "/aipd/home"))

(hunchentoot:define-easy-handler (handle-round :uri "/aipd/round") (id)
  (setf (hunchentoot:content-type*) "text/html")
  (cl-who:with-html-output-to-string (s)
    (:html
     (:head
      (:title "Asynchronous Iterated Prisoner's Dilemma"))
     (:body
      (:div
       (:h2 "What do you do?")
       (:form :action "player2-choose" :method :post
         (:input :type :hidden :name "id" :value id)
         (:input :type :submit :name "cooperate" :value "cooperate")
         (:input :type :submit :name "defect" :value "defect")))))))

(hunchentoot:define-easy-handler (player2-choose :uri "/aipd/player2-choose") (id cooperate defect)
  (let*((challenge (find (read-from-string id) *challenges* :key 'id))
        (player1 (player1 challenge))
        (player2 (player2 challenge))
        (player1-choice
         (player1-choice challenge))
        (player2-choice
         (cond
           (cooperate :cooperate)
           (defect :defect)
           (t (error "Trying to take a third option.")))))
    (setf *challenges* (delete (read-from-string id) *challenges* :key 'id))
    (ecase player1-choice
      (:cooperate
       (ecase player2-choice
         (:cooperate
          (incf (points player1) 12)
          (incf (points player2) 12))
         (:defect
          (incf (points player1) 1)
          (incf (points player2) 13))))
      (:defect
       (ecase player2-choice
         (:cooperate
          (incf (points player1) 13)
          (incf (points player2) 1))
         (:defect
          (incf (points player1) 10)
          (incf (points player2) 10)))))
    (hunchentoot:redirect "/aipd/home")))
