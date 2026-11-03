/* G2171 sort_noduprecs, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2171a; do k=1 to 2; value=1; output; output; value=2; output; end; run;
proc sort data=g2171a out=g2171b noduprecs; by _all_; run;
proc sql; create table g2171o as select count(*) as actual from g2171b; quit;

data _null_; if 0 then set g2171o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2171 rows=' rows;
else do; set g2171o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2171';
else put 'ERROR: ROUND5_FAIL=G2171 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2171:; quit;
