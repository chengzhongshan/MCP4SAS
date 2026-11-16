import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import AsyncMock
from unittest.mock import patch
from MCP4SAS_Use_Python.jobs import Jobs

class JobWaitTests(unittest.TestCase):
    def test_live_client_accepts_initial_terminal_results_without_replay(self):
        import asyncio
        from MCP4SAS_Use_Python.live_examples import completed
        for status,error in [('COMPLETE',False),('FAILED',True),('UNKNOWN',True)]:
            terminal={'structuredContent':{'status':status,'pid':123},'isError':error}
            call=AsyncMock(return_value=terminal)
            first,last=asyncio.run(completed(call,{},1))
            self.assertEqual(first,last)
            call.assert_awaited_once()
    def test_immediate_pending_and_finished_status(self):
        with tempfile.TemporaryDirectory() as temp,patch.dict('os.environ',{'MCP4SAS_PYTHON_STATE_DIR':temp}):
            jobs=Jobs(temp)
            with patch.object(jobs,'poll',return_value={'status':'RUNNING','pid':123}) as poll:
                result=jobs.wait(123,0)
                self.assertEqual(result['poll_after_seconds'],5)
                poll.assert_called_once()
            with patch.object(jobs,'poll',side_effect=[{'status':'RUNNING'},{'status':'FAILED','exit_code':1}]),patch('MCP4SAS_Use_Python.jobs.time.sleep'):
                self.assertEqual(jobs.wait(123,1)['exit_code'],1)
            for seconds in [-1,31,float('nan'),float('inf'),True,'20']:
                with self.assertRaises(ValueError):jobs.wait(123,seconds)
            for limit in [-1,1000001,True,1.5]:
                with self.assertRaises(ValueError):jobs.wait(123,0,limit)

    def test_complete_log_is_preserved_and_diagnosed_before_excerpt(self):
        with tempfile.TemporaryDirectory() as temp,patch.dict('os.environ',{'MCP4SAS_PYTHON_STATE_DIR':temp}):
            jobs=Jobs(temp)
            directory=Path(temp)/'result';directory.mkdir()
            log=directory/'full.log'
            body='=== SAS Log ===\nWARNING: first diagnostic.\n'+'x'*40000+'\nLAST_MARKER\n=== Output ===\n'
            log.write_text(body,encoding='utf8')
            (directory/'worker.result.json').write_text(json.dumps(dict(exit_code=0,log_path=str(log))))
            (jobs.index/'123.json').write_text(json.dumps(dict(directory=str(directory))))
            result=jobs.wait(123,0)
            self.assertTrue(result['log_truncated'])
            self.assertEqual(result['diagnostics']['warning_count'],1)
            self.assertIn('LAST_MARKER',result['text'])
            self.assertEqual(log.read_text(),body)
            full=jobs.wait(123,0,0)
            self.assertFalse(full['log_truncated'])
            self.assertIn(body,full['text'])

if __name__=='__main__':unittest.main()
