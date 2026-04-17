(function () {
  const canvas = document.getElementById("hero-canvas");
  if (!canvas || !window.THREE) return;

  const W = () => canvas.parentElement.offsetWidth;
  const H = () => canvas.parentElement.offsetHeight;

  const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(W(), H());

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(60, W() / H(), 0.1, 100);
  camera.position.set(0, 0, 7);

  const PALETTE = [0x1fa9e2, 0x0d67a7, 0x48c7f9, 0xffffff, 0x065a94, 0x2dd4f8];

  // ── Particle cloud ────────────────────────────────
  const N = 200;
  const pos = new Float32Array(N * 3);
  const col = new Float32Array(N * 3);
  for (let i = 0; i < N; i++) {
    pos[i * 3]     = (Math.random() - 0.5) * 22;
    pos[i * 3 + 1] = (Math.random() - 0.5) * 14;
    pos[i * 3 + 2] = (Math.random() - 0.5) * 10;
    const c = new THREE.Color(PALETTE[Math.floor(Math.random() * PALETTE.length)]);
    col[i * 3] = c.r; col[i * 3 + 1] = c.g; col[i * 3 + 2] = c.b;
  }
  const pGeo = new THREE.BufferGeometry();
  pGeo.setAttribute("position", new THREE.BufferAttribute(pos, 3));
  pGeo.setAttribute("color",    new THREE.BufferAttribute(col, 3));
  const points = new THREE.Points(pGeo, new THREE.PointsMaterial({
    size: 0.05, vertexColors: true, transparent: true, opacity: 0.6, sizeAttenuation: true,
  }));
  scene.add(points);

  // ── Floating wireframe geometry ──────────────────
  const GEO = [
    new THREE.IcosahedronGeometry(0.22, 0),
    new THREE.OctahedronGeometry(0.19, 0),
    new THREE.TetrahedronGeometry(0.17, 0),
    new THREE.IcosahedronGeometry(0.15, 1),
  ];

  const floaters = Array.from({ length: 16 }, (_, i) => {
    const mesh = new THREE.Mesh(
      GEO[i % GEO.length].clone(),
      new THREE.MeshBasicMaterial({
        color: PALETTE[Math.floor(Math.random() * PALETTE.length)],
        wireframe: true,
        transparent: true,
        opacity: 0.28 + Math.random() * 0.16,
      })
    );
    mesh.position.set(
      (Math.random() - 0.5) * 18,
      (Math.random() - 0.5) * 11,
      (Math.random() - 0.5) * 8
    );
    mesh.userData = {
      rx: (Math.random() - 0.5) * 0.013,
      ry: (Math.random() - 0.5) * 0.013,
      fs: 0.002 + Math.random() * 0.005,
      fo: Math.random() * Math.PI * 2,
    };
    scene.add(mesh);
    return mesh;
  });

  // ── Connection lines between close particles ──────
  const lineMat = new THREE.LineBasicMaterial({ color: 0x1fa9e2, transparent: true, opacity: 0.08 });
  const lineGroup = new THREE.Group();
  scene.add(lineGroup);

  function rebuildLines() {
    while (lineGroup.children.length) lineGroup.remove(lineGroup.children[0]);
    const pts = pGeo.attributes.position.array;
    for (let i = 0; i < N; i++) {
      for (let j = i + 1; j < N; j++) {
        const dx = pts[i*3]   - pts[j*3];
        const dy = pts[i*3+1] - pts[j*3+1];
        const dz = pts[i*3+2] - pts[j*3+2];
        const dist = Math.sqrt(dx*dx + dy*dy + dz*dz);
        if (dist < 3.2) {
          const geo = new THREE.BufferGeometry().setFromPoints([
            new THREE.Vector3(pts[i*3], pts[i*3+1], pts[i*3+2]),
            new THREE.Vector3(pts[j*3], pts[j*3+1], pts[j*3+2]),
          ]);
          lineGroup.add(new THREE.Line(geo, lineMat));
        }
      }
    }
  }
  rebuildLines();

  // ── Mouse ─────────────────────────────────────────
  let mx = 0, my = 0;
  document.addEventListener("mousemove", e => {
    mx = (e.clientX / window.innerWidth  - 0.5) * 2;
    my = (e.clientY / window.innerHeight - 0.5) * 2;
  });

  // ── Resize ────────────────────────────────────────
  window.addEventListener("resize", () => {
    renderer.setSize(W(), H());
    camera.aspect = W() / H();
    camera.updateProjectionMatrix();
  });

  // ── Animate ───────────────────────────────────────
  let t = 0;
  (function tick() {
    requestAnimationFrame(tick);
    t += 0.008;

    points.rotation.y = t * 0.03;
    points.rotation.x = t * 0.015;
    lineGroup.rotation.y = t * 0.03;
    lineGroup.rotation.x = t * 0.015;

    floaters.forEach(f => {
      f.rotation.x += f.userData.rx;
      f.rotation.y += f.userData.ry;
      f.position.y += Math.sin(t * f.userData.fs + f.userData.fo) * 0.004;
    });

    camera.position.x += (mx * 0.7 - camera.position.x) * 0.035;
    camera.position.y += (-my * 0.4 - camera.position.y) * 0.035;
    camera.lookAt(scene.position);

    renderer.render(scene, camera);
  })();
})();
