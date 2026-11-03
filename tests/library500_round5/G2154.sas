/* G2154 indexed_set_key, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2154a; do k=1 to 5; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2154a; index create k; quit;
data g2154b; do k=5 to 1 by -1; output; end; run;
data g2154c; set g2154b; set g2154a key=k; if _iorc_=0; run;
proc sql; create table g2154o as select sum(value) as actual from g2154c; quit;

data _null_; if 0 then set g2154o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2154 rows=' rows;
else do; set g2154o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND5_PASS=G2154';
else put 'ERROR: ROUND5_FAIL=G2154 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2154:; quit;
