<script>
	import { fly, fade } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';
	import tippy, { followCursor } from 'tippy.js';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/themes/light.css';
	import { onMount } from 'svelte';

	let {
		duty_label = '',
		series = [],
		xScale,
		y,
		dimensions,
		rowHeight,
		guessMode,
		index,
		tickSize,
		active = false,
		highlight = false,
		options,
		circleTransition = 'all 0.5s ease-out',
		interactiveMode,
		hoveredSeries = $bindable()
	} = $props();

	let isDragging = $state(false);
	let tippyInstances = $state([]);
	let svgEl = $state(null);

	function handleMouseDown(event) {
		if (!guessMode) return;
		isDragging = true;
		event.preventDefault();
		svgEl = event.target.ownerSVGElement;
	}

	function handleMouseMove(event) {
		if (!guessMode || !isDragging || !svgEl) return;

		const svgRect = svgEl.getBoundingClientRect();
		const mouseX = event.clientX - svgRect.left;
		const newValue = xScale.invert(mouseX);

		const clampedValue = Math.max(0, Math.min(100, newValue));

		// Update the series value
		if (series[0]) {
			series[0].value = clampedValue;
		}

		$userResponse.guess = clampedValue;
	}

	function handleMouseUp() {
		if (!guessMode) return;
		isDragging = false;
		svgEl = null;
	}

	// Add global mouse event listeners
	$effect(() => {
		if (guessMode) {
			document.addEventListener('mousemove', handleMouseMove);
			document.addEventListener('mouseup', handleMouseUp);

			return () => {
				document.removeEventListener('mousemove', handleMouseMove);
				document.removeEventListener('mouseup', handleMouseUp);
			};
		}
	});

	// Function to create tippy instances
	function createTippyInstances() {
		// Clean up existing instances first
		tippyInstances.forEach((instance) => {
			if (instance && instance.destroy) {
				instance.destroy();
			}
		});
		tippyInstances = [];

		// Only create new instances if interactiveMode is true
		if (interactiveMode) {
			// Use a more specific selector for this component instance
			const circles = document.querySelectorAll(`[data-row-index="${index}"][data-tippy-content]`);
			circles.forEach((circle) => {
				const instance = tippy(circle, {
					theme: 'light',
					duration: 0,
					followCursor: true,
					plugins: [followCursor],
					allowHTML: true
				});
				tippyInstances.push(instance);
			});
		}
	}

	// Reactive effect to recreate tooltips when data changes
	$effect(() => {
		if (interactiveMode && series.length > 0) {
			// Use a small delay to ensure DOM is updated
			setTimeout(createTippyInstances, 0);
		}
	});

	onMount(() => {
		// Initial tippy creation
		createTippyInstances();

		// Cleanup function
		return () => {
			tippyInstances.forEach((instance) => {
				if (instance && instance.destroy) {
					instance.destroy();
				}
			});
			tippyInstances = [];
		};
	});


</script>

<g
	class="row"
	class:active
	class:highlight
	transform="translate(0, {y})"
	transition:fly={{ duration: 500, y: 100, delay: index * 10 }}
	style="--delay: {index * 10}ms;"
	style:--circle-transition={circleTransition}
>
	<line x1={dimensions.margins.left} x2={xScale.range()[1]} y1="0" y2="0" stroke="#ddd" />

	{#key duty_label}
		<text x={dimensions.margins.left - 10} y="0" dy="0.32em" text-anchor="end" class:highlight>
			{duty_label}
		</text>
	{/key}

	{#each series.sort((a, b) => {
		const aMatches = options?.series?.find((d) => d.label.toLowerCase() === a.label.toLowerCase());
		const bMatches = options?.series?.find((d) => d.label.toLowerCase() === b.label.toLowerCase());
		return aMatches ? 1 : bMatches ? -1 : 0;
	}) as s, i}
		{@const defaultColor = '#dddddd'}
		{@const color = guessMode
			? '#E63719'
			: active
				? options
					? options?.series?.find((d) => d.label.toLowerCase() === s.label.toLowerCase())?.color ||
						defaultColor
					: '#64B42D'
				: defaultColor}
		{@const faded = color == defaultColor}
		<circle
			cx={xScale(s.value)}
			cy="0"
			r={6}
			fill={color}
			opacity={faded ? 0.5 : 0.75}
			onmousedown={handleMouseDown}
			style={guessMode ? 'cursor: grab;' : ''}
			class:interactive={guessMode}
			data-row-index={index}
			data-tippy-content={interactiveMode
				? `<b>${s.label ? (s.label.includes('duties') ? 'U.S. average:' : s.label + ":") : ''}</b> ${s.value ? `${s.value.toFixed(1)}%` : ''}`
				: ''}
			onmouseover={() => {
				hoveredSeries = s.label;
			}}
			onmouseout={() => {
				hoveredSeries = null;
			}}
			style:stroke={hoveredSeries == s.label ? '#000' : 'none'}
			style:stroke-width={hoveredSeries == s.label ? '2' : '0'}
		/>

		{#if guessMode}
			<circle
				transition:fade|global={{ duration: 100 }}
				cx={xScale(s.value)}
				cy="0"
				r={12}
				fill="none"
				stroke="#000"
				stroke-width="2"
				class="interactive"
			/>
		{/if}
	{/each}
</g>

<style lang="scss">
	.row {
		transition: transform 0.5s var(--delay, 0s) cubic-bezier(0.25, 0.1, 0.25, 1);
	}

	text {
		font-family: $font-family-sans;
		&.highlight {
			font-weight: 600;
		}
	}

	circle:not(.interactive) {
		transition: var(--circle-transition);
	}
</style>