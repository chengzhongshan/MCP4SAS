/* H2853 frewind_read_again, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename rtemp temp;
data _null_; file rtemp; put '4'; put '5'; run;
data h2853o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;

data _null_; if 0 then set h2853o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2853 rows=' rows;
else do; set h2853o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2853';
else put 'ERROR: ROUND6_FAIL=H2853 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2853:; quit;
