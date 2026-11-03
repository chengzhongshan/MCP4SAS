/* G2402 macro_euclid_loop, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2402m(); %local a b r; %let a=3; %let b=5;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2402o; actual=&a; run;
%mend; %g2402m(); %sysmacdelete g2402m;

data _null_; if 0 then set g2402o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2402 rows=' rows;
else do; set g2402o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2402';
else put 'ERROR: ROUND5_FAIL=G2402 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2402:; quit;
