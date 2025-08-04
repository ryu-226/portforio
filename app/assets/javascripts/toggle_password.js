document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll(".toggle-password").forEach(function(icon) {
    icon.addEventListener("click", function() {
      // 兄弟要素の input.password-field を探す
      var input = icon.parentElement.querySelector(".password-field");
      if (!input) return;
      // タイプ切り替え
      var newType = input.type === "password" ? "text" : "password";
      input.type = newType;
      // アイコンの見た目を切り替え
      if (newType === "text") {
        icon.classList.remove("fa-eye");
        icon.classList.add("fa-eye-slash");
      } else {
        icon.classList.remove("fa-eye-slash");
        icon.classList.add("fa-eye");
      }
    });
  });
});