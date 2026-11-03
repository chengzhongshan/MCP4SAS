/* G2175 sort_noduprecs, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2175a; do k=1 to 6; value=1; output; output; value=2; output; end; run;
proc sort data=g2175a out=g2175b noduprecs; by _all_; run;
proc sql; create table g2175o as select count(*) as actual from g2175b; quit;

data _null_; if 0 then set g2175o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2175 rows=' rows;
else do; set g2175o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2175';
else put 'ERROR: ROUND5_FAIL=G2175 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2175:; quit;
