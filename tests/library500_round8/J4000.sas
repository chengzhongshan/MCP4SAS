/* J4000 failure_format_reversed_range, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j4000fmt 12-11='reversed'; run;
proc catalog catalog=work.formats; delete j4000fmt.format; quit;

proc datasets library=work nolist; delete j4000:; quit;
