/* ── Theme data ─────────────────────────────────────────── */
const THEMES = [
  {
    id:    'marvel',
    label: 'Marvel',
    vibe:  'Cinematic title card',
    desc:  'Tiny logo top → huge red ENTER block → underline inputs',
  },
  {
    id:    'classic-jdm',
    label: 'Classic JDM',
    vibe:  'JDM dashboard',
    desc:  'Full-bleed photo + bottom HUD bar (clock · login · power)',
  },
  {
    id:    'alienx',
    label: 'AlienX',
    vibe:  'Sci-fi command terminal',
    desc:  'Subject right, vertical green console left + scanlines',
  },
  {
    id:    'drag-racer',
    label: 'Drag Racer',
    vibe:  'Racing telemetry HUD',
    desc:  'Top-left mega clock, bottom-right pill login + GO button',
  },
  {
    id:    'gojo',
    label: 'Gojo',
    vibe:  'Manga monochrome split',
    desc:  'Left-pinned INFINITY panel, Gojo face stays clear right',
  },
  {
    id:    'kawaii',
    label: 'Kawaii',
    vibe:  'Pastel rounded card',
    desc:  'Subject right, big rounded pink card + floating hearts',
  },
  {
    id:    'joker',
    label: 'Joker',
    vibe:  'Off-center theatrical serif',
    desc:  'Vignette portrait, narrow right-third login column',
  },
  {
    id:    'rdr2',
    label: 'RDR2',
    vibe:  'Wanted-poster western',
    desc:  'Bottom-center parchment card, framed clock top-right',
  },
  {
    id:    'deadpool',
    label: 'Deadpool',
    vibe:  'Snarky chat-bubble panel',
    desc:  'Left chat-bubble login, hero portrait stays right',
  },
  {
    id:    'bmw',
    label: 'BMW',
    vibe:  'M-stripe ignition HUD',
    desc:  'Left key-fob ignition panel, classic cars stay right',
  },
];

/* ── State ──────────────────────────────────────────────── */
let activeId = THEMES[0].id;

/* ── Helpers ─────────────────────────────────────────────── */

/**
 * Return the wallpaper URL for a theme id.
 * Tries .jpg first; the <img> onerror trick is handled in CSS via
 * a fallback background-color — we load both possible extensions
 * by setting them in order and letting the browser pick the first
 * that loads (CSS background-image doesn't support <picture>
 * fallbacks, so we try jpg and keep a colour fallback).
 */
function wallpaperUrl(id) {
  // GitHub Pages serves the repo at root, so paths are relative:
  // ./marvel/assets/wallpaper.jpg  OR  ./marvel/assets/wallpaper.png
  return [
    `./${id}/assets/wallpaper.jpg`,
    `./${id}/assets/wallpaper.png`,
  ];
}

/**
 * Set the CSS background-image of an element, trying jpg then png.
 * Falls back to a colour gradient if neither loads.
 */
function applyWallpaper(el, id) {
  const [jpg, png] = wallpaperUrl(id);

  // Create an Image to probe which URL resolves.
  const img = new Image();
  img.onload = () => {
    el.style.backgroundImage = `url('${img.src}')`;
    el.classList.remove('no-image');
  };
  img.onerror = () => {
    // Try png next
    if (img.src.endsWith('.jpg')) {
      const img2 = new Image();
      img2.onload = () => {
        el.style.backgroundImage = `url('${img2.src}')`;
        el.classList.remove('no-image');
      };
      img2.onerror = () => {
        // Both failed – show gradient fallback
        el.style.backgroundImage = '';
        el.classList.add('no-image');
      };
      img2.src = png;
    }
  };
  img.src = jpg;
}

function showToast() {
  const toast = document.getElementById('toast');
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 1800);
}

