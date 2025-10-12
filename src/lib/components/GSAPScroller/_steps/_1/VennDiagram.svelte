<script>
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import { onMount, tick } from 'svelte';
	import { fade } from 'svelte/transition';

	/** @type {Props} */
	let { offset = 0, height, width } = $props();

	// Animation constants - tweak these to adjust overlap behavior
	const start = 0;
	const end = 0.9;
	const OVERLAP_START = 1; // 90% overlap at start (offset=0)
	const OVERLAP_END = 0; // 10% overlap at end (offset=1)

	// Calculate animation values based on scroll progress - these are reactive
	const localOffset = $derived((offset - start) / (end - start));
	const clampedLocalOffset = $derived(Math.max(0.2, Math.min(1, localOffset)));

	// Circle properties
	const baseRadius = width / 4;
	const centerY = height / 2;
	const centerX = width / 2; // Center of the container

	// Calculate overlap: start at OVERLAP_START, end at OVERLAP_END
	const currentOverlap = $derived(
		OVERLAP_START - clampedLocalOffset * (OVERLAP_START - OVERLAP_END)
	);

	// Calculate separation distance based on overlap
	// When overlap = 1, separation = 0 (circles on top of each other)
	// When overlap = 0, separation = 2 * baseRadius (circles just touching)
	const maxSeparation = 2 * baseRadius;
	const separation = $derived(maxSeparation * (1 - currentOverlap));

	// Calculate horizontal positions (start centered, drift apart)
	// The visual center of both circles stays at centerX
	const leftCircleX = $derived(centerX - separation / 2);
	const rightCircleX = $derived(centerX + separation / 2);


	// Calculate vertical positions (start aligned, drift up/down)
	// Keep the visual center (midpoint) of both circles at centerY
	const verticalDrift = $derived(clampedLocalOffset * 20); // Drift up to 60px up/down
	const leftCircleY = $derived(centerY - verticalDrift); // Left circle moves up
	const rightCircleY = $derived(centerY + verticalDrift); // Right circle moves down
	// The midpoint between leftCircleY and rightCircleY is always centerY

	// Calculate rotation (full rotation over scroll range)
	const rotation = $derived(clampedLocalOffset * 45);

	// Calculate scale (slight scaling effect)
	const scale = $derived(0.8 + clampedLocalOffset * 0.4); // Scale from 0.8 to 1.2

	// Create gradients
	const createGradients = () => {
		const svg = document.querySelector('svg');
		if (!svg) return;

		// Clear existing gradients
		const existingDefs = svg.querySelector('defs');
		if (existingDefs) existingDefs.remove();

		const defs = svg.appendChild(document.createElementNS('http://www.w3.org/2000/svg', 'defs'));

		// Helper function to create a gradient
		const createGradient = (id, startColor) => {
			const gradient = defs.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'radialGradient')
			);
			gradient.setAttribute('id', id);
			gradient.setAttribute('cx', '50%');
			gradient.setAttribute('cy', '50%');
			gradient.setAttribute('r', '100%');

			const stop1 = gradient.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'stop')
			);
			stop1.setAttribute('offset', '20%');
			stop1.setAttribute('stop-color', startColor);

			const stop2 = gradient.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'stop')
			);
			stop2.setAttribute('offset', '100%');
			stop2.setAttribute('stop-color', getCSSVar('--color-theme-blue'));
		};

		// Create both gradients
		createGradient('leftGradient', getCSSVar('--color-theme-dem-blue'));
		createGradient('rightGradient', getCSSVar('--color-theme-gop-red'));
	};

	onMount(async () => {
		await tick();
		createGradients();
	});
</script>

<div class="inner-container" in:fade|global={{ duration: 400, delay: 500 }}>
	<svg width="100%" {height} transition:fade|global={{ duration: 400 }}>
		<g transform="rotate({rotation}) scale({scale})" transform-origin="center">
			<!-- Left circle (Democrat) -->
			<circle
				cx={leftCircleX}
				cy={leftCircleY}
				r={baseRadius}
				fill="url(#leftGradient)"
				opacity="0.8"
				stroke={getCSSVar('--color-theme-dem-blue')}
			/>

			<!-- Right circle (Republican) -->
			<circle
				cx={rightCircleX}
				cy={rightCircleY}
				r={baseRadius}
				fill="url(#rightGradient)"
				opacity="0.8"
				stroke={getCSSVar('--color-theme-gop-red')}
			/>
		</g>
	</svg>
</div>

<style lang="scss">
	.inner-container {
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		position: absolute;
		inset: 0;
		pointer-events: none;
		z-index: 2;
	}

	svg {
		display: block;
		width: 100%;
		height: auto;

		circle {
			stroke-width: 2px;
			fill-opacity: 0.5;
			mix-blend-mode: overlay;
            mix-blend-mode: difference;
		}
	}
</style>
