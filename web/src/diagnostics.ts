
import { exec, toast } from './ksu';

const basic = document.getElementById('diagnostics-basic') as HTMLButtonElement | null;
const extended = document.getElementById('diagnostics-extended') as HTMLButtonElement | null;
const status = document.getElementById('diagnostics-result');
const dialog = document.getElementById('diagnostics-confirm') as any;
const cancel = document.getElementById('diagnostics-cancel');
const accept = document.getElementById('diagnostics-accept');

let busy = false;
async function exportReport(mode: 'basic' | 'extended'): Promise<void> {
  if (busy) return;
  busy = true;
  if (basic) basic.disabled = true;
  if (extended) extended.disabled = true;
  if (status) status.textContent = '正在本机生成诊断报告…';
  try {
    const response = await exec('sh /data/adb/modules/FontMM/hyperos/diagnostics.sh ' + mode);
    const match = response.stdout.match(/^DIAG_FILE=(.+)$/m);
    if (response.errno !== 0 || !match) {
      throw new Error(response.stderr.trim() || response.stdout.trim() || '诊断文件未生成');
    }
    const file = match[1].trim();
    if (!file.startsWith('/storage/emulated/0/Download/FontMM/')) throw new Error('输出文件路径异常');
    if (status) status.textContent = '已保存：' + file + '。请用文件管理器分享 TXT，发送前检查内容。';
    toast('诊断日志已保存到 Download/FontMM');
  } catch (error) {
    if (status) status.textContent = '导出失败：' + String(error);
    toast('导出日志失败');
  } finally {
    busy = false;
    if (basic) basic.disabled = false;
    if (extended) extended.disabled = false;
  }
}
basic?.addEventListener('click', () => void exportReport('basic'));
extended?.addEventListener('click', () => { if (dialog) dialog.open = true; });
cancel?.addEventListener('click', () => { if (dialog) dialog.open = false; });
accept?.addEventListener('click', () => {
  if (dialog) dialog.open = false;
  void exportReport('extended');
});
