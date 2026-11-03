/* G2176 sort_noduprecs, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2176a; do k=1 to 7; value=1; output; output; value=2; output; end; run;
proc sort data=g2176a out=g2176b noduprecs; by _all_; run;
proc sql; create table g2176o as select count(*) as actual from g2176b; quit;

data _null_; if 0 then set g2176o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2176 rows=' rows;
else do; set g2176o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND5_PASS=G2176';
else put 'ERROR: ROUND5_FAIL=G2176 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2176:; quit;
