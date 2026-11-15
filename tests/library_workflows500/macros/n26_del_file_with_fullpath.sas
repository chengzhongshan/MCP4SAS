/* Test-only namespaced definition from del_file_with_fullpath.sas; original SHA256 9cb188cb4c5fddae8082e9fe59c7c65e1aff39f0562cce606122f68016992adc. */
%macro n26_del_file_with_fullpath(fullpath);
data _null_;
   rc=filename("fname","&fullpath");
   if rc=0 and fexist("fname") then
      rc=fdelete("fname");
   rc=filename("fname");
run;
%mend;
