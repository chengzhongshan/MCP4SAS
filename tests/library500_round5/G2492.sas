/* G2492 failure_format_overlap, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2492f 1-5='first' 3-6='second'; run;
data _null_; if cexist('work.formats.g2492f.format') then call execute('proc catalog catalog=work.formats; delete g2492f.format; quit;'); run;

proc datasets library=work nolist; delete g2492:; quit;
