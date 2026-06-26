const themes = [
  { id: "marvel",      name: "MARVEL",        wp: "../marvel/assets/wallpaper.jpg",      tag: "cinematic title card",       accent: "#ed1d24" },
  { id: "classic-jdm", name: "CLASSIC JDM",   wp: "../classic-jdm/assets/wallpaper.jpg", tag: "instrument cluster HUD",     accent: "#ffb020" },
  { id: "alienx",      name: "ALIEN X",       wp: "../alienx/assets/wallpaper.png",      tag: "omnitrix command console",   accent: "#39ff14" },
  { id: "drag-racer",  name: "DRAG RACER",    wp: "../drag-racer/assets/wallpaper.jpg",  tag: "racing telemetry overlay",   accent: "#ff3b30" },
  { id: "gojo",        name: "GOJO",          wp: "../gojo/assets/wallpaper.png",        tag: "manga monochrome split",     accent: "#cfcfcf" },
  { id: "kawaii",      name: "KAWAII",        wp: "../kawaii/assets/wallpaper.png",      tag: "pastel rounded card",        accent: "#ff9ec7" },
  { id: "joker",       name: "JOKER",         wp: "../joker/assets/wallpaper.jpg",       tag: "off-center theatrical strip",accent: "#8bc34a" },
  { id: "rdr2",        name: "RDR2",          wp: "../rdr2/assets/wallpaper.jpg",        tag: "wanted-poster western",      accent: "#c79a4a" },
  { id: "deadpool",    name: "DEADPOOL",      wp: "../deadpool/assets/wallpaper.jpg",    tag: "snarky chat-bubble panel",   accent: "#d4202c" },
  { id: "bmw",         name: "BMW MUSEUM",    wp: "../bmw/assets/wallpaper.jpg",         tag: "M-stripe ignition HUD",      accent: "#1c69d4" },
];

const $ = (s) => document.querySelector(s);
const preview = $("#preview");
const picker = $("#picker");
const grid = $("#grid");
const activeId = $("#activeId");
const cmd = $("#installCmd");

let current = themes[0];

function render() {
  preview.style.backgroundImage = `url("${current.wp}")`;
  preview.innerHTML = `
    <div class="chrome">
      <div class="meta">
        <strong>${current.name}</strong>
        ${current.tag} · accent <span style="color:${current.accent}">${current.accent}</span>
      </div>
    </div>`;
  activeId.textContent = current.id;
  document.documentElement.style.setProperty("--accent", current.accent);
  [...picker.children].forEach((b) =>
    b.classList.toggle("active", b.dataset.id === current.id)
  );
}

themes.forEach((t) => {
  const b = document.createElement("button");
  b.dataset.id = t.id;
  b.innerHTML = `${t.name} <span class="pid">${t.id}</span>`;
  b.onclick = () => { current = t; render(); };
  picker.appendChild(b);

  const c = document.createElement("div");
  c.className = "card";
  c.dataset.name = t.name;
  c.style.backgroundImage = `url("${t.wp}")`;
  c.onclick = () => { current = t;
    render(); window.scrollTo({ top: 0, behavior: "smooth" }); };
  grid.appendChild(c);
});

cmd.onclick = async () => {
  try {
    await navigator.clipboard.writeText(`sudo ./install.sh ${current.id}`);
    const c = cmd.querySelector(".copy");
    const old = c.textContent; c.textContent = "copied!";
    setTimeout(() => (c.textContent = old), 1200);
  } catch {}
};

render();
