/* L344: catx boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/CAT CATX for Linking variables to create new one in PROC SQL.sas:3 */
data _null_;
length actual $256;
actual=catx('|',' a ',' ',' 3 ',' b ');
if actual='a|3|b' and lengthn(actual)=5 then put 'LIB500_PASS=L344';
else put 'ERROR: LIB500_FAIL=L344 actual=' actual;
run;
