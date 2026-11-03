/* L311: tranwrd boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-0-one','one','two');
if actual='two-0-two' and lengthn(actual)=9 then put 'LIB500_PASS=L311';
else put 'ERROR: LIB500_FAIL=L311 actual=' actual;
run;
