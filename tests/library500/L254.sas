/* L254: reverse boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab3Z');
if actual='Z3ba' and lengthn(actual)=4 then put 'LIB500_PASS=L254';
else put 'ERROR: LIB500_FAIL=L254 actual=' actual;
run;
