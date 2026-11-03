/* L257: reverse boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab6Z');
if actual='Z6ba' and lengthn(actual)=4 then put 'LIB500_PASS=L257';
else put 'ERROR: LIB500_FAIL=L257 actual=' actual;
run;
