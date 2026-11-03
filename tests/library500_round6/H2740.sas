/* H2740 notdigit_position, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_the_double_at_to_read_the_2nd_line_and_compare_with_previous_line.sas:11 */

data h2740o; length text $40; text=repeat('1',11-1)||'x'; actual=notdigit(text); run;

data _null_; if 0 then set h2740o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2740 rows=' rows;
else do; set h2740o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2740';
else put 'ERROR: ROUND6_FAIL=H2740 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2740:; quit;
