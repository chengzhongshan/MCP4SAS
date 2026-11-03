/* J3995 failure_format_reversed_range, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3995fmt 7-6='reversed'; run;
proc catalog catalog=work.formats; delete j3995fmt.format; quit;

proc datasets library=work nolist; delete j3995:; quit;
