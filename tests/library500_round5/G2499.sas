/* G2499 failure_format_overlap, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2499f 1-12='first' 10-20='second'; run;
data _null_; if cexist('work.formats.g2499f.format') then call execute('proc catalog catalog=work.formats; delete g2499f.format; quit;'); run;

proc datasets library=work nolist; delete g2499:; quit;
