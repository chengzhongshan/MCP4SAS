/* Test-only namespaced definition from chdir.sas; original SHA256 c8495b2fb414860585d30c4dd54b636f04950403f0b6804c3844364eec7cb22a. */
%macro n26_chdir(dir);
%let dir=%sysfunc(prxchange(s/\\/\//,-1,&dir));
%if "&sysscp"="WIN" %then %do;
x "cd /d &dir";
%end;
%else %do;
data _null_;
      rc=dlgcdir("&dir");
      put rc=;
run;
%end;
%put changed into the &dir;
%mend;
