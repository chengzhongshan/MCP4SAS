/* L409: datepart boundary 8; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+691200);
if not missing(actual) and abs(actual-(21923)) <= 1e-11*max(1,abs(21923)) then put 'LIB500_PASS=L409';
else put 'ERROR: LIB500_FAIL=L409 actual=' actual;
run;
