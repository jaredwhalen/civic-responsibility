<script>
	import { fly, fade } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';
	import tippy, { followCursor } from 'tippy.js';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/themes/light.css';
	import { onMount } from 'svelte';
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import { isMobile } from '$lib/stores/responsive.js';

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
		showGapLine = false,
		hoveredSeries = $bindable(),
		clickedSeries = $bindable(),
		clickedCircles = $bindable(),
		activeView
	} = $props();

	let isDragging = $state(false);
	let tippyInstances = $state([]);
	let tippyMap = $state(new Map());
	let svgEl = $state(null);
	let lineX2 = $state(0);
	let showText = $state(false);

	function handleMouseDown(event) {
		if (!guessMode) return;
		isDragging = true;
		event.preventDefault();
		svgEl = event.target.ownerSVGElement;
	}

	function handleTouchStart(event) {
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

		if (series[0]) series[0].value = clampedValue;
		$userResponse.guess = clampedValue;
	}

	function handleTouchMove(event) {
		if (!guessMode || !isDragging || !svgEl) return;

		event.preventDefault();
		const svgRect = svgEl.getBoundingClientRect();
		const touch = event.touches[0];
		const touchX = touch.clientX - svgRect.left;
		const newValue = xScale.invert(touchX);
		const clampedValue = Math.max(0, Math.min(100, newValue));

		if (series[0]) series[0].value = clampedValue;
		$userResponse.guess = clampedValue;
	}

	function handleMouseUp() {
		if (!guessMode) return;
		isDragging = false;
		svgEl = null;
	}

	function handleTouchEnd() {
		if (!guessMode) return;
		isDragging = false;
		svgEl = null;
	}

	// Global mouse and touch listeners when guessing
	$effect(() => {
		if (guessMode) {
			document.addEventListener('mousemove', handleMouseMove);
			document.addEventListener('mouseup', handleMouseUp);
			document.addEventListener('touchmove', handleTouchMove, { passive: false });
			document.addEventListener('touchend', handleTouchEnd);
			return () => {
				document.removeEventListener('mousemove', handleMouseMove);
				document.removeEventListener('mouseup', handleMouseUp);
				document.removeEventListener('touchmove', handleTouchMove);
				document.removeEventListener('touchend', handleTouchEnd);
			};
		}
	});

	// Poll-correct animation
	$effect(() => {
		if (pollCorrectMode && series.length === 2) {
			lineX2 = xScale(series[0].value);
			showText = false;
			setTimeout(() => {
				lineX2 = xScale(series[1].value);
				showText = true;
			}, 50);
		} else if (guessMode || pollCorrectMode) {
			showText = true;
		}
	});

	// Gap line coordinates
	let gapLineCoords = $state(null);
	$effect(() => {
		if (showGapLine && series.length > 1) {
			const sortedSeries = [...series].sort((a, b) => a.value - b.value);
			gapLineCoords = {
				x1: xScale(sortedSeries[0].value),
				x2: xScale(sortedSeries[sortedSeries.length - 1].value)
			};
		} else {
			gapLineCoords = null;
		}
	});

	// Color
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

	// Create tippy instances (sticky + registered by circleId)
	function createTippyInstances() {
		// Clean up any tippy on our row's elements
		const existingCircles = document.querySelectorAll(
			`[data-row-index="${index}"][data-tippy-content]`
		);
		existingCircles.forEach((el) => {
			if (el._tippy && typeof el._tippy.destroy === 'function' && !el._tippy.state.isDestroyed) {
				try {
					el._tippy.destroy();
				} catch (e) {
					console.warn('Destroy tippy error:', e);
				}
			}
		});

		// Clean up tracked instances
		tippyInstances.forEach((inst) => {
			try {
				inst?.destroy?.();
			} catch {}
		});
		tippyInstances = [];
		tippyMap = new Map();

		if (guessMode) return;

		const circles = document.querySelectorAll(`[data-row-index="${index}"][data-tippy-content]`);

		circles.forEach((circle) => {
			try {
				const circleId = circle.getAttribute('data-circle-id');
				const instance = tippy(circle, {
					theme: 'light',
					duration: 0,
					allowHTML: true,
					hideOnClick: false, // stay open unless we hide
					interactive: false,
					trigger: 'mouseenter click',
					appendTo: document.body // important for SVG
				});
				tippyInstances.push(instance);
				tippyMap.set(circleId, instance);

				// If pinned, force open initially. Otherwise let normal triggers handle show/hide.
				if (clickedCircles?.has?.(circleId)) instance.show();
			} catch (e) {
				console.warn('Error creating tippy instance:', e);
			}
		});
	}

	// Recreate tooltips when data/DOM changes
	$effect(() => {
		if (options || series.length > 0) {
			series.forEach((s) => s.value); // depend on values
			setTimeout(createTippyInstances, 0); // after DOM update
		}
	});

	// Sync only pinned tooltips (hide others)
	$effect(() => {
		const _ids = [...(clickedCircles ?? new Set())]; // establish dependency
		tippyMap.forEach((inst, id) => {
			if (clickedCircles.has(id)) {
				inst.show();
			} else {
				inst.hide();
			}
		});
	});

	onMount(() => {
		createTippyInstances();

		// Optional: clicking document hides non-pinned tooltips
		const onDocClick = () => {
			tippyMap.forEach((inst, id) => {
				if (!clickedCircles.has(id)) inst.hide();
			});
		};
		document.addEventListener('click', onDocClick);

		return () => {
			document.removeEventListener('click', onDocClick);
			tippyInstances.forEach((inst) => {
				try {
					inst?.destroy?.();
				} catch {}
			});
			tippyInstances = [];
			tippyMap = new Map();
		};
	});

	function handleCircleClick(event, label) {
		event.stopPropagation();

		// Keep clickedSeries reactive (immutable Set update)
		if (activeView != 'mean') {
			if (clickedSeries.has(label)) {
				// const next = new Set(clickedSeries);
				// next.delete(label);
				// clickedSeries = next;
			} else {
				const next = new Set(clickedSeries);
				next.add(label);
				clickedSeries = next;
			}
		}

		const circleId = `${duty_label}-${label}`;

		// Toggle clickedCircles immutably + immediate show/hide
		if (clickedCircles.has(circleId)) {
			const next = new Set(clickedCircles);
			next.delete(circleId);
			clickedCircles = next;
			tippyMap.get(circleId)?.hide();
		} else {
			const next = new Set(clickedCircles);
			next.add(circleId);
			clickedCircles = next;
			tippyMap.get(circleId)?.show();
		}
	}
