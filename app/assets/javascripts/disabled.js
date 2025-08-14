(function() {
  function setBtnDisabled(btn, disabled, busyText) {
    if (!btn) return;
    if (!btn.dataset.label) btn.dataset.label = btn.value || btn.textContent;
    btn.disabled = !!disabled;
    if (disabled && busyText) {
      if ('value' in btn) btn.value = busyText; else btn.textContent = busyText;
    } else {
      if ('value' in btn) btn.value = btn.dataset.label; else btn.textContent = btn.dataset.label;
    }
  }

  // ===== 新規登録 =====
  function initSignup() {
    const form  = document.getElementById("signup-form");
    if (!form) return; // ページに無ければ何もしない

    const btn   = document.getElementById("signup-submit");
    const name  = document.getElementById("user_nickname");
    const email = document.getElementById("user_email");
    const pw    = document.getElementById("user_password");
    const pw2   = document.getElementById("user_password_confirmation");

    function pwComplexOK(s){ return /[A-Za-z]/.test(s) && /\d/.test(s); }

    function applyCustomValidity() {
      if (pw)  pw.setCustomValidity(pwComplexOK(pw.value) ? "" : "英字と数字の両方を含めてください");
      if (pw && pw2) pw2.setCustomValidity(pw.value === pw2.value ? "" : "パスワードが一致しません");
    }

    function update() {
      if (!btn) return;
      applyCustomValidity();
      // ネイティブ検証結果に合わせて有効化
      setBtnDisabled(btn, !form.checkValidity());
    }

    // 入力のたびに更新（input/change/keyup まで拾って堅牢に）
    [name, email, pw, pw2].forEach(el => {
      if (!el) return;
      ["input","change","keyup"].forEach(ev => el.addEventListener(ev, update));
    });

    // オートフィル対策：少し遅らせて初回実行
    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      applyCustomValidity();
      if (!form.checkValidity()) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      setBtnDisabled(btn, true, "送信中…");
    });
  }

  // ===== ログイン =====
  function initLogin() {
    const form  = document.getElementById("login-form");
    if (!form) return;

    const btn   = document.getElementById("login-submit");
    const email = document.getElementById("session_email");
    const pw    = document.getElementById("session_password");

    function update() {
      if (!btn) return;
      setBtnDisabled(btn, !form.checkValidity());
    }

    [email, pw].forEach(el => {
      if (!el) return;
      ["input","change","keyup"].forEach(ev => el.addEventListener(ev, update));
    });

    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      if (!form.checkValidity()) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      setBtnDisabled(btn, true, "送信中…");
    });
  }

