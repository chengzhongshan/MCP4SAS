/* G2405 macro_euclid_loop, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2405m(); %local a b r; %let a=6; %let b=8;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2405o; actual=&a; run;
%mend; %g2405m(); %sysmacdelete g2405m;

data _null_; if 0 then set g2405o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2405 rows=' rows;
else do; set g2405o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2405';
else put 'ERROR: ROUND5_FAIL=G2405 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2405:; quit;
