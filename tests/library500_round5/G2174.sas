/* G2174 sort_noduprecs, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2174a; do k=1 to 5; value=1; output; output; value=2; output; end; run;
proc sort data=g2174a out=g2174b noduprecs; by _all_; run;
proc sql; create table g2174o as select count(*) as actual from g2174b; quit;

data _null_; if 0 then set g2174o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2174 rows=' rows;
else do; set g2174o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2174';
else put 'ERROR: ROUND5_FAIL=G2174 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2174:; quit;
