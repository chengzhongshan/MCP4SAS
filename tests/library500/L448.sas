/* L448: prxchange boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */
%let l500_prx=%sysfunc(prxchange(s/[a\/]*/X/,1,aaaaaaaaz));
data _null_;
length actual $256;
actual="&l500_prx";
if actual='Xz' and lengthn(actual)=2 then put 'LIB500_PASS=L448';
else put 'ERROR: LIB500_FAIL=L448 actual=' actual;
run;
