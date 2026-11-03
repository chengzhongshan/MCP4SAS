/* L347: catx boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/CAT CATX for Linking variables to create new one in PROC SQL.sas:3 */
data _null_;
length actual $256;
actual=catx('|',' a ',' ',' 6 ',' b ');
if actual='a|6|b' and lengthn(actual)=5 then put 'LIB500_PASS=L347';
else put 'ERROR: LIB500_FAIL=L347 actual=' actual;
run;
