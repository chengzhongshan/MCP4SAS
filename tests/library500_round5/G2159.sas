/* G2159 indexed_set_key, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2159a; do k=1 to 10; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2159a; index create k; quit;
data g2159b; do k=10 to 1 by -1; output; end; run;
data g2159c; set g2159b; set g2159a key=k; if _iorc_=0; run;
proc sql; create table g2159o as select sum(value) as actual from g2159c; quit;

data _null_; if 0 then set g2159o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2159 rows=' rows;
else do; set g2159o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND5_PASS=G2159';
else put 'ERROR: ROUND5_FAIL=G2159 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2159:; quit;
