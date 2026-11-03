/* L244: left boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B3');
if actual='B3' and lengthn(actual)=2 then put 'LIB500_PASS=L244';
else put 'ERROR: LIB500_FAIL=L244 actual=' actual;
run;
