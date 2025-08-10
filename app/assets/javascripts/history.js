document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('edit-actual-form');
  const csrfMetaToken = document.querySelector('meta[name="csrf-token"]')?.content;

  // 日付セル→下部フォームへ反映
  window.handleDaySelect = (el) => {
    const container = el.parentElement;

    // 既存の選択解除
    container.querySelectorAll('button.group.is-selected')
      .forEach(b => b.classList.remove('is-selected'));
    el.classList.add('is-selected');

    const base    = form.dataset.updateBase;
    const dateStr = el.dataset.date;
    const drawId  = el.dataset.drawId;
    const actual  = el.dataset.actualAmount;

    // UI反映
    document.getElementById('edit-date-display').value =
      dateStr + (drawId ? '' : '（抽選なし）');
    document.getElementById('actual_amount').value = actual || '';
    document.getElementById('edit-draw-id').value  = drawId || '';
    document.getElementById('save-btn').disabled   = !drawId;

    // /draws/:id を直接組み立て
    form.action = drawId ? `${base}/${drawId}` : '#';

    // per-form CSRF 対応：hidden のトークンも更新
    const tokenInput = form.querySelector('input[name="authenticity_token"]');
    if (csrfMetaToken && tokenInput) tokenInput.value = csrfMetaToken;
  };

  // 送信前チェック（保険）
  form.addEventListener('submit', (e) => {
    if (!/\/draws\/\d+$/.test(form.action)) {
      e.preventDefault();
      alert('日付セル（抽選がある日）を選択してください。');
    }
  });
});
