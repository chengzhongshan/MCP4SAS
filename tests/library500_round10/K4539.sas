/* K4539 failure_invalid_sysevalf_conversion, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4539v=%sysevalf(10+0.5,not_a_conversion); %symdel k4539v / nowarn;

proc datasets library=work nolist; delete k4539:; quit;
