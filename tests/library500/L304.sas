/* L304: compress boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 3 b ');
if actual='a3b' and lengthn(actual)=3 then put 'LIB500_PASS=L304';
else put 'ERROR: LIB500_FAIL=L304 actual=' actual;
run;
