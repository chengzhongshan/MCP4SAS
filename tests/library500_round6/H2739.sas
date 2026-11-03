/* H2739 notdigit_position, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_the_double_at_to_read_the_2nd_line_and_compare_with_previous_line.sas:11 */

data h2739o; length text $40; text=repeat('1',10-1)||'x'; actual=notdigit(text); run;

data _null_; if 0 then set h2739o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2739 rows=' rows;
else do; set h2739o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2739';
else put 'ERROR: ROUND6_FAIL=H2739 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2739:; quit;
