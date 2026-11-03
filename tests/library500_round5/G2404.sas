/* G2404 macro_euclid_loop, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2404m(); %local a b r; %let a=5; %let b=7;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2404o; actual=&a; run;
%mend; %g2404m(); %sysmacdelete g2404m;

data _null_; if 0 then set g2404o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2404 rows=' rows;
else do; set g2404o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2404';
else put 'ERROR: ROUND5_FAIL=G2404 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2404:; quit;
