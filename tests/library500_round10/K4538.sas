/* K4538 failure_invalid_sysevalf_conversion, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4538v=%sysevalf(9+0.5,not_a_conversion); %symdel k4538v / nowarn;

proc datasets library=work nolist; delete k4538:; quit;
