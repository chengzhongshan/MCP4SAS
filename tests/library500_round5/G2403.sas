/* G2403 macro_euclid_loop, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2403m(); %local a b r; %let a=4; %let b=6;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2403o; actual=&a; run;
%mend; %g2403m(); %sysmacdelete g2403m;

data _null_; if 0 then set g2403o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2403 rows=' rows;
else do; set g2403o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2403';
else put 'ERROR: ROUND5_FAIL=G2403 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2403:; quit;
