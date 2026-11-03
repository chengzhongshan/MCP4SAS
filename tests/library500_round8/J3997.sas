/* J3997 failure_format_reversed_range, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3997fmt 9-8='reversed'; run;
proc catalog catalog=work.formats; delete j3997fmt.format; quit;

proc datasets library=work nolist; delete j3997:; quit;
