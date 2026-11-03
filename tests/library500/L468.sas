/* L468: input boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('024',3.);
if not missing(actual) and abs(actual-(24)) <= 1e-11*max(1,abs(24)) then put 'LIB500_PASS=L468';
else put 'ERROR: LIB500_FAIL=L468 actual=' actual;
run;
