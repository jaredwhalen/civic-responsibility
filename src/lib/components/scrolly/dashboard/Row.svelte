<script>
	import { fly, fade } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';
	import tippy, { followCursor } from 'tippy.js';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/themes/light.css';
	import { onMount } from 'svelte';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	let {
		duty_label = '',
		series = [],
		xScale,
		y,
		dimensions,
		rowHeight,
		guessMode,
		pollCorrectMode,
		index,
		tickSize,
		active = false,
		highlight = false,
		options,
		customSeries = null,
		circleTransition = 'all 0.5s ease-out',
		interactiveMode,
		inIntro,
		hoveredSeries = $bindable()
	} = $props();

	let isDragging = $state(false);
	let tippyInstances = $state([]);
	let svgEl = $state(null);
	let lineX2 = $state(0);
	let showText = $state(false);

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
		$userResponse.userSubmitted = true;
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

	// Animate line growth and text in poll correct mode
	$effect(() => {
		if (pollCorrectMode && series.length === 2 && $userResponse.userSubmitted) {
			// Start line at guess position
			lineX2 = xScale(series[0].value);
			showText = false;

			// Animate to correct answer position and show text
			setTimeout(() => {
				lineX2 = xScale(series[1].value);
				showText = true;
			}, 50);
		} else if (guessMode || pollCorrectMode) {
			// Show text immediately in other modes
			showText = true;
		}
	});

	// $inspect(hoveredSeries);

	// Function to get circle color
	function getCircleColor(s) {
		const defaultColor = '#bbbbbb';
		return guessMode
			? getCSSVar('--color-theme-red')
			: pollCorrectMode
				? s.label === 'Your guess'
					? getCSSVar('--color-theme-red')
					: getCSSVar('--color-theme-green')
				: active
					? customSeries
						? customSeries.find((d) => d.label === s.label)?.color || defaultColor
						: options
							? options?.series?.find((d) => d.label.toLowerCase() === s.label.toLowerCase())
									?.color || defaultColor
							: getCSSVar('--color-theme-blue')
					: defaultColor;
	}

	// Function to create tippy instances
	function createTippyInstances() {
		// Clean up existing instances first - destroy any tippy instances on our elements
		const existingCircles = document.querySelectorAll(
			`[data-row-index="${index}"][data-tippy-content]`
		);
		existingCircles.forEach((circle) => {
			if (circle._tippy && typeof circle._tippy.destroy === 'function') {
				try {
					circle._tippy.destroy();
				} catch (e) {
					// Silently ignore errors from destroyed instances
					console.warn('Error destroying tippy instance:', e);
				}
			}
		});

		// Also clean up our tracked instances
		tippyInstances.forEach((instance) => {
			if (instance && typeof instance.destroy === 'function') {
				try {
					instance.destroy();
				} catch (e) {
					// Silently ignore errors from destroyed instances
					console.warn('Error destroying tippy instance:', e);
				}
			}
		});
		tippyInstances = [];

		if (!guessMode) {
			// Use a more specific selector for this component instance
			const circles = document.querySelectorAll(`[data-row-index="${index}"][data-tippy-content]`);
			circles.forEach((circle) => {
				try {
					const instance = tippy(circle, {
						theme: 'light',
						duration: 0,
						followCursor: true,
						plugins: [followCursor],
						allowHTML: true
					});
					tippyInstances.push(instance);
				} catch (e) {
					console.warn('Error creating tippy instance:', e);
				}
			});
		}
	}

	// Reactive effect to recreate tooltips when data changes
	$effect(() => {
		if (options || series.length > 0) {
			// Watch for changes in series values to trigger tooltip recreation
			series.forEach((s) => s.value);
			// Use a small delay to ensure DOM is updated
			setTimeout(createTippyInstances, 0);
		}
	});

	onMount(() => {
		// Clear any existing tooltips

		tippyInstances.forEach((instance) => {
			if (instance && typeof instance.destroy === 'function') {
				try {
					instance.destroy();
				} catch (e) {
					// Silently ignore errors from destroyed instances
				}
			}
		});

		tippyInstances = [];

		// Initial tippy creation
		createTippyInstances();

		// Cleanup function
		return () => {
			tippyInstances.forEach((instance) => {
				if (instance && typeof instance.destroy === 'function') {
					try {
						instance.destroy();
					} catch (e) {
						// Silently ignore errors from destroyed instances
						console.warn('Error destroying tippy instance in cleanup:', e);
					}
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
	class:interactive={interactiveMode}
	transform="translate(0, {y})"
	transition:fly={{ duration: 500, y: 100, delay: index * 10 }}
	style="--delay: {index * 10}ms;"
	style:--circle-transition={circleTransition}
>
	<line
		x1={dimensions.margins.left}
		x2={xScale.range()[1]}
		y1="0"
		y2="0"
		stroke="#aaa"
		stroke-width={inIntro ? 2 : 1}
	/>

	{#key duty_label}
		<text
			class:hide={guessMode}
			class="duty-label"
			x={dimensions.margins.left - 10}
			y="0"
			dy="0.32em"
			text-anchor="end"
			class:highlight
		>
			{duty_label}
		</text>
	{/key}

	{#if pollCorrectMode && series.length === 2 && $userResponse.userSubmitted}
		<!-- Draw line between guess and correct answer -->
		<line
			class="correct-line"
			x1={xScale(series[0].value)}
			y1="0"
			x2={lineX2}
			y2="0"
			stroke="#333"
			stroke-width="4"
			opacity="0.6"
		/>
	{/if}

	{#each series.sort((a, b) => {
		const aMatches = options?.series?.find((d) => d.label.toLowerCase() === a.label.toLowerCase());
		const bMatches = options?.series?.find((d) => d.label.toLowerCase() === b.label.toLowerCase());
		return aMatches ? 1 : bMatches ? -1 : 0;
	}) as s, i}
		{@const shouldShowGuess =
			!pollCorrectMode || s.label !== 'Your guess' || $userResponse.userSubmitted}
		{@const shouldHideGuessLabel =
			pollCorrectMode &&
			series.length === 2 &&
			Math.abs(xScale(series[0].value) - xScale(series[1].value)) < 10}

		{#if shouldShowGuess}
			{@const color = getCircleColor(s)}

			{@const textOffset = guessMode || pollCorrectMode ? -30 : -30}

			<circle
				cx={xScale(s.value)}
				cy="0"
				r={inIntro ? 12 : 6}
				fill={color}
				opacity={interactiveMode ? (hoveredSeries == s.label ? 1 : 0.75) : 1}
				onmousedown={handleMouseDown}
				style={guessMode ? 'cursor: grab;' : ''}
				class:interactive={guessMode}
				data-row-index={index}
				data-tippy-content={!guessMode
					? `<b>${s.label ? (s.label.includes('duties') ? 'U.S. average:' : s.label + ':') : ''}</b> ${s.value ? `${s.value.toFixed(1)}%` : ''}`
					: ''}
				onmouseover={() => {
					hoveredSeries = s.label;
				}}
				onmouseout={() => {
					hoveredSeries = null;
				}}
				style:stroke={hoveredSeries == s.label ? '#000' : color}
				style:stroke-width={hoveredSeries == s.label ? '2' : '1'}
				class:isDragging
			/>

			{#if guessMode || pollCorrectMode}
				{#if !shouldHideGuessLabel || s.label !== 'Your guess'}
					<text
						x={xScale(s.value)}
						y={textOffset}
						text-anchor="middle"
						class="guess-mode-text"
						class:show={showText}
						font-weight="600"
						fill="#333"
					>
						{s.value.toFixed(0)}%
					</text>
				{/if}
			{/if}
		{/if}

		{#if guessMode}
			<circle
				transition:fade|global={{ duration: 100 }}
				cx={xScale(s.value)}
				cy="0"
				r={18}
				fill="none"
				stroke="#000"
				stroke-width="2"
				class="interactive"
				class:isDragging
			/>
		{/if}
	{/each}

	<!-- Hover layer - renders on top with no interactivity (only in normal mode) -->
	{#if hoveredSeries && !guessMode && !pollCorrectMode}
		{#each series as s}
			{#if s.label === hoveredSeries}
				<circle
					cx={xScale(s.value)}
					cy="0"
					r={inIntro ? 12 : 6}
					fill={getCircleColor(s)}
					opacity={1}
					style="pointer-events: none;"
					style:stroke="#000"
					style:stroke-width="2"
					class="hover-layer"
				/>
			{/if}
		{/each}
	{/if}
</g>

<style lang="scss">
	.row {
		transition: transform 0.5s var(--delay, 0s) cubic-bezier(0.25, 0.1, 0.25, 1);
	}

	.row.interactive {
		.duty-label {
			font-size: 1rem;
		}
	}

	.duty-label {
		font-family: $font-family-sans;
		font-size: 1.6rem;
		transition: opacity 0.5s ease;
		font-weight: 300;
		&.highlight {
			font-weight: 700;
		}
	}

	.guess-mode-text {
		font-family: $font-family-sans;
		font-size: 2rem;
		font-weight: 600;
		opacity: 0;
		transform: translateX(10px);
		transition: all 0.5s var(--delay, 0s) cubic-bezier(0.25, 0.1, 0.25, 1);

		&.show {
			opacity: 1;
			transform: translateX(0);
		}
	}

	circle:not(.isDragging) {
		transition: var(--circle-transition);
	}

	.hide {
		opacity: 0;
	}

	.correct-line {
		stroke-dasharray: 1000;
		stroke-dashoffset: 1000;
		animation: drawLine 1s ease-out forwards;
		animation-delay: 0.5s;
	}

	@keyframes drawLine {
		to {
			stroke-dashoffset: 0;
		}
	}
</style>
