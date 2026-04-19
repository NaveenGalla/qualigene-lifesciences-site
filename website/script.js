// ── Mobile menu ───────────────────────────────────────────────────────────────
const menuToggle = document.querySelector(".menu-toggle");
const nav        = document.querySelector(".nav");

if (menuToggle && nav) {
  menuToggle.addEventListener("click", () => {
    const open = nav.classList.toggle("is-open");
    menuToggle.setAttribute("aria-expanded", String(open));
  });
  nav.querySelectorAll("a").forEach(a =>
    a.addEventListener("click", () => {
      nav.classList.remove("is-open");
      menuToggle.setAttribute("aria-expanded", "false");
    })
  );
}

// ── Year ──────────────────────────────────────────────────────────────────────
const yearNode = document.querySelector("#year");
if (yearNode) yearNode.textContent = new Date().getFullYear();

// ── Contact form ──────────────────────────────────────────────────────────────
const contactForm = document.querySelector("#contactForm");
const formStatus  = document.querySelector("#formStatus");
if (contactForm && formStatus) {
  contactForm.addEventListener("submit", e => {
    e.preventDefault();
    const d   = new FormData(contactForm);
    const get = k => d.get(k)?.toString().trim() || "";
    const sub = encodeURIComponent(`Qualigene website enquiry - ${get("sector") || "General"}`);
    const bdy = encodeURIComponent(
      [`Name: ${get("name")}`, `Company / Farm: ${get("company")}`,
       `Email: ${get("email")}`, `Phone: ${get("phone")}`,
       `Sector: ${get("sector")}`, "", "Requirement:", get("message")].join("\n")
    );
    window.location.href = `mailto:info@Qualigene.com?subject=${sub}&body=${bdy}`;
    formStatus.textContent = "Your enquiry email draft is ready. Review and send when happy.";
  });
}

// ── Topbar scroll shrink ──────────────────────────────────────────────────────
const topbar = document.querySelector(".topbar");
if (topbar) {
  const onScroll = () => topbar.classList.toggle("scrolled", window.scrollY > 48);
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();
}

// ── Stagger data attrs ────────────────────────────────────────────────────────
document.querySelectorAll(
  ".product-showcase,.solution-grid,.gallery-strip,.reason-grid,.cert-grid,.product-gallery,.related-products,.about-grid,.hero-stats,.product-detail-grid,.compliance-grid"
).forEach(group =>
  group.querySelectorAll(".reveal").forEach((el, i) => { el.dataset.stagger = Math.min(i + 1, 6); })
);

// ── Intersection observer (fallback + non-GSAP reveals) ───────────────────────
const revealNodes = document.querySelectorAll(".reveal");
const revealObs = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add("is-visible"); revealObs.unobserve(e.target); } }),
  { threshold: 0.12 }
);
revealNodes.forEach(n => revealObs.observe(n));

