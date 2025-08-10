(() => {
  const onLoad = () => {
    const cores = Array.from(document.querySelectorAll('.card-3d'));
    if (!cores.length) return;

    const isMobile = window.matchMedia('(max-width: 639px)').matches;

    // 初期は裏向きで待機（共通）
    cores.forEach(c => c.classList.add('start-back'));

    // スマホは“触るまで”武装解除しない／PCはすぐ有効
    let armed = !isMobile;

    // スタッガー間隔（カード間のディレイ）
    const step = 200;

    // PC は最初に少し待つ（お好みで）
    const baseDelay = isMobile ? 0 : 500;

    // ★ 順番の決定：PC は明示／スマホは DOM 並び
    if (!isMobile) {
      const pcOrder = [
        '#card-user .card-3d',     // 1. ユーザー情報
        '#card-settings .card-3d', // 2. 現在の設定
        '#card-history .card-3d',  // 3. 利用履歴
      ];
      // 指定順に stagger を振る
      pcOrder.forEach((sel, i) => {
        const node = document.querySelector(sel);
        if (node) node.dataset.stagger = String(i);
      });
      // 上記以外がもしあれば、後ろに回す（保険）
      let next = pcOrder.length;
      cores.forEach(c => {
        if (c.dataset.stagger == null) c.dataset.stagger = String(next++);
      });
    } else {
      // モバイル：DOM順のまま
      cores.forEach((c, i) => c.dataset.stagger = String(i));
    }

    // 表示監視＆めくり
    const io = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!armed || !entry.isIntersecting) return;

        const core = entry.target;
        if (core.dataset.revealed === '1') return;
        core.dataset.revealed = '1';

        const idx = Number(core.dataset.stagger || 0);
        const delay = baseDelay + idx * step;

        setTimeout(() => {
          core.classList.add('animate-flip-reveal-front');
          core.classList.remove('start-back');
          core.addEventListener('animationend', () => {
            core.classList.remove('animate-flip-reveal-front');
          }, { once: true });
        }, delay);

        io.unobserve(core);
      });
    }, { threshold: 0.35, rootMargin: '0px 0px -10% 0px' });

    cores.forEach(c => io.observe(c));

    // スマホは“触られるまで”armed にしない
    const arm = () => {
      if (armed) return;
      armed = true;
      requestAnimationFrame(() => {
        cores.forEach(c => { io.unobserve(c); io.observe(c); });
      });
      window.removeEventListener('scroll', arm, { passive: true });
      window.removeEventListener('touchmove', arm, { passive: true });
    };
    if (!armed) {
      window.addEventListener('scroll', arm, { passive: true });
      window.addEventListener('touchmove', arm, { passive: true });
    }
  };

  document.addEventListener('turbo:load', onLoad);
  document.addEventListener('DOMContentLoaded', onLoad);
})();