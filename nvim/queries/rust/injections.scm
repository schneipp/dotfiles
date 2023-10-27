; (macro_invocation
;   (scoped_identifier
;     path: (identifier) @_path (#eq? @_path "sqlx")
;     name: (identifier) @_name (#eq? @_name "query")
;     (token_tree
; 	(raw_string_literal) @sql)
;     (#offset! @sql 1 0 0 0))
; )

;;(string_literal) @value (#offset! @sql 0 1 0 -1)
([
   (string_literal)
   (raw_string_literal)
 ] @sql
 (#match? @sql "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
 (#offset! @sql 0 1 0 -1))
