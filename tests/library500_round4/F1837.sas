/* F1837 rank_groups_balanced, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1837a; do x=1 to 2*8; output; end; run;
proc rank data=f1837a out=f1837b groups=2; var x; ranks bin; run;
proc sql; create table f1837o as select sum(bin) as actual from f1837b; quit;

data _null_; if 0 then set f1837o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1837 rows=' rows;
else do; set f1837o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1837';
else put 'ERROR: ROUND4_FAIL=F1837 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1837:; quit;
