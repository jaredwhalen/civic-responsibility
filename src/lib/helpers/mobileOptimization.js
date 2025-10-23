/**
 * Mobile performance optimization utilities
 */

// Detect if device is low-end based on hardware concurrency and memory
export function isLowEndDevice() {
	if (typeof window === 'undefined') return false;
	
	// Check for low hardware concurrency (CPU cores)
	const cores = navigator.hardwareConcurrency || 4;
	
	// Check for low memory (if available)
	const memory = navigator.deviceMemory || 4;
	
	// Check for slow connection
	const connection = navigator.connection;
	const isSlowConnection = connection && (
		connection.effectiveType === 'slow-2g' || 
		connection.effectiveType === '2g' ||
		connection.saveData === true
	);
	
	return cores <= 2 || memory <= 2 || isSlowConnection;
}

// Check if device prefers reduced motion
export function prefersReducedMotion() {
	if (typeof window === 'undefined') return false;
	return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

// Get optimal animation settings based on device capabilities
export function getAnimationSettings() {
	const isLowEnd = isLowEndDevice();
	const reducedMotion = prefersReducedMotion();
	
	return {
		// Disable animations for reduced motion preference
		enabled: !reducedMotion,
		
		// Reduce complexity on low-end devices
		complexity: isLowEnd ? 'low' : 'high',
		
		// Adjust frame rates
		targetFPS: isLowEnd ? 30 : 60,
		
		// Reduce D3 transition duration on low-end devices
		d3Duration: isLowEnd ? 100 : 50,
		
		// Disable heavy effects on low-end devices
		disableHeavyEffects: isLowEnd
	};
}

// Throttle function for performance
export function throttle(func, limit) {
	let inThrottle;
	return function() {
		const args = arguments;
		const context = this;
		if (!inThrottle) {
			func.apply(context, args);
			inThrottle = true;
			setTimeout(() => inThrottle = false, limit);
		}
	};
}

// Debounce function for performance
export function debounce(func, wait) {
	let timeout;
	return function executedFunction(...args) {
		const later = () => {
			clearTimeout(timeout);
			func(...args);
		};
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
	};
}
