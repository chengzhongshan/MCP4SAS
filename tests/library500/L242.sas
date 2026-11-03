/* L242: left boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B1');
if actual='B1' and lengthn(actual)=2 then put 'LIB500_PASS=L242';
else put 'ERROR: LIB500_FAIL=L242 actual=' actual;
run;
