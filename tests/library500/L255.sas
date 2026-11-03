/* L255: reverse boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab4Z');
if actual='Z4ba' and lengthn(actual)=4 then put 'LIB500_PASS=L255';
else put 'ERROR: LIB500_FAIL=L255 actual=' actual;
run;
