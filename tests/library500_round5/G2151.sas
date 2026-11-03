/* G2151 indexed_set_key, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2151a; do k=1 to 2; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2151a; index create k; quit;
data g2151b; do k=2 to 1 by -1; output; end; run;
data g2151c; set g2151b; set g2151a key=k; if _iorc_=0; run;
proc sql; create table g2151o as select sum(value) as actual from g2151c; quit;

data _null_; if 0 then set g2151o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2151 rows=' rows;
else do; set g2151o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2151';
else put 'ERROR: ROUND5_FAIL=G2151 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2151:; quit;