</script>

<g
	class="row"
	class:active
	class:highlight
	class:interactive={interactiveMode}
	transform="translate(0, {y})"
	transition:fly={{ duration: $isMobile ? 0 : 500, y: 100, delay: index * 10 }}
	style="--delay: {index * 10}ms;"
	style:--circle-transition={circleTransition}
>
	<line
		x1={dimensions.margins.left}
		x2={xScale.range()[1]}
		y1="0"
		y2="0"
		class="grid-line"
		stroke-width={inIntro ? 2 : 1}
	/>

	{#if showGapLine && gapLineCoords}
		<line
			class="gap-line"
			x1={gapLineCoords.x1}
			y1="0"
			x2={gapLineCoords.x2}
			y2="0"
			stroke="#000"
			stroke-width="4"
			opacity="0.4"
		/>
	{/if}

	{#each series.sort((a, b) => {
		const aMatches = options?.series?.find((d) => d.label.toLowerCase() === a.label.toLowerCase());
		const bMatches = options?.series?.find((d) => d.label.toLowerCase() === b.label.toLowerCase());
		return aMatches ? 1 : bMatches ? -1 : 0;
	}) as s, i}
		{@const shouldHideGuessLabel =
			pollCorrectMode &&
			series.length === 2 &&
			Math.abs(xScale(series[0].value) - xScale(series[1].value)) < 75}

		{@const color = getCircleColor(s)}
		{@const textOffset = $isMobile ? -20 : -30}
		{@const circleId = `${duty_label}-${s.label}`}

		<!-- svelte-ignore a11y_click_events_have_key_events -->
		<!-- svelte-ignore a11y_no_static_element_interactions -->
		<!-- svelte-ignore a11y_mouse_events_have_key_events -->
		<circle
			cx={xScale(s.value)}
			cy="0"
			r={inIntro ? 12 : 6}
			fill={color}
			opacity={interactiveMode ? 0.75 : 1}
			onmousedown={handleMouseDown}
			ontouchstart={handleTouchStart}
			style={guessMode ? 'cursor: grab;' : ''}
			class:interactive={guessMode}
			data-state={s.label}
			data-value={s.value}
			data-duty={duty_label}
			data-row-index={index}
			data-circle-id={circleId}
			data-tippy-content={!guessMode
				? `<b>${s.label ? (s.label.includes('duties') ? 'U.S. average:' : s.label + ':') : ''}</b> ${s.value ? `${s.value.toFixed(0)}%` : ''}`
				: ''}
			onmouseover={() => {
				if (!interactiveMode) return;
				hoveredSeries = s.label;
			}}
			onmouseout={() => {
				if (!interactiveMode) return;
				hoveredSeries = null;
			}}
			onclick={(e) => {
				if (!interactiveMode) return;
				handleCircleClick(e, s.label);
			}}
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

	{#if clickedSeries.size > 0 || (hoveredSeries && !guessMode && !pollCorrectMode)}
		{#each series as s}
			{#if s.label === hoveredSeries || clickedSeries.has(s.label)}
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

	{#key duty_label}
		<text
			class:hide={guessMode}
			class="duty-label"
			x={dimensions.margins.left - ($isMobile ? 0 : 10)}
			y={$isMobile ? interactiveMode ? '-15' : '-12' : '0'}
			dy="0.32em"
			text-anchor={$isMobile ? 'start' : 'end'}
			class:highlight
		>
			{duty_label}
		</text>
	{/key}
</g>

<style lang="scss">
	.row {
		transition: transform 0.5s var(--delay, 0s) cubic-bezier(0.25, 0.1, 0.25, 1);

		.grid-line {
			stroke: var(--color-gray-500);
		}
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
		stroke: var(--bg-color);
		stroke-width: 2;
		paint-order: stroke;

		@include mq('mobile', 'max') {
			font-size: 1rem;
		}

		&.highlight {
			font-weight: 700;
			@include mq('mobile', 'max') {
				font-weight: 400;
			}
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

		@include mq('mobile', 'max') {
			font-size: 1.4rem;
		}
	}

	circle:not(.isDragging) {
		transition: all 0.5s var(--delay, 0s) cubic-bezier(0.25, 0.1, 0.25, 1);
	}

	.hide {
		opacity: 0;
	}

	.gap-line {
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

	@keyframes drawGapLine {
		from {
			stroke-dashoffset: 20;
		}
		to {
			stroke-dashoffset: 0;
		}
	}

	circle:focus {
		outline: none;
	}
</style>
