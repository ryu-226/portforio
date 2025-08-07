document.addEventListener("DOMContentLoaded", () => {
  const amount    = document.getElementById('today-amount');
  const modal     = document.getElementById('draw-modal');
  const modalBg   = document.getElementById('modal-bg');
  const closeBtn  = document.getElementById('close-modal-btn');
  const card      = document.getElementById('amount-card');
  const realEl    = document.getElementById('real-amount');
  const container = document.getElementById('capsule-container');

  function playFullAnimation(finalAmount) {
    // 1) カードめくり
    setTimeout(() => {
      card.classList.add('animate-flip');
      setTimeout(() => {
        realEl.innerHTML = `<span id="real-number" class="mr-1">0</span><span>円</span>`;
        card.style.transform = '';
      }, 800);
    }, 1600);

    // 2) カウントアップ + ポップ + 花吹雪
    setTimeout(() => {
      let count = 0;
      const step = Math.max(1, Math.floor(800 / finalAmount));
      const numEl = document.getElementById('real-number');
      const timer = setInterval(() => {
        count++;
        numEl.textContent = count;
        if (count >= finalAmount) {
          clearInterval(timer);
          numEl.parentElement.classList.add('animate-pop');
          for (let i = 0; i < 20; i++) {
            const p = document.createElement('div');
            p.className = 'confetti-piece';
            p.style.left           = `${50 + (Math.random() * 80 - 40)}%`;
            p.style.background     = `hsl(${Math.random() * 360},70%,60%)`;
            p.style.animationDelay = `${Math.random() * 0.5}s`;
            container.appendChild(p);
            setTimeout(() => p.remove(), 1500);
          }
          const msg = document.getElementById('draw-message');
          msg.classList.remove('opacity-0');
          msg.classList.add('opacity-100');
        }
      }, step);
      realEl.classList.add('animate-fade-in-scale');
    }, 2500);
  }

  // モーダル周りの要素がそろっている場合だけ、閉じる系の処理を登録
  if (modal && modalBg && closeBtn) {

    // モーダル表示 ＋ アニメーション開始の共通処理
    function openModalAndAnimate() {
      modal.style.display   = '';
      modalBg.style.display = '';

      const msg = document.getElementById('draw-message');
      msg.classList.remove('opacity-100');
      msg.classList.add('opacity-0');

      const text = amount.textContent || "";
      const num  = parseInt(text.replace(/\D+/g, ""), 10) || 0;

      setTimeout(() => playFullAnimation(num), 300);
    }

    // 金額クリック時
    amount.addEventListener('click', () => {
      if (!/\d+/.test(amount.textContent)) return;
      openModalAndAnimate();
    });

    // 自動オープン
    if (modal.style.display !== 'none') {
      openModalAndAnimate();
    }

    // モーダル内部クリックは外側閉じ処理を阻止
    modal.addEventListener('click', e => e.stopPropagation());

    // バックドロップクリックで閉じる
    modalBg.addEventListener('click', () => {
      modal.style.display   = 'none';
      modalBg.style.display = 'none';
    });

    // 閉じるボタン
    closeBtn.addEventListener('click', () => {
      modal.style.display   = 'none';
      modalBg.style.display = 'none';
    });
  }
});
