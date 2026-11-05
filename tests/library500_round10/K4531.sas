/* K4531 failure_invalid_sysevalf_conversion, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4531v=%sysevalf(2+0.5,not_a_conversion); %symdel k4531v / nowarn;

proc datasets library=work nolist; delete k4531:; quit;
