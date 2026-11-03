/* L258: reverse boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab7Z');
if actual='Z7ba' and lengthn(actual)=4 then put 'LIB500_PASS=L258';
else put 'ERROR: LIB500_FAIL=L258 actual=' actual;
run;
