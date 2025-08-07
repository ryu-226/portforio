document.addEventListener("DOMContentLoaded", () => {
  const btn      = document.getElementById("menu-btn");
  const backdrop = document.getElementById("menu-backdrop");
  const drawer   = document.getElementById("menu-drawer");
  let open = false;

  function openMenu() {
    btn.setAttribute("aria-expanded", "true");
    backdrop.classList.remove("opacity-0","pointer-events-none");
    backdrop.classList.add("opacity-100","pointer-events-auto");
    drawer.classList.remove("translate-x-full");
    // スタガーアニメ：各 li に順番に表示クラスを付与
    drawer.querySelectorAll("li").forEach((li, i) => {
      setTimeout(() => {
        li.classList.remove("opacity-0","translate-x-4");
        li.classList.add("opacity-100","translate-x-0");
      }, 100 * (i + 1));
    });
  }

  function closeMenu() {
    btn.setAttribute("aria-expanded", "false");
    backdrop.classList.add("opacity-0");
    backdrop.classList.remove("opacity-100");
    backdrop.classList.add("pointer-events-none");
    drawer.classList.add("translate-x-full");
    // リセット： li を再び隠す
    drawer.querySelectorAll("li").forEach(li => {
      li.classList.add("opacity-0","translate-x-4");
      li.classList.remove("opacity-100","translate-x-0");
    });
  }

  btn.addEventListener("click", e => {
    e.stopPropagation();
    open = !open;
    open ? openMenu() : closeMenu();
  });
  backdrop.addEventListener("click", closeMenu);
  document.addEventListener("click", e => {
    if (open && !drawer.contains(e.target) && e.target !== btn) {
      closeMenu();
      open = false;
    }
  });
});
