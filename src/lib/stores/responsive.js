import { writable } from 'svelte/store';

// Global responsive state stores
export const isMobile = writable(false);
export const isTablet = writable(false);
export const isDesktop = writable(true);

// Device type detection function
export function detectDeviceType() {
    if (typeof window === 'undefined') return;
    
    const width = window.innerWidth;
    const mobile = width < 768;
    const tablet = width >= 768 && width < 1024;
    const desktop = width >= 1024;
    
    isMobile.set(mobile);
    isTablet.set(tablet);
    isDesktop.set(desktop);
}

// Initialize device detection on mount
if (typeof window !== 'undefined') {
    detectDeviceType();
    window.addEventListener('resize', detectDeviceType);
}
