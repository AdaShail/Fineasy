// ===== Navigation Scroll Effect =====
const navbar = document.getElementById('navbar');
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const mobileMenu = document.getElementById('mobile-menu');

// Sections with gradient backgrounds (navbar should have white text)
const gradientSections = document.querySelectorAll('.hero, .cta-section');

// Function to check if navbar is over a gradient section
function updateNavbarStyle() {
    const navbarHeight = navbar.offsetHeight;
    const navbarBottom = navbarHeight;
    
    let isOverGradient = false;
    
    gradientSections.forEach(section => {
        const rect = section.getBoundingClientRect();
        // Check if navbar overlaps with this section
        if (rect.top < navbarBottom && rect.bottom > 0) {
            isOverGradient = true;
        }
    });
    
    if (isOverGradient) {
        navbar.classList.remove('scrolled');
    } else {
        navbar.classList.add('scrolled');
    }
}

// Update on scroll
window.addEventListener('scroll', updateNavbarStyle);

// Initial check
updateNavbarStyle();

// Mobile menu toggle
if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener('click', () => {
        mobileMenu.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });

    // Close mobile menu on link click
    document.querySelectorAll('.mobile-nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            mobileMenu.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        });
    });
}

// ===== Smooth Scroll for Anchor Links =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const headerOffset = 80;
            const elementPosition = target.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// ===== Intersection Observer for Animations =====
const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animate-fade-in-up');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe elements for animation
document.querySelectorAll('.feature-card, .step, .testimonial-card, .pricing-card, .faq-item').forEach(el => {
    el.style.opacity = '0';
    observer.observe(el);
});

// ===== Video Placeholder Click Handler =====
const videoPlaceholder = document.getElementById('video-placeholder');
if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        window.open('https://app.fineasy.tech', '_blank');
    });
}

// ===== Counter Animation =====
function animateCounter(element, target, duration = 2000) {
    let start = 0;
    const increment = target / (duration / 16);
    
    function updateCounter() {
        start += increment;
        if (start < target) {
            element.textContent = Math.floor(start).toLocaleString();
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target.toLocaleString();
        }
    }
    
    updateCounter();
}

// ===== Redirect Handler for CTA Buttons =====
document.querySelectorAll('[href*="app.fineasy.tech"]').forEach(link => {
    link.addEventListener('click', function(e) {
        // Track click event (for analytics)
        if (typeof gtag !== 'undefined') {
            gtag('event', 'click', {
                'event_category': 'CTA',
                'event_label': this.textContent.trim()
            });
        }
    });
});

// ===== Lazy Load Images =====
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                }
                imageObserver.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// ===== Performance: Defer non-critical CSS =====
window.addEventListener('load', () => {
    // Add any deferred styles or scripts here
    document.body.classList.add('loaded');
});

// ===== Console Easter Egg =====
// Removed for production
