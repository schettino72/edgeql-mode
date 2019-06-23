;; define hook to allow users to run their code when mode is run
(defvar edgeql-mode-hook nil)

;; create keymap
(defvar edgeql-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for EdgeQL major mode")

;; automatically associate buffers with .eql files to this mode
(add-to-list 'auto-mode-alist '("\\.eql\\'" . edgeql-mode))


;; Syntax highlight for keywords

;;; (not categorized yet)

;;; reserved_keywords
;; "__source__" "__subject__" "__type__" "analyze" "and" "anyarray"
;; "anytuple" "anytype" "begin" "case" "check" "configure"
;; "deallocate" "detached" "discard" "distinct" "do" "drop"
;; "else" "empty" "end" "execute" "exists" "explain" "fetch"
;; "function" "get" "global" "grant" "group" "if" "ilike"
;; "import" "in" "is" "like" "limit" "listen" "load"
;; "lock" "match" "move" "not" "notify" "offset" "optional" "or"
;; "order" "over" "partition" "policy" "prepare" "raise" "refresh" "reindex"
;; "revoke" "typeof" "union" "variadic" "when" "window"

;;;     unreserved_keywords
;; "after" "all" "allow" "as" "asc"
;; "assignment" "before" "by" "cardinality" "cast" "config"
;; "database" "default" "deferrable" "deferred" "delegated" "desc" "explicit"
;; "expression" "final" "first" "from" "implicit" "infix" "inheritable"
;; "inherited" "into" "isolation" "last" "named" "of"
;; "on" "only" "operator" "postfix" "prefix" "read" "rename"
;; "repeatable" "required" "restrict" "scalar" "serializable"
;; "session" "single" "source" "system" "target" "ternary" "then" "to"
;; "transaction" "using"  "write"



(setq edgeql-keywords-statements
      '("create"  "alter"
        "select" "for" "insert" "update" "delete" "with" "introspect"
        "start" "commit" "rollback"  "declare" "release" "savepoint"
        "set" "reset" "filter"))
(setq edgeql-keywords-types
      '("type" "property" "link" "migration" "view" "role" "alias" "module"
        "index" "annotation" "constraint"))
(setq edgeql-keywords-mod '("required" "multi" "extending" "abstract"))

(setq edgeql-type-builtins
      '("Object" "anyenum" "anyfloat" "anyint" "anyreal" "anyscalar" "array"
        "bool" "bytes" "datetime" "decimal" "duration" "enum" "float32"
        "float64" "int16" "int32" "int64" "json" "local_date" "local_datetime"
        "local_time" "sequence" "str" "tuple" "uuid"))
(setq edgeql-operators
      '("->" "!=" "%" "*" "+" "++" "-" "/" "//" ":=" "<" "<=" "=" ">" ">="
        "?!=" "?=" "??" "^"))


(setq edgeql-font-lock-keywords
      (list
       (cons (regexp-opt (mapcar 'upcase edgeql-keywords-statements) t) font-lock-keyword-face)
       (cons (regexp-opt (mapcar 'upcase edgeql-keywords-types) t) font-lock-type-face)
       (cons (regexp-opt edgeql-keywords-mod t) font-lock-preprocessor-face)
       (cons (regexp-opt edgeql-type-builtins t) font-lock-builtin-face)
       (cons (regexp-opt edgeql-operators t) font-lock-constant-face)
       ))


;; indentation
(defvar edgeql-indent-offset 4)

(defun edgeql-indent-line ()
  "Indent current line as EdgeQL code"
  (interactive)
  (beginning-of-line)
  (if (bobp) ; beginning of the buffer (first line of buffer)
      (indent-line-to 0)
    ;; cur-indent is the intended indentation level for this line
    (let (cur-indent)
      ;; de-indent current line if contains a closing block `}`
      (if (looking-at "^[ \t]*[})]")
          (progn
            (save-excursion
              (forward-line -1) ; go to previoust line
              (setq cur-indent (- (current-indentation) edgeql-indent-offset)))
            (if (< cur-indent 0) ; safety check
                (setq cur-indent 0)))
        ;; if previous line has a `{` increase indent
        (save-excursion
          (forward-line -1)
          (if (looking-at ".*[{(]$")
              (setq cur-indent (+ (current-indentation) edgeql-indent-offset))
            ;; keep indentation from previous line
            (setq cur-indent (current-indentation)))))
      ;; move indentation line
      (indent-line-to cur-indent))))

(defvar edgeql-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    st)
  "Syntax table for edgeql-mode")


;; automatically upcase keywords
(setq edgeql-autocap-words
      (concat "\\<"
              (regexp-opt (append edgeql-keywords-statements  edgeql-keywords-types) t)
              "\\>[^[:alnum:]_]"))

(defun edgeql-upcase-keywords ()
  (when (looking-back edgeql-autocap-words)
    (upcase-word -1)))


(defun edgeql-mode ()
  "Major mode for editing EdgeQL files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table edgeql-mode-syntax-table)
  (use-local-map edgeql-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(edgeql-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'edgeql-indent-line)

  (add-hook 'post-self-insert-hook 'edgeql-upcase-keywords nil t)
  (setq major-mode 'edgeql-mode)
  (setq mode-name "EdgeQL")
  (run-hooks 'edgeql-mode-hook))


(provide 'edgeql-mode)


;;; debug looking-at
;; (defun lkat ()
;;   "interactive looking at"
;;   (interactive)
;;   (if (looking-at ".*{")
;;       (message "yes")
;;     (message "no")))
