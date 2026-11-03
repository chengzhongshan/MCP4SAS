/* L246: left boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B5');
if actual='B5' and lengthn(actual)=2 then put 'LIB500_PASS=L246';
else put 'ERROR: LIB500_FAIL=L246 actual=' actual;
run;
