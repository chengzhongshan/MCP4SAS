/* L314: tranwrd boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-3-one','one','two');
if actual='two-3-two' and lengthn(actual)=9 then put 'LIB500_PASS=L314';
else put 'ERROR: LIB500_FAIL=L314 actual=' actual;
run;