/* ── setActive ───────────────────────────────────────────── */
function setActive(id) {
  activeId = id;

  const theme = THEMES.find(t => t.id === id);

  // Update install command
  document.getElementById('activeId').textContent = id;

  // Update preview image + overlay text
  const preview = document.getElementById('preview');
  applyWallpaper(preview, id);
  document.getElementById('previewLabel').textContent = theme.label;
  document.getElementById('previewVibe').textContent  = theme.vibe;

  // Update picker button states
  document.querySelectorAll('.picker-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.id === id);
    btn.setAttribute('aria-pressed', btn.dataset.id === id ? 'true' : 'false');
  });

  // Update grid card states
  document.querySelectorAll('.theme-card').forEach(card => {
    card.classList.toggle('active', card.dataset.id === id);
  });
}

/* ── Build picker ────────────────────────────────────────── */
function buildPicker() {
  const picker = document.getElementById('picker');
  THEMES.forEach(theme => {
    const btn = document.createElement('button');
    btn.className        = 'picker-btn';
    btn.dataset.id       = theme.id;
    btn.textContent      = theme.label;
    btn.setAttribute('aria-pressed', 'false');
    btn.addEventListener('click', () => setActive(theme.id));
    picker.appendChild(btn);
  });
}

/* ── Build grid ──────────────────────────────────────────── */
function buildGrid() {
  const grid = document.getElementById('grid');
  THEMES.forEach(theme => {
    const card = document.createElement('div');
    card.className  = 'theme-card';
    card.dataset.id = theme.id;
    card.setAttribute('role', 'button');
    card.setAttribute('tabindex', '0');
    card.setAttribute('aria-label', `Preview ${theme.label} theme`);

    // Thumb
    const thumb = document.createElement('div');
    thumb.className = 'card-thumb';

    // Fallback label inside thumb (shows while image loads or if it fails)
    const fallback = document.createElement('div');
    fallback.className   = 'card-thumb-fallback';
    fallback.textContent = theme.id;
    thumb.appendChild(fallback);

    // Info row
    const info = document.createElement('div');
    info.className = 'card-info';
    info.innerHTML = `<strong>${theme.label}</strong><span>${theme.vibe}</span>`;

    card.appendChild(thumb);
    card.appendChild(info);
    grid.appendChild(card);

    // Load wallpaper after element is in DOM
    applyWallpaper(thumb, theme.id);

    // Hide fallback once image loads (re-check via mutation / image load)
    // The applyWallpaper helper sets background-image on success; we just
    // hide the fallback text once the bg is set.
    const observer = new MutationObserver(() => {
      if (thumb.style.backgroundImage) {
        fallback.style.display = 'none';
        observer.disconnect();
      }
    });
    observer.observe(thumb, { attributes: true, attributeFilter: ['style'] });

    // Click / keyboard handler
    const activate = () => setActive(theme.id);
    card.addEventListener('click', activate);
    card.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); activate(); }
    });
  });
}

/* ── Copy command ────────────────────────────────────────── */
function setupCopy() {
  const bar     = document.getElementById('installCmd');
  const copyBtn = document.getElementById('copyBtn');

  function doCopy() {
    const text = `sudo ./install.sh ${activeId}`;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(() => {
        copyBtn.textContent = 'copied!';
        copyBtn.classList.add('copied');
        showToast();
        setTimeout(() => {
          copyBtn.textContent = 'copy';
          copyBtn.classList.remove('copied');
        }, 1800);
      }).catch(() => fallbackCopy(text));
    } else {
      fallbackCopy(text);
    }
  }

  function fallbackCopy(text) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity  = '0';
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    copyBtn.textContent = 'copied!';
    showToast();
    setTimeout(() => { copyBtn.textContent = 'copy'; }, 1800);
  }

  bar.addEventListener('click', doCopy);
  // Prevent double-fire when button itself is clicked (it's inside bar)
  copyBtn.addEventListener('click', e => { e.stopPropagation(); doCopy(); });
}

/* ── Init ────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  buildPicker();
  buildGrid();
  setupCopy();
  setActive(THEMES[0].id);   // set marvel as default
});
