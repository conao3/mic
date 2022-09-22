;;; mic-test.el --- Test for mic

;; Copyright (C) 2022  ROCKTAKEY

;; Author: ROCKTAKEY <rocktakey@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Test for mic

;;; Code:

(require 'ert)

(require 'undercover)
(undercover "*.el"
            (:report-format 'codecov)
            (:report-file "coverage-final.json")
            (:send-report nil))

(require 'mic)

(defmacro mic-ert-macroexpand-1 (name &rest args)
  "Define test named NAME.
The test compare macro expandation of `car' of each element of ARGS with `cdr' of it."
  (declare (indent defun))
  `(ert-deftest ,name ()
     ,@(mapcar
        (lambda (arg)
          `(should (equal (macroexpand-1 ',(car arg))
                          ',(cdr arg))))
        args)))

(mic-ert-macroexpand-1 mic-autoload-interactive
  ((mic package-name
     :autoload-intaractive
     (find-file
      write-file))
   . (prog1 'package-name
       (autoload #'find-file "package-name" nil t)
       (autoload #'write-file "package-name" nil t))))

(mic-ert-macroexpand-1 mic-autoload-noninteractive
  ((mic package-name
     :autoload-nonintaractive
     (cl-map
      cl-mapcar))
   . (prog1 'package-name
       (autoload #'cl-map "package-name")
       (autoload #'cl-mapcar "package-name"))))

(mic-ert-macroexpand-1 mic-custom
  ((mic package-name
     :custom
     ((a . 1)
      (b . (+ 1 2))))
   . (prog1 'package-name
       (customize-set-variable 'a 1)
       (customize-set-variable 'b
                               (+ 1 2)))))

(mic-ert-macroexpand-1 mic-custom-after-load
  ((mic package-name
     :custom-after-load
     ((a . 1)
      (b . (+ 1 2))))
   . (prog1 'package-name
       (with-eval-after-load 'package-name
         (customize-set-variable 'a 1)
         (customize-set-variable 'b
                                 (+ 1 2))))))

(mic-ert-macroexpand-1 mic-declare-function
  ((mic package-name
     :declare-function
     (find-file
      write-file))
   . (prog1 'package-name
       (declare-function find-file "ext:package-name")
       (declare-function write-file "ext:package-name"))))

(mic-ert-macroexpand-1 mic-define-key
  ((mic package-name
     :define-key
     ((global-map
       ("C-t" . #'other-window)
       ("C-n" . #'next-window))
      (prog-mode-map
       ("M-a" . #'beginning-of-buffer)
       ("M-e" . #'end-of-buffer))))
   . (prog1 'package-name
       (define-key global-map (kbd "C-t") #'other-window)
       (define-key global-map (kbd "C-n") #'next-window)
       (define-key prog-mode-map (kbd "M-a") #'beginning-of-buffer)
       (define-key prog-mode-map (kbd "M-e") #'end-of-buffer))))

(mic-ert-macroexpand-1 mic-define-key-after-load
  ((mic package-name
     :define-key-after-load
     ((c-mode-map
       ("C-t" . #'other-window)
       ("C-n" . #'next-window))
      (c++-mode-map
       ("M-a" . #'beginning-of-buffer)
       ("M-e" . #'end-of-buffer))))
   . (prog1 'package-name
       (with-eval-after-load 'package-name
         (define-key c-mode-map (kbd "C-t") #'other-window)
         (define-key c-mode-map (kbd "C-n") #'next-window)
         (define-key c++-mode-map (kbd "M-a") #'beginning-of-buffer)
         (define-key c++-mode-map (kbd "M-e") #'end-of-buffer)))))

(mic-ert-macroexpand-1 mic-define-key-with-feature
  ((mic package-name
     :define-key-with-feature
     ((cc-mode
       (c-mode-map
        ("C-t" . #'other-window)
        ("C-n" . #'next-window))
       (c++-mode-map
        ("M-a" . #'beginning-of-buffer)
        ("M-e" . #'end-of-buffer)))
      (python
       (python-mode-map
        ("C-t" . #'python-check)))))
   . (prog1 'package-name
       (with-eval-after-load 'cc-mode
         (define-key c-mode-map (kbd "C-t") #'other-window)
         (define-key c-mode-map (kbd "C-n") #'next-window)
         (define-key c++-mode-map (kbd "M-a") #'beginning-of-buffer)
         (define-key c++-mode-map (kbd "M-e") #'end-of-buffer))
       (with-eval-after-load 'python
         (define-key python-mode-map (kbd "C-t") #'python-check)))))

(mic-ert-macroexpand-1 mic-defvar-noninitial
  ((mic package-name
     :defvar-noninitial
     (skk-jisyo
      skk-use-azik))
   . (prog1 'package-name
       (defvar skk-jisyo)
       (defvar skk-use-azik))))

(mic-ert-macroexpand-1 mic-eval
  ((mic package-name
     :eval
     ((message "Hello")
      (message "World")))
   . (prog1 'package-name
       (message "Hello")
       (message "World"))))

(mic-ert-macroexpand-1 mic-eval-after-load
  ((mic package-name
     :eval-after-load
     ((message "Hello")
      (message "World")))
   . (prog1 'package-name
       (with-eval-after-load 'package-name
         (message "Hello")
         (message "World")))))

(mic-ert-macroexpand-1 mic-eval-after-others
  ((mic package-name
     :custom
     ((skk-jisyo . "~/skk-jisyo"))
     :eval
     ((message "before")
      (message "custom"))
     :eval-after-others
     ((message "after")
      (message "custom")))
   . (prog1 'package-name
       (message "before")
       (message "custom")
       (customize-set-variable
        'skk-jisyo
        "~/skk-jisyo")
       (message "after")
       (message "custom"))))

(mic-ert-macroexpand-1 mic-eval-after-others-after-load
  ((mic package-name
     :custom-after-load
     ((skk-jisyo . "~/skk-jisyo"))
     :eval-after-load
     ((message "before")
      (message "custom"))
     :eval-after-others-after-load
     ((message "after")
      (message "custom")))
   . (prog1 'package-name
       (with-eval-after-load 'package-name
         (message "before")
         (message "custom")
         (customize-set-variable
          'skk-jisyo
          "~/skk-jisyo")
         (message "after")
         (message "custom")))))

(mic-ert-macroexpand-1 mic-eval-before-all
  ((mic package-name
     :custom
     ((skk-jisyo . "~/skk-jisyo"))
     :eval
     ((message "before")
      (message "custom"))
     :eval-before-all
     ((message "before")
      (message "all")))
   . (prog1 'package-name
       (message "before")
       (message "all")
       (message "before")
       (message "custom")
       (customize-set-variable
        'skk-jisyo
        "~/skk-jisyo"))))

(mic-ert-macroexpand-1 mic-face
  ((mic package-name
     :face
     ((aw-leading-char-face
       . ((t (:foreground "red" :height 10.0))))
      (aw-mode-line-face
       . ((t (:background "#006000" :foreground "white" :bold t))))))
   . (prog1 'package-name
       (custom-set-faces
        '(aw-leading-char-face
          ((t (:foreground "red" :height 10.0))))
        '(aw-mode-line-face
          ((t (:background "#006000" :foreground "white" :bold t))))))))

(mic-ert-macroexpand-1 mic-hook
  ((mic package-name
     :hook
     ((after-init-hook . #'ignore)
      (prog-mode-hook . (lambda ()))))
   . (prog1 'package-name
       (add-hook 'after-init-hook #'ignore)
       (add-hook 'prog-mode-hook (lambda ())))))

(mic-ert-macroexpand-1 mic-package
  ((mic package-name
     :package
     (package-1
      package-2))
   . (prog1 'package-name
       (unless (package-installed-p 'package-1)
         (package-install 'package-1))
       (unless (package-installed-p 'package-2)
         (package-install 'package-2)))))



(ert-deftest mic--plist-put ()
  (let ((plist '(:foo 1 :bar 2)))
    (mic--plist-put plist :baz 3)
    (should (eq (plist-get plist :foo) 1))
    (should (eq (plist-get plist :bar) 2))
    (should (eq (plist-get plist :baz) 3)))

  (let (plist)
    (mic--plist-put plist :baz 3)
    (should (eq (plist-get plist :baz) 3))))

(ert-deftest mic--plist-put-append ()
  (let ((plist '(:foo 1 :bar 2)))
    (mic--plist-put-append plist :baz '(3))
    (should (eq (plist-get plist :foo) 1))
    (should (eq (plist-get plist :bar) 2))
    (should (equal (plist-get plist :baz) '(3))))

  (let ((plist '(:foo (1) :bar (2))))
    (mic--plist-put-append plist :bar '(3))
    (should (equal (plist-get plist :foo) '(1)))
    (should (equal (plist-get plist :bar) '(2 3))))

  (let (plist)
    (mic--plist-put-append plist :baz '(3))
    (should (equal (plist-get plist :baz) '(3)))))



(mic-ert-macroexpand-1 mic-deffilter-const-macroexpand-1
  ((mic-deffilter-const func-name
     :foo t
     :bar '(2 4))
   . (defun func-name (plist)
       "Filter for `mic'.
It return PLIST but each value on some property below is replaced:
(:foo t :bar
      '(2 4))
"
       (mic--plist-put plist :foo t)
       (mic--plist-put plist :bar '(2 4))
       plist))
  ((mic-deffilter-const func-name
     "docstring"
     :foo t
     :bar '(2 4))
   . (defun func-name (plist)
       "docstring"
       (mic--plist-put plist :foo t)
       (mic--plist-put plist :bar '(2 4))
       plist)))

(ert-deftest mic-deffilter-const ()
  (mic-deffilter-const mic-test-mic-deffilter-const
    :foo t
    :bar '(2 4))

  (let* ((init '(:foo 1 :bar 2))
         (result (mic-test-mic-deffilter-const init)))
    (should (equal (plist-get result :foo) t))
    (should (equal (plist-get result :bar) '(2 4)))))

(mic-ert-macroexpand-1 mic-deffilter-const-append-macroexpand-1
  ((mic-deffilter-const-append func-name
     :foo '(t)
     :bar '(2 4))
   . (defun func-name (plist)
       "Filter for `mic'.
It return PLIST but each value on some property below is appended:
(:foo
 '(t)
 :bar
 '(2 4))
"
       (mic--plist-put-append plist :foo
                              '(t))
       (mic--plist-put-append plist :bar
                              '(2 4))
       plist))
  ((mic-deffilter-const-append func-name
     "docstring"
     :foo '(t)
     :bar '(2 4))
   . (defun func-name (plist)
       "docstring"
       (mic--plist-put-append plist :foo '(t))
       (mic--plist-put-append plist :bar '(2 4))
       plist)))

(ert-deftest mic-deffilter-const-append ()
  (mic-deffilter-const-append mic-test-mic-deffilter-const-append
    :foo '(t)
    :bar '(3 4))

  (let* ((init '(:foo (1) :bar (2)))
         (result (mic-test-mic-deffilter-const-append init)))
    (should (equal (plist-get result :foo) '(1 t)))
    (should (equal (plist-get result :bar) '(2 3 4)))))

(provide 'mic-test)
;;; mic-test.el ends here
