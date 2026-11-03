/* J3999 failure_format_reversed_range, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3999fmt 11-10='reversed'; run;
proc catalog catalog=work.formats; delete j3999fmt.format; quit;

proc datasets library=work nolist; delete j3999:; quit;
