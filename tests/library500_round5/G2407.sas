/* G2407 macro_euclid_loop, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2407m(); %local a b r; %let a=8; %let b=10;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2407o; actual=&a; run;
%mend; %g2407m(); %sysmacdelete g2407m;

data _null_; if 0 then set g2407o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2407 rows=' rows;
else do; set g2407o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2407';
else put 'ERROR: ROUND5_FAIL=G2407 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2407:; quit;
