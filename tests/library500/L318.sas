/* L318: tranwrd boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-7-one','one','two');
if actual='two-7-two' and lengthn(actual)=9 then put 'LIB500_PASS=L318';
else put 'ERROR: LIB500_FAIL=L318 actual=' actual;
run;
