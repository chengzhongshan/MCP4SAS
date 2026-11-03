/* L402: datepart boundary 1; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+86400);
if not missing(actual) and abs(actual-(21916)) <= 1e-11*max(1,abs(21916)) then put 'LIB500_PASS=L402';
else put 'ERROR: LIB500_FAIL=L402 actual=' actual;
run;
