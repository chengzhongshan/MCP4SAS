#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use SAS_Local_Home;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use JSON::PP qw(encode_json);

my $home='E:/SAS files';
is(SAS_Local_Home::expand_code_paths(q{libname x '~'; filename f "~/a.txt";},$home),
   q{libname x 'E:/SAS files'; filename f "%superq(PIPELINE_SAS_HOME)/a.txt";},
   'quoted directory and child paths expand for local SAS');
is(SAS_Local_Home::expand_code_paths(q{filename f '~\a.txt';},$home),
   q{filename f 'E:/SAS files\a.txt';},'Windows child separator is supported');
my $untouched="/* filename f '~/comment'; */\ndata x; input x \$30.;\ndatalines;\n'~/record'\n;\nrun;";
is(SAS_Local_Home::expand_code_paths($untouched,$home),$untouched,'comments and inline records remain unchanged');
is(SAS_Local_Home::expand_code_paths(q{filename f '~user/a'; x='a~';},$home),
   q{filename f '~user/a'; x='a~';},'only a leading home shorthand is expanded');
is(SAS_Local_Home::expand_code_paths(q{filename f '~/a';},''),q{filename f '~/a';},'ODA code remains unchanged without local home');
is(SAS_Local_Home::expand_code_paths(q{libname x '~';},q{E:/O'Brien}),q{libname x 'E:/O''Brien';},'apostrophes are escaped in SAS literals');
is(SAS_Local_Home::expand_code_paths(q{filename f "%sysfunc(pathname(HOME))/a";},$home),
   q{filename f "%sysfunc(pathname(HOME))/a";},'dynamic HOME expressions remain executable');

my $python=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
my $dir=tempdir('local sas home XXXX',TMPDIR=>1,CLEANUP=>1);
my $script=File::Spec->catfile($dir,'test home.py');
open my $fh,'>',$script or die $!;
print {$fh} "import os, sys, runpy\n", SAS_Local_Home::python_setup(), <<'PY';
class Session:
    def __init__(self, host=None):
        self._io=type('IO',(),{'sascfg':type('Config',(),{'iomhost':host})()})()
        self.calls=[]
    def submit(self, code):
        self.calls.append(code)
        return {'LOG':'NOTE: configured'}
s=Session()
configure_local_home(s,sys.argv[1])
assert s._pipeline_local_home==sys.argv[1].replace('\\','/')
assert 'filename HOME ' in s.calls[0] and 'PIPELINE_SAS_HOME' in s.calls[0]
configure_local_home(s,sys.argv[1])
assert len(s.calls)==1
for bad in ['relative/missing', os.path.join(sys.argv[1],'does not exist')]:
    try: configure_local_home(s,bad)
    except ValueError: pass
    else: raise AssertionError('invalid home accepted')
try: configure_local_home(Session(['remote.example']),sys.argv[1])
except ValueError: pass
else: raise AssertionError('remote connection accepted')
cfg=runpy.run_path(sys.argv[2])
assert 'linuxlocal' in cfg['SAS_config_names']
assert cfg['linuxlocal']['saspath'] and 'iomhost' not in cfg['linuxlocal']
assert isinstance(cfg['linuxlocal']['options'],list)
print('Local HOME setup and Linux STDIO profile contracts passed; no Linux SAS launched')
PY
open my $runner_fh,'<',File::Spec->catfile($Bin,'..','MCPDeps','SAS_ODA_Runner.pm') or die $!;
my $runner_source=do {local $/; <$runner_fh>}; close $runner_fh;
my ($one_shot_factory)=$runner_source =~ /(def _iter_saspy_cfg_names\(\):.*?)(?=def _format_elapsed)/s;
my ($persistent_factory)=$runner_source =~ /(def iter_saspy_cfg_names\(\):.*?)(?=def log_event)/s;
die 'Missing SASPy session factories' unless $one_shot_factory && $persistent_factory;
for my $factory ([$one_shot_factory,'_open_sas_session'],[$persistent_factory,'open_sas_session']) {
    print {$fh} 'factory_source=',encode_json($factory->[0]),"\n",'factory_name=',encode_json($factory->[1]),"\n",<<'PY';
os.environ['SASPY_CFGNAME']='linuxlocal'
os.environ['SASPY_CFGFILE']=sys.argv[2]
calls=[]
def fake_session(**kwargs):
    calls.append(kwargs)
    return 'linux-stdio-fixture'
ns={'os':os,'saspy':type('SASPy',(),{'SASsession':staticmethod(fake_session)}), 'SASsession':fake_session}
exec(factory_source,ns)
assert ns[factory_name]()=='linux-stdio-fixture'
assert calls==[{'cfgname':'linuxlocal','results':'html','cfgfile':sys.argv[2]}]
def missing_sas(**kwargs):
    calls.append(kwargs)
    raise OSError('fixture: Linux SAS executable missing')
ns['saspy']=type('SASPy',(),{'SASsession':staticmethod(missing_sas)})
ns['SASsession']=missing_sas
calls.clear()
try: ns[factory_name]()
except OSError as exc: assert 'executable missing' in str(exc)
else: raise AssertionError('missing SAS was reported as successful')
assert len(calls)==1 and calls[0]['cfgname']=='linuxlocal'
print(factory_name+': explicit Linux config and no ODA fallback verified')
PY
}
close $fh;
my @args=map {SAS_ODA_Runner::_normalize_local_path_for_python($_,$python)}
  ($script,$dir,File::Spec->catfile($Bin,'..','install','sascfg_linux_local.py'));
is(system({$python} $python,@args),0,'Python session setup rejects remote/missing paths and Linux profile selects STDIO');
done_testing();
