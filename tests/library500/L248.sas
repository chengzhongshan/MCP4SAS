/* L248: left boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B7');
if actual='B7' and lengthn(actual)=2 then put 'LIB500_PASS=L248';
else put 'ERROR: LIB500_FAIL=L248 actual=' actual;
run;
