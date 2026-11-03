/* H2732 notdigit_position, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_the_double_at_to_read_the_2nd_line_and_compare_with_previous_line.sas:11 */

data h2732o; length text $40; text=repeat('1',3-1)||'x'; actual=notdigit(text); run;

data _null_; if 0 then set h2732o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2732 rows=' rows;
else do; set h2732o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2732';
else put 'ERROR: ROUND6_FAIL=H2732 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2732:; quit;
