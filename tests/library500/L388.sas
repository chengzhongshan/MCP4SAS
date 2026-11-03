/* L388: count boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('abababababababZ','ab');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L388';
else put 'ERROR: LIB500_FAIL=L388 actual=' actual;
run;
