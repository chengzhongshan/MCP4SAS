/* L345: catx boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/CAT CATX for Linking variables to create new one in PROC SQL.sas:3 */
data _null_;
length actual $256;
actual=catx('|',' a ',' ',' 4 ',' b ');
if actual='a|4|b' and lengthn(actual)=5 then put 'LIB500_PASS=L345';
else put 'ERROR: LIB500_FAIL=L345 actual=' actual;
run;