// ===== お問い合わせ =====
  function initContact() {
    const form = document.getElementById("contact-form");
    if (!form) return;

    const btn  = document.getElementById("contact-submit");
    const name = form.querySelector('input[name="name"]');
    const mail = form.querySelector('input[name="email"]');
    const msg  = form.querySelector('textarea[name="message"]');

    // 念のため required を担保
    [name, mail, msg].forEach(el => el && el.setAttribute("required", ""));

    function update() {
      if (!btn) return;
      setBtnDisabled(btn, !form.checkValidity());
    }

    [name, mail, msg].forEach(el => el && ["input","change","keyup"].forEach(ev => el.addEventListener(ev, update)));
    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      if (!form.checkValidity()) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      setBtnDisabled(btn, true, "送信中…");
    });
  }

  // ===== アカウント設定（メール/パスワード変更） =====
  function initAccount() {
    const form = document.getElementById("account-form");
    if (!form) return;

    const btn   = document.getElementById("account-submit");
    const email = document.getElementById("account_email");
    const pw    = document.getElementById("account_new_password");
    const pw2   = document.getElementById("account_new_password_confirmation");
    const cur   = document.getElementById("account_current_password");

    const requireCurrent = String(form.dataset.requireCurrent) === "true";

    function pwOK(s){ return /[A-Za-z]/.test(s) && /\d/.test(s) && s.length >= 6; }
    function emailChanged() {
      if (!email) return false;
      const original = email.dataset.original || "";
      return (email.value || "").trim() !== original.trim();
    }
    function wantsPwChange() {
      return !!(pw && pw.value.length > 0);
    }
    function somethingWillChange() {
      return emailChanged() || wantsPwChange();
    }

    function applyCustomValidity() {
      // 現在のパスワード必須は「requireCurrent=true のときだけ」
      if (cur) {
        if (requireCurrent) {
          cur.setCustomValidity(somethingWillChange() && !cur.value ? "現在のパスワードを入力してください" : "");
        } else {
          cur.setCustomValidity(""); // SSO未設定ユーザーは不要（そもそも欄が無い想定）
        }
      }
      // パスワードを変えるなら複雑性＆一致
      if (wantsPwChange()) {
        pw.setCustomValidity(pwOK(pw.value) ? "" : "6文字以上で英字と数字を含めてください");
        if (pw2) pw2.setCustomValidity(pw.value === pw2.value ? "" : "パスワードが一致しません");
      } else {
        pw.setCustomValidity("");
        if (pw2) pw2.setCustomValidity("");
      }
    }

    function update() {
      if (!btn) return;
      applyCustomValidity();

      // 何も変更しない場合は押せない
      const canSubmit = somethingWillChange() && form.checkValidity();
      setBtnDisabled(btn, !canSubmit);
    }

    [email, pw, pw2, cur].forEach(el => el && ["input","change","keyup"].forEach(ev => el.addEventListener(ev, update)));
    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      applyCustomValidity();
      const canSubmit = somethingWillChange() && form.checkValidity();
      if (!canSubmit) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      setBtnDisabled(btn, true, "保存中…");
    });
  }

  // ==== パスワードリセット申請 ====
  function initPasswordRequest() {
    const form = document.getElementById("password-request-form");
    if (!form) return;

    const btn   = document.getElementById("password-request-submit");
    const email = document.getElementById("password_email");

    // 念のため required を担保
    if (email) email.setAttribute("required", "");

    function update() {
      if (!btn) return;
      btn.disabled = !form.checkValidity();
    }

    ["input","change","keyup"].forEach(ev => email && email.addEventListener(ev, update));
    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      if (!form.checkValidity()) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      if (!btn.dataset.label) btn.dataset.label = btn.value || btn.textContent;
      btn.disabled = true;
      if ('value' in btn) btn.value = "送信中…"; else btn.textContent = "送信中…";
    });
  }

  // ==== パスワード再設定（入力） ====
  function initPasswordReset() {
    const form = document.getElementById("password-reset-form");
    if (!form) return;

    const btn  = document.getElementById("password-reset-submit");
    const pw   = document.getElementById("password_password");
    const pw2  = document.getElementById("password_password_confirmation");

    const minLen = Number((pw && pw.dataset.minlen) || 6);

    function pwOK(s){ return /[A-Za-z]/.test(s) && /\d/.test(s) && s.length >= minLen; }

    function applyValidity() {
      if (pw)  pw.setCustomValidity(pwOK(pw.value) ? "" : `英字と数字を含み、${minLen}文字以上で入力してください`);
      if (pw && pw2) pw2.setCustomValidity(pw.value === pw2.value ? "" : "パスワードが一致しません");
    }

    function update() {
      if (!btn) return;
      applyValidity();
      btn.disabled = !form.checkValidity();
    }

    [pw, pw2].forEach(el => el && ["input","change","keyup"].forEach(ev => el.addEventListener(ev, update)));
    setTimeout(update, 0);

    form.addEventListener("submit", (e) => {
      applyValidity();
      if (!form.checkValidity()) {
        e.preventDefault();
        form.reportValidity();
        return;
      }
      if (!btn.dataset.label) btn.dataset.label = btn.value || btn.textContent;
      btn.disabled = true;
      if ('value' in btn) btn.value = "変更中…"; else btn.textContent = "変更中…";
    });
  }

  // ==== 既存 initAll にフックを追加 ====
  function initAll() {
    // 既存: initSignup(); initLogin(); initContact(); initAccount();
    if (typeof initSignup === "function") initSignup();
    if (typeof initLogin  === "function") initLogin();
    if (typeof initContact === "function") initContact();
    if (typeof initAccount === "function") initAccount();
    // 新規
    initPasswordRequest();
    initPasswordReset();
  }

  document.addEventListener("turbo:load", initAll);
  document.addEventListener("DOMContentLoaded", initAll);

})();