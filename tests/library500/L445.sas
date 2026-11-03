/* L445: prxchange boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */
%let l500_prx=%sysfunc(prxchange(s/[a\/]*/X/,1,aaaaaz));
data _null_;
length actual $256;
actual="&l500_prx";
if actual='Xz' and lengthn(actual)=2 then put 'LIB500_PASS=L445';
else put 'ERROR: LIB500_FAIL=L445 actual=' actual;
run;
