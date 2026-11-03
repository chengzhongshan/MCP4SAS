/* L404: datepart boundary 3; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+259200);
if not missing(actual) and abs(actual-(21918)) <= 1e-11*max(1,abs(21918)) then put 'LIB500_PASS=L404';
else put 'ERROR: LIB500_FAIL=L404 actual=' actual;
run;
