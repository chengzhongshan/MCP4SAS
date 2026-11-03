/* G2409 macro_euclid_loop, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2409m(); %local a b r; %let a=10; %let b=12;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2409o; actual=&a; run;
%mend; %g2409m(); %sysmacdelete g2409m;

data _null_; if 0 then set g2409o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2409 rows=' rows;
else do; set g2409o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2409';
else put 'ERROR: ROUND5_FAIL=G2409 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2409:; quit;
