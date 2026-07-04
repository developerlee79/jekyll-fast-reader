(function () {
  'use strict';

  var STORAGE_KEY = 'fr-state';
  var btn = document.getElementById('fr-toggle');
  if (!btn) return;

  var mode = btn.getAttribute('data-fr-mode');

  function applyState(active) {
    if (mode === 'opt-in') {
      document.body.classList.toggle('fast-reader', active);
    } else {
      document.body.classList.toggle('fr-disabled', !active);
    }
    btn.setAttribute('aria-pressed', active ? 'true' : 'false');
  }

  try {
    var saved = localStorage.getItem(STORAGE_KEY);
    if (saved === 'on') applyState(true);
    else if (saved === 'off') applyState(false);
  } catch (e) {
    // localStorage may be unavailable (private mode, disabled cookies, etc.)
  }

  btn.addEventListener('click', function () {
    var active = btn.getAttribute('aria-pressed') !== 'true';
    applyState(active);
    try {
      localStorage.setItem(STORAGE_KEY, active ? 'on' : 'off');
    } catch (e) {
      // ignore
    }
  });

  document.addEventListener('keydown', function (e) {
    if (!e.altKey || !e.shiftKey) return;
    if (e.key !== 'B' && e.key !== 'b') return;

    var t = e.target;
    if (t && (t.isContentEditable || /^(input|textarea|select)$/i.test(t.tagName))) return;

    e.preventDefault();
    btn.click();
  });
})();
