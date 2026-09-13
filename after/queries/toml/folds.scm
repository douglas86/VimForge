;; Fold table, pulling the end row back by 1 line so line 5 stays open
((table) @fold
 (#offset! @fold 0 0 -1 0))

((table_array_element) @fold
 (#offset! @fold 0 0 -1 0))
