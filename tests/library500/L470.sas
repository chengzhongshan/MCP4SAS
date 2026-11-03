/* L470: input boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('026',3.);
if not missing(actual) and abs(actual-(26)) <= 1e-11*max(1,abs(26)) then put 'LIB500_PASS=L470';
else put 'ERROR: LIB500_FAIL=L470 actual=' actual;
run;
