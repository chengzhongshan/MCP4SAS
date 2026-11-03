/* G2406 macro_euclid_loop, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2406m(); %local a b r; %let a=7; %let b=9;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2406o; actual=&a; run;
%mend; %g2406m(); %sysmacdelete g2406m;

data _null_; if 0 then set g2406o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2406 rows=' rows;
else do; set g2406o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2406';
else put 'ERROR: ROUND5_FAIL=G2406 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2406:; quit;
