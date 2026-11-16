import sys,pathlib,tempfile,unittest,zipfile,os,re
from unittest.mock import patch
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'MCPDeps'))
import sas_archive_transfer as a
class Fake:
 def __init__(self):self.code=[];self.downloads=0;self.uploads=0
 def submit(self,c):
  self.code.append(c)
  markers=re.findall(r'put "(MCPMETA_[^"|]+\|[0-9]+\|)"',c)
  return {'LOG':'\n'.join(m+'1|3' for m in markers)}
 def symget(self,n):return '0'
 def upload(self,*x,**k):self.uploads+=1;return {'Success':True}
 def download(self,*x,**k):self.downloads+=1;return {'Success':True}
class Tests(unittest.TestCase):
 def test_upload_discards_stale_pretransfer_metadata(self):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td)/'macro.sas';p.write_bytes(b'new source');s=Fake()
   adapter=a.ArchiveSession(s,'/home/test',lambda path:{'exists':True,'size':10})
   adapter.cache['/home/test/macro.sas']={'exists':True,'size':3}
   remote,_=a.upload_file(str(p),adapter)
   self.assertEqual(remote,'/home/test/macro.sas');self.assertEqual(s.uploads,1)
 def test_upload_size_mismatch_has_one_private_copy_retry(self):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td)/'macro.sas';p.write_bytes(b'new source');s=Fake();staged=[]
   def upload(source,remote,overwrite=True):
    s.uploads+=1;self.assertEqual(remote,'/home/test/macro.sas')
    self.assertEqual(pathlib.Path(source).read_bytes(),b'new source')
    if source!=str(p):staged.append(source)
    return {'Success':True}
   s.upload=upload
   with patch.object(a,'run_fileinfo',side_effect=[{'exists':True,'size':3},{'exists':True,'size':10}]):
    a.upload_file(str(p),a.ArchiveSession(s,'/home/test',lambda path:{}))
   self.assertEqual(s.uploads,2);self.assertEqual(len(staged),1)
   self.assertFalse(pathlib.Path(staged[0]).exists())
 def test_persistent_size_mismatch_stops_after_two_uploads(self):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td)/'macro.sas';p.write_bytes(b'new source');s=Fake()
   adapter=a.ArchiveSession(s,'/home/test',lambda path:{'exists':True,'size':3})
   with self.assertRaisesRegex(IOError,'expected 10 bytes, got 3'):a.upload_file(str(p),adapter)
   self.assertEqual(s.uploads,2)
 def test_archive_flag(self):
  for x in [False,'false','0','off']:self.assertFalse(a._archive_transfer_enabled({'archive_transfers':x}))
  self.assertTrue(a._archive_transfer_enabled({}))
 def test_duplicates_rejected_before_upload(self):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td);(p/'a').mkdir();(p/'b').mkdir();(p/'a/x').write_bytes(b'1');(p/'b/x').write_bytes(b'2');s=Fake();adapter=a.ArchiveSession(s,'/home/test',lambda p:{})
   with self.assertRaisesRegex(ValueError,'duplicate'):a.upload_files_archive([{'local_path':str(p/'a/x')},{'local_path':str(p/'b/x')}],adapter)
   self.assertEqual(s.uploads,0)
 def test_missing_upload_rejected(self):
  s=Fake();adapter=a.ArchiveSession(s,'/home/test',lambda p:{})
  with self.assertRaises(FileNotFoundError):a.upload_files_archive([{'local_path':'/nonexistent/poc'}],adapter)
  self.assertEqual(s.uploads,0)
 def download_case(self,mode):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td);x=p/'x';y=p/'y';x.write_bytes(b'oldx');y.write_bytes(b'oldy');s=Fake();adapter=a.ArchiveSession(s,'/home/test',lambda p:{'exists':True,'path':p,'size':100 if p.endswith('.zip') else 3})
   archive_paths=[]
   def receive(remote,local,session):
    archive_paths.append(local);members=re.findall(r'ods package\(mgwpkg\) add file="[^"]*/([^/"]+)";', '\n'.join(s.code))
    with zipfile.ZipFile(local,'w') as z:
     for i,m in enumerate(members):
      if mode=='missing' and i==1:continue
      z.writestr(m,b'badsize' if mode=='corrupt' and i==1 else b'abc')
     z.writestr('../../escape',b'ignored')
    return local,session
   with patch.object(a,'download_file',side_effect=receive):
    items=[{'remote_path':'/remote/x','local_path':str(x)},{'remote_path':'/remote/y','local_path':str(y)}]
    if mode=='ok':
     result,_=a.download_files_archive(items,adapter);self.assertEqual(len(result),2);self.assertEqual(x.read_bytes(),b'abc');self.assertEqual(y.read_bytes(),b'abc')
    else:
     with self.assertRaises(IOError):a.download_files_archive(items,adapter)
     self.assertEqual(x.read_bytes(),b'oldx');self.assertEqual(y.read_bytes(),b'oldy')
   self.assertFalse(any(p.glob('.sas_oda_archive_*')));self.assertTrue(all(not os.path.exists(q) for q in archive_paths));self.assertTrue(any('fdelete' in q for q in s.code));self.assertFalse((p/'escape').exists())
 def test_verified_download(self):self.download_case('ok')
 def test_corrupt_member_preserves_destinations(self):self.download_case('corrupt')
 def test_missing_member_preserves_destinations(self):self.download_case('missing')
 def test_duplicate_destination(self):
  s=Fake();adapter=a.ArchiveSession(s,'/home/test',lambda p:{'exists':True,'path':p,'size':3})
  with self.assertRaisesRegex(ValueError,'duplicate'):a.download_files_archive([{'remote_path':'/a','local_path':'same'},{'remote_path':'/b','local_path':'same'}],adapter)
 def test_batch_metadata_uses_one_submit(self):
  s=Fake();adapter=a.ArchiveSession(s,'/home/test',lambda p: self.fail('per-file metadata callback should not run'))
  adapter.prime_fileinfo(['/remote/a','/remote/b'])
  self.assertEqual(len(s.code),1);self.assertEqual(adapter.fileinfo('/remote/a')['size'],3);self.assertEqual(adapter.fileinfo('/remote/b')['size'],3)
 def test_incomplete_metadata_rejected(self):
  s=Fake();s.submit=lambda code:{'LOG':''};adapter=a.ArchiveSession(s,'/home/test',lambda p:{})
  with self.assertRaisesRegex(IOError,'Incomplete'):adapter.prime_fileinfo(['/remote/a'])
 def test_missing_upload_metadata_batched_before_transfer(self):
  s=Fake()
  def submit(code):
   s.code.append(code)
   markers=re.findall(r'put "(MCPMETA_[^"|]+\|[0-9]+\|)"',code)
   return {'LOG':'\n'.join(m+'0|.' for m in markers)}
  s.submit=submit
  adapter=a.ArchiveSession(s,'/home/test',lambda p:self.fail('new files must not use individual metadata RPCs'))
  adapter.prime_fileinfo(['/home/test/a','/home/test/b'],details_for_existing=True)
  self.assertEqual(len(s.code),1);self.assertFalse(adapter.fileinfo('/home/test/a')['exists'])
 def test_existing_upload_retains_timestamp_validation(self):
  s=Fake();calls=[]
  def existing(path):calls.append(path);return {'exists':True,'size':3,'modified_epoch':1234}
  adapter=a.ArchiveSession(s,'/home/test',existing)
  adapter.prime_fileinfo(['/home/test/a'],details_for_existing=True)
  self.assertEqual(calls,['/home/test/a']);self.assertEqual(adapter.fileinfo('/home/test/a')['modified_epoch'],1234)
 def test_explicit_no_archive(self):
  with tempfile.TemporaryDirectory() as td:
   p=pathlib.Path(td)/'x';p.write_bytes(b'abc');s=Fake()
   with patch.object(a,'upload_file',return_value=('/home/test/x',None)) as up,patch.object(a,'upload_files_archive') as archive:
    r=a.transfer_many(s,{'archive_transfers':False,'uploads':[{'local_path':str(p),'skip_if_same':False}]},'/home/test',lambda p:{})
    self.assertEqual(up.call_count,1);archive.assert_not_called();self.assertFalse(r['uploads'][0]['archive_transfer'])
if __name__=='__main__':unittest.main()