// ── Wait for GSAP ─────────────────────────────────────────────────────────────
window.addEventListener("load", () => {
  if (!window.gsap || !window.ScrollTrigger) return;
  gsap.registerPlugin(ScrollTrigger);

  // Helper — check if element is inside a product page (not homepage)
  const onProductPage = !!document.querySelector(".product-hero");

  // ── Section headings — float up ──────────────────────────────────────────────
  gsap.utils.toArray(".section-heading").forEach(el => {
    gsap.from(el, {
      scrollTrigger: { trigger: el, start: "top 86%", toggleActions: "play none none none" },
      y: 48, scale: 0.97, opacity: 0, duration: 1.05,
      ease: "power3.out", clearProps: "all",
    });
  });

  // ── Product cards — rise from below like surfacing ───────────────────────────
  gsap.utils.toArray(".product-showcase").forEach(grid => {
    gsap.from(grid.querySelectorAll(".product-card"), {
      scrollTrigger: { trigger: grid, start: "top 82%" },
      y: 70, scale: 0.93, opacity: 0,
      duration: 0.95, stagger: 0.09, ease: "power3.out", clearProps: "all",
    });
  });

  // ── Solution / reason / compliance / about grids — ripple wave stagger ────────
  gsap.utils.toArray(".solution-grid,.reason-grid,.compliance-grid,.about-grid").forEach(grid => {
    gsap.from(grid.querySelectorAll("article, .panel"), {
      scrollTrigger: { trigger: grid, start: "top 84%" },
      y: 50, scale: 0.95, opacity: 0,
      duration: 0.88, stagger: 0.08, ease: "power3.out", clearProps: "all",
    });
  });

  // ── Gallery strip — float up sequentially like rising bubbles ────────────────
  gsap.utils.toArray(".gallery-strip").forEach(strip => {
    gsap.from(strip.querySelectorAll(".gallery-card"), {
      scrollTrigger: { trigger: strip, start: "top 84%" },
      y: 55, scale: 0.93, opacity: 0,
      duration: 0.88, stagger: 0.1, ease: "power3.out", clearProps: "all",
    });
  });

  // ── Mini CTA ─────────────────────────────────────────────────────────────────
  gsap.utils.toArray(".mini-cta").forEach(el => {
    gsap.from(el, {
      scrollTrigger: { trigger: el, start: "top 86%" },
      scale: 0.9, opacity: 0, y: 40, duration: 0.9,
      ease: "back.out(1.5)", clearProps: "all",
    });
  });

  // ── Cert cards — surface up ───────────────────────────────────────────────────
  gsap.utils.toArray(".cert-grid").forEach(grid => {
    gsap.from(grid.querySelectorAll(".cert-card"), {
      scrollTrigger: { trigger: grid, start: "top 86%" },
      y: 50, scale: 0.95, opacity: 0,
      duration: 0.9, stagger: 0.12, ease: "power3.out", clearProps: "all",
    });
  });

  // ── Related products ─────────────────────────────────────────────────────────
  gsap.utils.toArray(".related-products").forEach(grid => {
    gsap.from(grid.querySelectorAll(".related-card"), {
      scrollTrigger: { trigger: grid, start: "top 86%" },
      y: 50, scale: 0.95, opacity: 0,
      duration: 0.82, stagger: 0.1, ease: "power3.out", clearProps: "all",
    });
  });

  // ── Product hero visual — float up from below ─────────────────────────────────
  const productHeroVis = document.querySelector(".product-hero-visual");
  if (productHeroVis) {
    gsap.from(productHeroVis, {
      y: 50, scale: 0.95, opacity: 0, duration: 1.1,
      ease: "power3.out", delay: 0.2, clearProps: "all",
    });
  }

  // ── Product hero copy ─────────────────────────────────────────────────────────
  const productHeroCopy = document.querySelector(".product-hero-copy");
  if (productHeroCopy) {
    gsap.from(productHeroCopy.children, {
      y: 36, scale: 0.97, opacity: 0, duration: 0.85, stagger: 0.1,
      ease: "power3.out", delay: 0.1, clearProps: "all",
    });
  }

  // ── Hero copy (homepage) — tide in from below ─────────────────────────────────
  const heroCopy = document.querySelector(".hero-copy");
  if (heroCopy && !onProductPage) {
    gsap.from(heroCopy.children, {
      y: 44, scale: 0.97, opacity: 0, duration: 0.92, stagger: 0.11,
      ease: "power3.out", delay: 0.3, clearProps: "all",
    });
  }

  // ── Trust strip ──────────────────────────────────────────────────────────────
  const trustStrip = document.querySelector(".trust-strip");
  if (trustStrip) {
    gsap.from(trustStrip, {
      scrollTrigger: { trigger: trustStrip, start: "top 90%" },
      y: 30, opacity: 0, duration: 0.8, ease: "power2.out", clearProps: "all",
    });
  }

  // ── Contact panel ─────────────────────────────────────────────────────────────
  const contactPanel = document.querySelector(".contact-panel");
  if (contactPanel) {
    gsap.from(contactPanel.children, {
      scrollTrigger: { trigger: contactPanel, start: "top 84%" },
      y: 60, opacity: 0, duration: 0.9, stagger: 0.15,
      ease: "power3.out", clearProps: "all",
    });
  }
});

