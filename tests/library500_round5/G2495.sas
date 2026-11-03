/* G2495 failure_format_overlap, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2495f 1-8='first' 6-12='second'; run;
data _null_; if cexist('work.formats.g2495f.format') then call execute('proc catalog catalog=work.formats; delete g2495f.format; quit;'); run;

proc datasets library=work nolist; delete g2495:; quit;
