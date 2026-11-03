/* L447: prxchange boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:4 */
%let l500_prx=%sysfunc(prxchange(s/[a\/]*/X/,1,aaaaaaaz));
data _null_;
length actual $256;
actual="&l500_prx";
if actual='Xz' and lengthn(actual)=2 then put 'LIB500_PASS=L447';
else put 'ERROR: LIB500_FAIL=L447 actual=' actual;
run;
