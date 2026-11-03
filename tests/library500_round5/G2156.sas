/* G2156 indexed_set_key, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2156a; do k=1 to 7; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2156a; index create k; quit;
data g2156b; do k=7 to 1 by -1; output; end; run;
data g2156c; set g2156b; set g2156a key=k; if _iorc_=0; run;
proc sql; create table g2156o as select sum(value) as actual from g2156c; quit;

data _null_; if 0 then set g2156o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2156 rows=' rows;
else do; set g2156o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND5_PASS=G2156';
else put 'ERROR: ROUND5_FAIL=G2156 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2156:; quit;
