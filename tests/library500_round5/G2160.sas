/* G2160 indexed_set_key, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2160a; do k=1 to 11; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2160a; index create k; quit;
data g2160b; do k=11 to 1 by -1; output; end; run;
data g2160c; set g2160b; set g2160a key=k; if _iorc_=0; run;
proc sql; create table g2160o as select sum(value) as actual from g2160c; quit;

data _null_; if 0 then set g2160o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2160 rows=' rows;
else do; set g2160o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND5_PASS=G2160';
else put 'ERROR: ROUND5_FAIL=G2160 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2160:; quit;
