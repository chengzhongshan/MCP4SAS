/* G2155 indexed_set_key, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop4tree_branches.sas:48 */

data g2155a; do k=1 to 6; value=k*k; output; end; run;
proc datasets library=work nolist; modify g2155a; index create k; quit;
data g2155b; do k=6 to 1 by -1; output; end; run;
data g2155c; set g2155b; set g2155a key=k; if _iorc_=0; run;
proc sql; create table g2155o as select sum(value) as actual from g2155c; quit;

data _null_; if 0 then set g2155o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2155 rows=' rows;
else do; set g2155o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND5_PASS=G2155';
else put 'ERROR: ROUND5_FAIL=G2155 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2155:; quit;
