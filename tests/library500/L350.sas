/* L350: catx boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/CAT CATX for Linking variables to create new one in PROC SQL.sas:3 */
data _null_;
length actual $256;
actual=catx('|',' a ',' ',' 9 ',' b ');
if actual='a|9|b' and lengthn(actual)=5 then put 'LIB500_PASS=L350';
else put 'ERROR: LIB500_FAIL=L350 actual=' actual;
run;
