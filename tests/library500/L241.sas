/* L241: left boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B0');
if actual='B0' and lengthn(actual)=2 then put 'LIB500_PASS=L241';
else put 'ERROR: LIB500_FAIL=L241 actual=' actual;
run;