// ── 3D Card Tilt + Specular Shine ─────────────────────────────────────────────
function initTilt(selector, maxDeg) {
  document.querySelectorAll(selector).forEach(card => {
    if (!card.querySelector(".card-shine")) {
      const shine = document.createElement("div");
      shine.className = "card-shine";
      card.appendChild(shine);
    }
    const shine = card.querySelector(".card-shine");
    let raf;

    card.addEventListener("mousemove", e => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => {
        const r  = card.getBoundingClientRect();
        const x  = e.clientX - r.left;
        const y  = e.clientY - r.top;
        const rx = ((y - r.height / 2) / (r.height / 2)) * -maxDeg;
        const ry = ((x - r.width  / 2) / (r.width  / 2)) *  maxDeg;
        card.style.transform = `perspective(900px) rotateX(${rx}deg) rotateY(${ry}deg) translateZ(12px)`;
        shine.style.opacity  = "1";
        shine.style.background = `radial-gradient(circle at ${x}px ${y}px, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0) 65%)`;
      });
    });

    const reset = () => {
      cancelAnimationFrame(raf);
      shine.style.opacity = "0";
      if (window.gsap) {
        gsap.to(card, { rotateX: 0, rotateY: 0, z: 0, duration: 0.9, ease: "elastic.out(1,0.45)", clearProps: "transform" });
      } else {
        card.style.transform = "";
      }
    };
    card.addEventListener("mouseleave", reset);
  });
}

initTilt(".product-card",   10);
initTilt(".solution-card",   9);
initTilt(".reason-card",     9);
initTilt(".gallery-card",    8);
initTilt(".related-card",    8);
initTilt(".cert-card",       6);
initTilt(".hero-stats article", 7);

// ── Animated stat counters ────────────────────────────────────────────────────
const statsEl = document.querySelector(".hero-stats");
if (statsEl) {
  const cObs = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      entry.target.querySelectorAll("strong[data-count]").forEach(el => {
        const target   = parseInt(el.dataset.count, 10);
        const suffix   = el.dataset.suffix || "";
        const duration = 1800;
        let   current  = 0;
        const step     = target / (duration / 16);
        const fmt      = n => n >= 1000 ? n.toLocaleString() : n;
        const t = setInterval(() => {
          current = Math.min(current + step, target);
          el.textContent = fmt(Math.floor(current)) + suffix;
          if (current >= target) clearInterval(t);
        }, 16);
      });
      cObs.unobserve(entry.target);
    });
  }, { threshold: 0.6 });
  cObs.observe(statsEl);
}

// ── Hero visual mouse parallax ────────────────────────────────────────────────
const heroVisual = document.querySelector(".hero-visual");
if (heroVisual) {
  let pvRaf;
  document.addEventListener("mousemove", e => {
    cancelAnimationFrame(pvRaf);
    pvRaf = requestAnimationFrame(() => {
      const x = (e.clientX / window.innerWidth  - 0.5) * 24;
      const y = (e.clientY / window.innerHeight - 0.5) * 16;
      if (window.gsap) {
        gsap.to(heroVisual, { rotateY: x * 0.38, rotateX: -y * 0.38, duration: 0.65, ease: "power2.out", transformPerspective: 1200 });
      } else {
        heroVisual.style.transform = `perspective(1200px) rotateY(${x * 0.38}deg) rotateX(${-y * 0.38}deg)`;
      }
    });
  });
  document.querySelector(".hero")?.addEventListener("mouseleave", () => {
    if (window.gsap) gsap.to(heroVisual, { rotateX: 0, rotateY: 0, duration: 1.2, ease: "power3.out" });
    else heroVisual.style.transform = "";
  });
}

// ── Smooth active nav highlight on scroll ────────────────────────────────────
const sections   = document.querySelectorAll("main section[id]");
const navLinks   = document.querySelectorAll(".nav a[href*='#']");
if (sections.length && navLinks.length) {
  const secObs = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      navLinks.forEach(a => {
        a.classList.toggle("nav-active", a.getAttribute("href").includes(e.target.id));
      });
    });
  }, { threshold: 0.45 });
  sections.forEach(s => secObs.observe(s));
}
