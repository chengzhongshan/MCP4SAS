/* K4534 failure_invalid_sysevalf_conversion, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4534v=%sysevalf(5+0.5,not_a_conversion); %symdel k4534v / nowarn;

proc datasets library=work nolist; delete k4534:; quit;
