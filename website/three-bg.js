(function () {
  const canvas = document.getElementById("hero-canvas");
  if (!canvas || !window.THREE) return;

  const W = () => canvas.parentElement.offsetWidth;
  const H = () => canvas.parentElement.offsetHeight;

  const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: false });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
  renderer.setSize(W(), H());

  const scene  = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(55, W() / H(), 0.1, 100);
  camera.position.set(0, 0, 8);

  // ── Animated wave surface ────────────────────────────────────────────────
  const wGeo = new THREE.PlaneGeometry(32, 20, 52, 32);
  wGeo.rotateX(-Math.PI * 0.34);
  const wMat = new THREE.MeshBasicMaterial({
    color: 0x1fa9e2,
    wireframe: true,
    transparent: true,
    opacity: 0.075,
  });
  const waveMesh = new THREE.Mesh(wGeo, wMat);
  waveMesh.position.y = -1.6;
  scene.add(waveMesh);

  // Cache original XY per vertex (Z will be displaced)
  const wAttr = wGeo.attributes.position;
  const wOrigX = new Float32Array(wAttr.count);
  const wOrigY = new Float32Array(wAttr.count);
  for (let i = 0; i < wAttr.count; i++) {
    wOrigX[i] = wAttr.getX(i);
    wOrigY[i] = wAttr.getY(i);
  }

  // ── Rising bubble particles ──────────────────────────────────────────────
  const NB = 110;
  const bx     = new Float32Array(NB);
  const by     = new Float32Array(NB);
  const bz     = new Float32Array(NB);
  const bspeed = new Float32Array(NB);
  const bphase = new Float32Array(NB);
  const bcolor = new Float32Array(NB * 3);

  const AQUA = [
    new THREE.Color(0x48c7f9),
    new THREE.Color(0x1fa9e2),
    new THREE.Color(0x0d67a7),
    new THREE.Color(0xb8eeff),
    new THREE.Color(0x2dd4f8),
  ];

  function initBubble(i, scattered) {
    bx[i]     = (Math.random() - 0.5) * 22;
    by[i]     = scattered ? (Math.random() - 0.5) * 18 : -10 - Math.random() * 5;
    bz[i]     = (Math.random() - 0.5) * 8;
    bspeed[i] = 0.016 + Math.random() * 0.032;
    bphase[i] = Math.random() * Math.PI * 2;
    const c   = AQUA[Math.floor(Math.random() * AQUA.length)];
    bcolor[i * 3] = c.r; bcolor[i * 3 + 1] = c.g; bcolor[i * 3 + 2] = c.b;
  }

  for (let i = 0; i < NB; i++) initBubble(i, true);

  const bPosArr = new Float32Array(NB * 3);
  const bGeo   = new THREE.BufferGeometry();
  bGeo.setAttribute("position", new THREE.BufferAttribute(bPosArr, 3));
  bGeo.setAttribute("color",    new THREE.BufferAttribute(bcolor,  3));

  scene.add(new THREE.Points(bGeo, new THREE.PointsMaterial({
    size: 0.11,
    vertexColors: true,
    transparent: true,
    opacity: 0.48,
    sizeAttenuation: true,
  })));

  // ── Mouse parallax ───────────────────────────────────────────────────────
  let mx = 0, my = 0;
  document.addEventListener("mousemove", e => {
    mx = (e.clientX / window.innerWidth  - 0.5) * 2;
    my = (e.clientY / window.innerHeight - 0.5) * 2;
  }, { passive: true });

  // ── Resize ───────────────────────────────────────────────────────────────
  window.addEventListener("resize", () => {
    renderer.setSize(W(), H());
    camera.aspect = W() / H();
    camera.updateProjectionMatrix();
  }, { passive: true });

  // ── Render loop ──────────────────────────────────────────────────────────
  let t = 0;
  (function tick() {
    requestAnimationFrame(tick);
    t += 0.007;

    // Displace wave vertices along Z with overlapping sine waves
    for (let i = 0; i < wAttr.count; i++) {
      const ox = wOrigX[i], oy = wOrigY[i];
      wAttr.setZ(i,
        Math.sin(ox * 0.44 + t * 1.1)  * 0.34 +
        Math.sin(oy * 0.37 + t * 0.82) * 0.22 +
        Math.sin((ox - oy) * 0.27 + t * 0.63) * 0.16
      );
    }
    wAttr.needsUpdate = true;

    // Rise and sway bubbles
    for (let i = 0; i < NB; i++) {
      by[i] += bspeed[i];
      bx[i] += Math.sin(t * 0.68 + bphase[i]) * 0.006;
      if (by[i] > 10) initBubble(i, false);
      bPosArr[i * 3]     = bx[i];
      bPosArr[i * 3 + 1] = by[i];
      bPosArr[i * 3 + 2] = bz[i];
    }
    bGeo.attributes.position.needsUpdate = true;

    // Smooth camera mouse parallax
    camera.position.x += (mx * 0.55  - camera.position.x) * 0.026;
    camera.position.y += (-my * 0.28 - camera.position.y) * 0.026;
    camera.lookAt(0, 0, 0);

    renderer.render(scene, camera);
  })();
})();
