/* J3992 failure_format_reversed_range, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3992fmt 4-3='reversed'; run;
proc catalog catalog=work.formats; delete j3992fmt.format; quit;

proc datasets library=work nolist; delete j3992:; quit;
