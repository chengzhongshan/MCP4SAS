/* G2401 macro_euclid_loop, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2401m(); %local a b r; %let a=2; %let b=4;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2401o; actual=&a; run;
%mend; %g2401m(); %sysmacdelete g2401m;

data _null_; if 0 then set g2401o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2401 rows=' rows;
else do; set g2401o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2401';
else put 'ERROR: ROUND5_FAIL=G2401 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2401:; quit;
