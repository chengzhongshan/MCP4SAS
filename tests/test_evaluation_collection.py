"""Native counterpart: changed contracts/source cannot inherit saved results."""
from pathlib import Path
import json
import sys
import tempfile
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.collect_evaluations import collect,ROOT
from MCP4SAS_Use_Python.evaluation import contract_fingerprint


class CollectionTests(unittest.TestCase):
    def test_rechecks_actual_source_log_status_and_contract(self):
        # Deliberately synthetic logs test only the collector, not SAS execution.
        manifest=json.loads((ROOT/'tests/library500_round8/manifest.json').read_text())
        cases=manifest['cases'][:2];label=cases[0]['id']+'_'+cases[1]['id']
        with tempfile.TemporaryDirectory(prefix='SAS_Output_library500_live_',dir=ROOT) as temp:
            run=Path(temp);(run/label).mkdir()
            body='options notes;\n'+'\n'.join((ROOT/'tests/library500_round8'/v['file']).read_text() for v in cases)
            (run/(label+'.sas')).write_text(body)
            (run/label/'output.html.info.txt').write_text('=== SAS Log ===\n'+''.join('ROUND8_PASS='+v['id']+'\n' for v in cases)+'=== Output ===\n')
            status=dict(complete=True,success=True,state='completed')
            (run/label/'output.run.status.json').write_text(json.dumps(status))
            records=[dict(id=v['id'],batch=label,body_sha256=v['body_sha256'],contract_sha256=contract_fingerprint(v),passed=True) for v in cases]
            data=dict(round=8,results=records,batches=[dict(label=label,exit_code=0)])
            path=run/'results.json';path.write_text(json.dumps(data))
            self.assertEqual(collect(8,[run])['verified'],2)
            (run/(label+'.sas')).write_text(body+'/* changed source */')
            with self.assertRaisesRegex(ValueError,'Submitted source mismatch'):collect(8,[run])
            (run/(label+'.sas')).write_text(body)
            records[0]['contract_sha256']='0'*64;path.write_text(json.dumps(data))
            with self.assertRaisesRegex(ValueError,'contract mismatch'):collect(8,[run])
            skipped=collect(8,[run],skip_stale=True)
            self.assertEqual(skipped['verified'],0);self.assertEqual(len(skipped['stale_attempts']),2)
            del records[0]['contract_sha256'];path.write_text(json.dumps(data))
            with self.assertRaisesRegex(ValueError,'Missing evaluation contract'):collect(8,[run])


if __name__=='__main__':unittest.main()
