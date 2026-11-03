/* G2497 failure_format_overlap, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2497f 1-10='first' 8-16='second'; run;
data _null_; if cexist('work.formats.g2497f.format') then call execute('proc catalog catalog=work.formats; delete g2497f.format; quit;'); run;

proc datasets library=work nolist; delete g2497:; quit;
