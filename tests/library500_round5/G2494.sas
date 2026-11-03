/* G2494 failure_format_overlap, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2494f 1-7='first' 5-10='second'; run;
data _null_; if cexist('work.formats.g2494f.format') then call execute('proc catalog catalog=work.formats; delete g2494f.format; quit;'); run;

proc datasets library=work nolist; delete g2494:; quit;
