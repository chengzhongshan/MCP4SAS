/* G2152 indexed_set_key, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2152a; do k=1 to 3; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2152a; index create k; quit;
data g2152b; do k=3 to 1 by -1; output; end; run;
data g2152c; set g2152b; set g2152a key=k; if _iorc_=0; run;
proc sql; create table g2152o as select sum(value) as actual from g2152c; quit;

data _null_; if 0 then set g2152o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2152 rows=' rows;
else do; set g2152o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND5_PASS=G2152';
else put 'ERROR: ROUND5_FAIL=G2152 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2152:; quit;
