document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".toast").forEach((el) => {
    const close = () => {
      el.style.pointerEvents = "none";
      el.classList.add("opacity-0", "translate-y-1");
      el.addEventListener("transitionend", () => el.remove(), { once: true });
    };
    const timeout = parseInt(el.dataset.timeout || "3000", 10);
    if (timeout > 0) setTimeout(close, timeout);
    el.querySelector(".toast-close")?.addEventListener("click", close);
  });
});