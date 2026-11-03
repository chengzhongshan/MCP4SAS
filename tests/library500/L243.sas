/* L243: left boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B2');
if actual='B2' and lengthn(actual)=2 then put 'LIB500_PASS=L243';
else put 'ERROR: LIB500_FAIL=L243 actual=' actual;
run;
