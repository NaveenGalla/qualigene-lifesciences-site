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

    const formData = new FormData(contactForm);
    const name = formData.get("name")?.toString().trim() || "";
    const company = formData.get("company")?.toString().trim() || "";
    const phone = formData.get("phone")?.toString().trim() || "";
    const email = formData.get("email")?.toString().trim() || "";
    const sector = formData.get("sector")?.toString().trim() || "";
    const message = formData.get("message")?.toString().trim() || "";

    const subject = encodeURIComponent(`Website enquiry from ${name || "Prospective customer"} - ${sector || "Qualigene"}`);
    const body = encodeURIComponent(
      [
        `Name: ${name}`,
        `Company / Farm: ${company}`,
        `Phone: ${phone}`,
        `Email: ${email}`,
        `Sector: ${sector}`,
        "",
        "Requirement:",
        message,
      ].join("\n")
    );

    window.location.href = `mailto:info@Qualigene.com?subject=${subject}&body=${body}`;
    formStatus.textContent = "Your enquiry email draft is ready. Review it and send when you’re happy.";
  });
}
