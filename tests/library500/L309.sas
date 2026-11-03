/* L309: compress boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 8 b ');
if actual='a8b' and lengthn(actual)=3 then put 'LIB500_PASS=L309';
else put 'ERROR: LIB500_FAIL=L309 actual=' actual;
run;
