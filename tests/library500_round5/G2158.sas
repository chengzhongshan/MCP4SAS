/* G2158 indexed_set_key, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2158a; do k=1 to 9; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2158a; index create k; quit;
data g2158b; do k=9 to 1 by -1; output; end; run;
data g2158c; set g2158b; set g2158a key=k; if _iorc_=0; run;
proc sql; create table g2158o as select sum(value) as actual from g2158c; quit;

data _null_; if 0 then set g2158o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2158 rows=' rows;
else do; set g2158o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND5_PASS=G2158';
else put 'ERROR: ROUND5_FAIL=G2158 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2158:; quit;
