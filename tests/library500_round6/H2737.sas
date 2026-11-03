/* H2737 notdigit_position, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_the_double_at_to_read_the_2nd_line_and_compare_with_previous_line.sas:11 */

data h2737o; length text $40; text=repeat('1',8-1)||'x'; actual=notdigit(text); run;

data _null_; if 0 then set h2737o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2737 rows=' rows;
else do; set h2737o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2737';
else put 'ERROR: ROUND6_FAIL=H2737 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2737:; quit;
