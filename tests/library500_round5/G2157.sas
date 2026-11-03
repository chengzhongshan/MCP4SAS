/* G2157 indexed_set_key, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2157a; do k=1 to 8; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2157a; index create k; quit;
data g2157b; do k=8 to 1 by -1; output; end; run;
data g2157c; set g2157b; set g2157a key=k; if _iorc_=0; run;
proc sql; create table g2157o as select sum(value) as actual from g2157c; quit;

data _null_; if 0 then set g2157o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2157 rows=' rows;
else do; set g2157o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND5_PASS=G2157';
else put 'ERROR: ROUND5_FAIL=G2157 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2157:; quit;
