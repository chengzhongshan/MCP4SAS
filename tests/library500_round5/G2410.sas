/* G2410 macro_euclid_loop, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:7 */

%macro g2410m(); %local a b r; %let a=11; %let b=13;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data g2410o; actual=&a; run;
%mend; %g2410m(); %sysmacdelete g2410m;

data _null_; if 0 then set g2410o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2410 rows=' rows;
else do; set g2410o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2410';
else put 'ERROR: ROUND5_FAIL=G2410 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2410:; quit;
