export const getCSSVar = (varName) => {
    if (typeof window === 'undefined') return null;
    return window.getComputedStyle(document.documentElement).getPropertyValue(varName);
}