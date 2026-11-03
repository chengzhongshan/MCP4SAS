/* L256: reverse boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab5Z');
if actual='Z5ba' and lengthn(actual)=4 then put 'LIB500_PASS=L256';
else put 'ERROR: LIB500_FAIL=L256 actual=' actual;
run;
