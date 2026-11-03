/* L439: prxmatch boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:4 */
%let l500_prx=%sysfunc(prxmatch(/[a\/]*\//,aa/));
data _null_;
actual=&l500_prx;
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L439';
else put 'ERROR: LIB500_FAIL=L439 actual=' actual;
run;
