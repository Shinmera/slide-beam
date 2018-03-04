#|
 This file is a part of slide-beam
 (c) 2018 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.slide-beam)

(defclass beamer (main)
  ((slide-show :initform NIL :accessor slide-show))
  (:default-initargs
   :clear-color (vec 1 1 1)))

(defmethod initialize-instance :after ((beamer beamer) &key slide-show)
  (setf (slide-show beamer)
        (etypecase slide-show
          (slide-show slide-show)
          ((or pathname string) (load-slide-show slide-show)))))

(define-action slideshow ())

(define-action next (slideshow)
  (key-press (one-of key :right :n :space :enter :return :pgup :page-up))
  (mouse-press (one-of button :left))
  (gamepad-press (one-of button :dpad-r :r1 :r2)))

(define-action prev (slideshow)
  (key-press (one-of key :left :p :backspace :pgdn :page-down))
  (gamepad-press (one-of button :dpad-l :l1 :l2)))

(define-action exit (slideshow)
  (key-press (one-of key :esc :escape))
  (gamepad-press (one-of button :home)))

(defun change-scene (display new)
  (transition (scene display) new)
  (setf (scene display) new))

(define-handler (controller next) (ev)
  (change-scene (display controller) (next-slide (slide-show (display controller)))))

(define-handler (controller prev) (ev)
  (change-scene (display controller) (prev-slide (slide-show (display controller)))))

(define-handler (controller exit) (ev)
  (quit *context*))

(defun start-slideshow (path)
  (launch 'beamer :slide-show path))

(defun toplevel ()
  (let ((path (first (uiop:command-line-arguments))))
    (if path
        (start-slideshow path)
        (error "Please pass a path to a slide show directory."))))