/* L403: datepart boundary 2; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+172800);
if not missing(actual) and abs(actual-(21917)) <= 1e-11*max(1,abs(21917)) then put 'LIB500_PASS=L403';
else put 'ERROR: LIB500_FAIL=L403 actual=' actual;
run;
