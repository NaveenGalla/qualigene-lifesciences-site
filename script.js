const menuToggle = document.querySelector(".menu-toggle");
const nav = document.querySelector(".nav");
const revealNodes = document.querySelectorAll(".reveal");
const yearNode = document.querySelector("#year");
const contactForm = document.querySelector("#contactForm");
const formStatus = document.querySelector("#formStatus");

if (menuToggle && nav) {
  menuToggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    menuToggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      nav.classList.remove("is-open");
      menuToggle.setAttribute("aria-expanded", "false");
    });
  });
}

const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.16 }
);

revealNodes.forEach((node) => observer.observe(node));

if (yearNode) {
  yearNode.textContent = new Date().getFullYear();
}

if (contactForm && formStatus) {
  contactForm.addEventListener("submit", (event) => {
    event.preventDefault();

    const data = new FormData(contactForm);
    const name = data.get("name")?.toString().trim() || "";
    const company = data.get("company")?.toString().trim() || "";
    const email = data.get("email")?.toString().trim() || "";
    const phone = data.get("phone")?.toString().trim() || "";
    const sector = data.get("sector")?.toString().trim() || "";
    const message = data.get("message")?.toString().trim() || "";

    const subject = encodeURIComponent(`Qualigene website enquiry - ${sector || "General"}`);
    const body = encodeURIComponent(
      [
        `Name: ${name}`,
        `Company / Farm: ${company}`,
        `Email: ${email}`,
        `Phone: ${phone}`,
        `Sector: ${sector}`,
        "",
        "Requirement:",
        message,
      ].join("\n")
    );

    window.location.href = `mailto:info@Qualigene.com?subject=${subject}&body=${body}`;
    formStatus.textContent = "Your enquiry email draft is ready. Review it and send when you are happy.";
  });
}
