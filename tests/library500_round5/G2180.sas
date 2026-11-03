/* G2180 sort_noduprecs, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2180a; do k=1 to 11; value=1; output; output; value=2; output; end; run;
proc sort data=g2180a out=g2180b noduprecs; by _all_; run;
proc sql; create table g2180o as select count(*) as actual from g2180b; quit;

data _null_; if 0 then set g2180o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2180 rows=' rows;
else do; set g2180o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND5_PASS=G2180';
else put 'ERROR: ROUND5_FAIL=G2180 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2180:; quit;
