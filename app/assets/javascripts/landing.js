(function(){
  const reveal = () => {
    const el = document.getElementById('hero-copy');
    if(!el) return;

    // メディアクエリ：アニメが苦手な人なら即表示
    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) {
      el.classList.remove('opacity-0','translate-y-10','scale-90');
      el.style.transition = 'none';
      return;
    }

    // 1フレーム遅らせてトランジションを効かせる
    requestAnimationFrame(() => {
      el.classList.remove('opacity-0','translate-y-10','scale-90');
    });
  };

  document.addEventListener('turbo:load', reveal);
  document.addEventListener('DOMContentLoaded', reveal);
})();


(function(){
  const boot = () => {
    const cards = Array.from(document.querySelectorAll('.vp-card'));
    if (!cards.length) return;

    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // reduced-motion の場合は即表示
    if (prefersReduced) {
      cards.forEach(c => c.classList.remove('opacity-0','translate-y-4','scale-[.98]'));
      return;
    }

    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const el = entry.target;

        // data-stagger を使って 0,1,2... と遅延
        const staggerIndex = Number(el.dataset.stagger || 0);
        const delay = 100 + staggerIndex * 300; // ベース80ms + 順次120ms

        setTimeout(() => {
          el.classList.remove('opacity-0','translate-y-4','scale-[.98]');
          el.classList.add('transition', 'duration-1500', 'ease-out'); // 以後のhoverも滑らかに
        }, delay);

        io.unobserve(el); // 一度だけ
      });
    }, { threshold: 0.2, rootMargin: '0px 0px -10% 0px' });

    cards.forEach(c => io.observe(c));
  };

  document.addEventListener('turbo:load', boot);
  document.addEventListener('DOMContentLoaded', boot);
})();

(function () {
  const bootHIW = () => {
    const cards = Array.from(document.querySelectorAll('.hiw-card'));
    if (!cards.length) return;

    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // スライド速度と遅延
    const DURATION = 720;        // 右→0 の所要(ms)
    const BASE     = 120;        // 最初の待機(ms)
    const STAGGER  = 240;        // 1枚ごとの追加遅延(ms)

    // 初期オフセット（画面幅に対して余裕）
    const isMdUp  = window.matchMedia('(min-width: 768px)').matches;
    const OFFSET  = isMdUp ? '14vw' : '22vw';

    // 初期状態を「必ず」付与（ここが重要）
    cards.forEach(c => {
      c.style.transform = `translate3d(${OFFSET},0,0)`;
      c.style.opacity   = '0';
      c.style.willChange = 'transform, opacity';
      c.style.backfaceVisibility = 'hidden';
      // 初期に空表示だと単位だけ見えるので 0 を仮表示（任意）
      c.querySelectorAll('.cu').forEach(s => { if (!s.textContent) s.textContent = '0'; });
    });

    // 数値カウントアップ（最後は必ず目標値で終わる版）
    function runCountUps(root, instant = false) {
      root.querySelectorAll('.cu').forEach(el => {
        const to     = Number(el.dataset.count || 0);
        const prefix = el.dataset.prefix ?? '';
        const suffix = el.dataset.suffix ?? '';
        const dur    = Number(el.dataset.duration || 900);

        const render = (n) => {
          el.textContent = `${prefix}${Math.round(n).toLocaleString('ja-JP')}${suffix}`;
        };

        // アニメ無効 or 即時描画指定
        if (prefersReduced || instant || dur <= 0) {
          render(to);
          return;
        }

        const start = performance.now();
        let rafId;

        const step = (now) => {
          const t = Math.min(1, (now - start) / dur);

          if (t >= 1) {            // ← 最後は必ず目標値で確定
            render(to);
            return;
          }

          const eased = 1 - Math.pow(1 - t, 3);  // easeOutCubic
          render(to * eased);
          rafId = requestAnimationFrame(step);
        };

        rafId = requestAnimationFrame(step);

        // フェイルセーフ：最終フレームが飛んでも確定させる
        setTimeout(() => {
          cancelAnimationFrame(rafId);
          render(to);
        }, dur + 60);
      });
    }

    // 動きを苦手設定の人は即時
    if (prefersReduced) {
      cards.forEach(c => {
        c.style.transform = 'translate3d(0,0,0)';
        c.style.opacity = '1';
        runCountUps(c, true);
      });
      return;
    }

    // 見えたら右→0にスライド。完了後にカウントアップ
    const io = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        const el = entry.target;
        const i  = Number(el.dataset.stagger || 0);

        el.style.transition = `transform ${DURATION}ms cubic-bezier(.2,.6,.2,1), opacity ${DURATION}ms`;

        const start = () => {
          el.style.transform = 'translate3d(0,0,0)';
          el.style.opacity   = '1';

          let done = false;
          const onEnd = (ev) => {
            if (ev.propertyName !== 'transform') return; // transform の終了だけ
            done = true;
            el.removeEventListener('transitionend', onEnd);
            el.style.transition = '';
            runCountUps(el);
          };
          el.addEventListener('transitionend', onEnd, { once: true });

          // 念のため：transitionend が飛ばない環境向けフェイルセーフ
          setTimeout(() => { if (!done) runCountUps(el); }, DURATION + 80);
        };

        setTimeout(start, BASE + i * STAGGER);
        io.unobserve(el);
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -10% 0px' });

    cards.forEach(c => io.observe(c));
  };

  document.addEventListener('turbo:load', bootHIW);
  document.addEventListener('DOMContentLoaded', bootHIW);
})();

(() => {
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const onLoad = () => {
    const group = document.querySelector('[data-stagger-group]');
    if (!group) return;

    const cards = Array.from(group.querySelectorAll('[data-stagger]'));
    const io = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        const index = cards.indexOf(entry.target);
        const delay = prefersReduced ? 400 : index * 300; // スタガー間隔ms

        setTimeout(() => {
          entry.target.classList.remove('opacity-0', 'translate-y-3');
          entry.target.classList.add('opacity-100', 'translate-y-0');
          // ふわっと感
          entry.target.classList.add('duration-1300', 'ease-out');
        }, delay);

        io.unobserve(entry.target);
      });
    }, { threshold: 0.2, rootMargin: '0px 0px -10% 0px' });

    cards.forEach(c => io.observe(c));
  };

  document.addEventListener('turbo:load', onLoad);
  document.addEventListener('DOMContentLoaded', onLoad);
})();

(() => {
  const mount = () => {
    const btn = document.getElementById('back-to-top');
    if (!btn) return;

    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // スクロール位置で表示/非表示（ラフに300px超えたら表示）
    let ticking = false;
    const toggle = () => {
      const show = window.scrollY > 300;
      if (show) {
        btn.classList.add('opacity-100');
        btn.classList.remove('opacity-0', 'pointer-events-none');
      } else {
        btn.classList.remove('opacity-100');
        btn.classList.add('opacity-0', 'pointer-events-none');
      }
    };

    const onScroll = () => {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        toggle();
        ticking = false;
      });
    };

    // 初期判定＆監視
    toggle();
    window.addEventListener('scroll', onScroll, { passive: true });

    // クリックで上へ（reduced-motion は即座にジャンプ）
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      if (prefersReduced) {
        window.scrollTo(0, 0);
      } else {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    }, false);
  };

  document.addEventListener('turbo:load', mount);
  document.addEventListener('DOMContentLoaded', mount);
})();