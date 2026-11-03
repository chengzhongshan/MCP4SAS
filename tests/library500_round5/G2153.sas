/* G2153 indexed_set_key, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2153a; do k=1 to 4; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2153a; index create k; quit;
data g2153b; do k=4 to 1 by -1; output; end; run;
data g2153c; set g2153b; set g2153a key=k; if _iorc_=0; run;
proc sql; create table g2153o as select sum(value) as actual from g2153c; quit;

data _null_; if 0 then set g2153o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2153 rows=' rows;
else do; set g2153o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND5_PASS=G2153';
else put 'ERROR: ROUND5_FAIL=G2153 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2153:; quit;
