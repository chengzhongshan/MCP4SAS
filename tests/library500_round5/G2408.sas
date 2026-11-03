/* G2408 macro_euclid_loop, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2408m(); %local a b r; %let a=9; %let b=11;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2408o; actual=&a; run;
%mend; %g2408m(); %sysmacdelete g2408m;

data _null_; if 0 then set g2408o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2408 rows=' rows;
else do; set g2408o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2408';
else put 'ERROR: ROUND5_FAIL=G2408 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2408:; quit;
