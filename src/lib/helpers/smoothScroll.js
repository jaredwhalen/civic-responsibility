export default function smoothScroll(querySelector) {
    document.querySelector(querySelector).scrollIntoView({
        behavior: 'smooth'
    });
}