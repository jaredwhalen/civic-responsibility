<script>
	import { fly, fade } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';

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
		circleTransition = 'all 0.5s ease-out'
	} = $props();

	let isDragging = $state(false);
	let dragStartX = $state(0);

	function handleMouseDown(event) {
		if (!guessMode) return;
		isDragging = true;
		event.preventDefault();
	}

	function handleMouseMove(event) {
		if (!guessMode || !isDragging) return;

		// Calculate position directly from mouse position relative to scale range
		const mouseX = event.clientX;
		const scaleRange = xScale.range();
		const scaleDomain = xScale.domain();

		// Convert mouse position to value (0-100)
		const normalizedX = (mouseX - scaleRange[0]) / (scaleRange[1] - scaleRange[0]);
		const newValue = Math.max(0, Math.min(100, normalizedX * 100));

		// Update the series value
		if (series[0]) {
			series[0].value = newValue;
		}

		$userResponse.guess = newValue;
	}

	function handleMouseUp() {
		if (!guessMode) return;
		isDragging = false;
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
						? options?.series?.find((d) => d.label.toLowerCase() === s.label.toLowerCase())
								?.color || defaultColor
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
