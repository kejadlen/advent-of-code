(fn dbg [tbl]
  (each [_ chunk (ipairs tbl)]
    (print (accumulate [x "" _ i (ipairs chunk)]
             (.. x ", " i)))))

(local input (accumulate [input [[]] line (io.lines :../day_01.txt)]
               (do
                 (if (= (length line) 0)
                     (table.insert input [])
                     (table.insert (. input (length input)) (tonumber line)))
                 input)))

(fn sum [l]
  (accumulate [sum 0 _ n (ipairs l)]
    (+ sum n)))

(local l (icollect [_ l (ipairs input)] (sum l)))
(table.sort l)
(print (. l (length l)))
