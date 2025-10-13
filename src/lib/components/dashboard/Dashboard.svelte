<script>
	import { onMount } from 'svelte';
	import { scaleLinear } from 'd3-scale';
	import { fade, fly } from 'svelte/transition';
	import Row from './Row.svelte';
	import { userResponse } from '$lib/stores/userResponse.js';

	import { scaleSequential } from 'd3-scale';
	import { interpolateRgb } from 'd3-interpolate';
	import { interpolateYlGn } from 'd3-scale-chromatic';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	// components
	import Controls from './Controls.svelte';
	import GroupLegend from './GroupLegend.svelte';
	import GradientLegend from './GradientLegend.svelte';
	import MapViz from './Map.svelte';
	import Axis from './Axis.svelte';

	// data imports
	import mean from '$lib/data/csvs/mean_duties_weighted.csv';
	import gender from '$lib/data/csvs/table_gender.csv';
	import generation from '$lib/data/csvs/table_generation.csv';
	import race from '$lib/data/csvs/table_racegroup.csv';
	import pid from '$lib/data/csvs/table_pid3.csv';
	import states from '$lib/data/csvs/mean_duties_weighted_by_state.csv';
	import { get } from 'svelte/store';

	// n counts
	import statesN from '$lib/data/csvs/states_n.csv';
	import raceN from '$lib/data/csvs/race_n.csv';

	const N_THRESHOLD = 30;

	// Create N lookup maps with normalized keys (lowercase)
	const raceNMap = new Map(raceN.map((d) => [d.raceGroup.toLowerCase(), Number(d.n)]));
	const statesNMap = new Map(statesN.map((d) => [d.State.toLowerCase(), Number(d.n)]));

	function filterDataByN(data, nMap, threshold, groupKey) {
		return data.filter((row) => {
			const n = nMap.get(row[groupKey].toLowerCase());
			return n !== undefined && n >= threshold;
		});
	}
	let { activeId, interactiveMode = $bindable(), animateMount = true, isPinned = false } = $props();
	let activeView = $state('mean');
	let selectedStateView = $state('map');
	let selectedStateChartViewOptions = $state([]);
	let selectedStateMapViewOption = $state(null);
	let guessMode = $derived(activeId == 'poll-guess');
	let pollCorrectMode = $derived(activeId == 'poll-correct');
	let mapData = $derived(
		filterDataByN(states, statesNMap, N_THRESHOLD, 'state').filter(
			(d) => d.duty_label == selectedStateMapViewOption
		)
	);
	let hoveredSeries = $state(null);
	let clickedSeries = $state(new Set());
	let clickedCircles = $state(new Set());

	$effect(() => {
		if (activeId != '9999-dashboard') {
			activeView = 'mean';
		}
	});

	// Reset dashboard to default interactive mode settings when unpinned
	$effect(() => {
		if (interactiveMode && !isPinned) {
			// Reset to default interactive mode settings
			activeView = 'mean';
			selectedStateView = 'map';
			selectedStateChartViewOptions = [];
			// Reset selectedStateMapViewOption to first state if available
			if (states && states.length > 0) {
				selectedStateMapViewOption = states[0].state;
			}
		}
	});

	// Store correct answer when in poll-correct mode
	$effect(() => {
		if (pollCorrectMode && currentViewData.length > 0) {
			// Only update if the correct answer has actually changed to avoid reactive loops
			const newCorrectAnswer = currentViewData[0].series[1].value;
			if ($userResponse.correctAnswer !== newCorrectAnswer) {
				$userResponse.correctAnswer = newCorrectAnswer;
			}
		}
	});

	// Set initial selectedStateMapViewOption when states data is available
	$effect(() => {
		if (states && states.length > 0) {
			selectedStateMapViewOption = states[0].state;
		}
	});

	// Prevent body scrolling when dashboard is pinned
	$effect(() => {
		if (interactiveMode && isPinned) {
			document.body.style.overflow = 'hidden';
		} else {
			document.body.style.overflow = '';
		}

		// Cleanup on component destroy
		return () => {
			document.body.style.overflow = '';
		};
	});

	// Initialize selectedStateChartViewOptions when switching to chart view
	$effect(() => {
		if (selectedStateView === 'chart') {
			selectedStateChartViewOptions = [];
		}
	});

	const options = $derived([
		{
			label: 'Gender',
			value: 'gender',
			series: [
				{ label: 'Men', color: getCSSVar('--color-theme-blue') },
				{ label: 'Women', color: getCSSVar('--color-theme-green') }
			]
		},
		{
			label: 'Political Identification',
			value: 'pid',
			series: [
				{ label: 'Democrats', color: getCSSVar('--color-theme-dem-blue') },
				{ label: 'Republicans', color: getCSSVar('--color-theme-gop-red') },
				{ label: 'Independents', color: getCSSVar('#dddddd') }
			]
		},
		{
			label: 'Generation',
			value: 'generation',
			series: [
				{ label: 'Gen Z', color: getCSSVar('--color-theme-yellow') },
				{ label: 'Millennials', color: getCSSVar('--color-theme-green') },
				{ label: 'Gen X', color: getCSSVar('--color-theme-blue') },
				{ label: 'Baby Boomers', color: getCSSVar('--color-theme-red') }
			]
		},
		{
			label: 'Race/Ethnicity',
			value: 'race',
			series: [
				{ label: 'White', color: getCSSVar('--color-theme-blue') },
				{ label: 'Black', color: getCSSVar('--color-theme-green') },
				{ label: 'Hispanic', color: getCSSVar('--color-theme-yellow') },
				{ label: 'Asian', color: getCSSVar('--color-theme-red') },
				{ label: 'Other', color: '#dddddd' }
			]
		},
		{
			label: 'State',
			value: 'state',
			series:
				selectedStateView === 'chart' && selectedStateChartViewOptions.length > 0
					? selectedStateChartViewOptions.map((state, index) => ({
							label: state,
							color: [
								getCSSVar('--color-theme-blue'),
								getCSSVar('--color-theme-green'),
								getCSSVar('--color-theme-yellow')
							][index % 3]
						}))
					: [] // Empty array when no states selected
		}
	]);

	// data maps
	let currentDataMap = {
		'poll-guess': {
			includeArr: ['Defending freedom'],
			highlightArr: ['Defending freedom']
		},
		'poll-correct': {
			includeArr: ['Defending freedom'],
			highlightArr: ['Defending freedom'],
			showGapLine: true
		},
		'chart-constitution': {
			includeArr: ['Voting', 'Following the Constitution', 'Paying your taxes'],
			highlightArr: ['Voting', 'Following the Constitution', 'Paying your taxes']
		},
		'chart-charity': {
			includeArr: ['Donating to charity', 'Joining the military', 'Welcoming refugees'],
			highlightArr: ['Donating to charity', 'Joining the military', 'Welcoming refugees']
		},
		'chart-party-agree': {
			includeArr: ['Defending freedom', 'Voting', 'Helping your community'],
			highlightArr: ['Defending freedom', 'Voting', 'Helping your community'],
			view: 'pid',
			series: [
				{ label: 'Democrats', color: getCSSVar('--color-theme-dem-blue') },
				{ label: 'Republicans', color: getCSSVar('--color-theme-gop-red') }
			]
		},
		'chart-party-disagree': {
			includeArr: ['Loving America', 'Supporting equality'],
			highlightArr: ['Loving America', 'Supporting equality'],
			view: 'pid',
			series: [
				{ label: 'Democrats', color: getCSSVar('--color-theme-dem-blue') },
				{ label: 'Republicans', color: getCSSVar('--color-theme-gop-red') }
			],
			showGapLine: true
		},
		'chart-generation': {
			includeArr: ['Supporting Democracy', 'Honoring the flag', 'Connecting across differences'],
			highlightArr: ['Supporting Democracy', 'Honoring the flag', 'Connecting across differences'],
			view: 'generation',
			series: [
				{ label: 'Gen Z', color: getCSSVar('--color-theme-blue') },
				{ label: 'Baby Boomers', color: getCSSVar('--color-theme-yellow') }
			],
			showGapLine: true
		},
		'10-chart-majority': {
			includeArr: [
				'Defending freedom',
				'Following the Constitution',
				'Donating to charity',
				"Fighting for people's rights",
				'Honoring the flag'
			],
			highlightArr: ["Fighting for people's rights", 'Honoring the flag']
		},
		'11-outro': [],
		'12-outro': [],
		'13-outro': [],
		transition: [],
		'9999-dashboard': []
	};

	function transformGroupedData(data) {
		if (!data || data.length === 0) return [];

		data.sort((a, b) => b.mean - a.mean);

		// Infer group key: find key that isn't 'duty_label' or 'mean'
		const groupKey = Object.keys(data[0]).find((key) => key !== 'duty_label' && key !== 'mean');

		if (!groupKey) throw new Error('No group key found in data');

		// Group by duty_label
		const grouped = new Map();

		data.forEach((d) => {
			const label = d.duty_label;
			if (!grouped.has(label)) {
				grouped.set(label, []);
			}

			grouped.get(label).push({
				label: d[groupKey],
				value: Number(d.mean)
			});
		});

		// Build result
		let id = 1;
		const result = [];

		for (const [duty_label, series] of grouped.entries()) {
			result.push({
				id: id++,
				duty_label,
				group: groupKey,
				series
			});
		}

		return result;
	}

	const transformedData = {
		mean: transformGroupedData(mean),
		gender: transformGroupedData(gender),
		generation: transformGroupedData(generation),
		race: transformGroupedData(filterDataByN(race, raceNMap, N_THRESHOLD, 'racegroup')),
		pid: transformGroupedData(pid),
		state: transformGroupedData(filterDataByN(states, statesNMap, N_THRESHOLD, 'state'))
	};

	let currentViewData = $derived.by(() => {
		if (!currentDataMap[activeId]) {
			return [];
		}

		// Determine which dataset to use based on view property or activeView
		const dataView = currentDataMap[activeId]?.view || activeView;
		const dataSource = transformedData[dataView] || transformedData[activeView];

		if (guessMode) {
			return dataSource
				.filter((d) =>
					currentDataMap[activeId]?.includeArr?.length
						? currentDataMap[activeId]?.includeArr.includes(d.duty_label)
						: true
				)
				.map((d) => ({
					...d,
					series: [{ label: 'Your guess', value: $userResponse.guess }]
				}));
		}

		if (pollCorrectMode) {
			return dataSource
				.filter((d) =>
					currentDataMap[activeId]?.includeArr?.length
						? currentDataMap[activeId]?.includeArr.includes(d.duty_label)
						: true
				)
				.map((d) => ({
					...d,
					series: [
						{ label: 'Your guess', value: $userResponse.guess },
						{ label: 'Correct answer', value: d.series[0].value }
					]
				}));
		}

		// Use custom series if defined in currentDataMap, otherwise use full dataset
		const baseData = dataSource.filter((d) =>
			currentDataMap[activeId]?.includeArr?.length
				? currentDataMap[activeId]?.includeArr.includes(d.duty_label)
				: true
		);

		// If custom series is defined, filter to only show those series
		if (currentDataMap[activeId]?.series) {
			return baseData.map((d) => ({
				...d,
				series: d.series.filter((s) =>
					currentDataMap[activeId].series.some((customSeries) => customSeries.label === s.label)
				)
			}));
		}

		return baseData;
	});

	// Sort currentViewData when viewing state data in chart mode
	let sortedViewData = $derived.by(() => {
		if (
			activeView === 'state' &&
			selectedStateView == 'chart' &&
			selectedStateChartViewOptions.length > 0
		) {
			// Find the state data for the first selected state
			const stateData = states.filter((d) => d.state === selectedStateChartViewOptions[0]);

			// Sort duties by their values for the first selected state (descending)
			return [...currentViewData].sort((a, b) => {
				const aValue = stateData.find((d) => d.duty_label === a.duty_label)?.mean || 0;
				const bValue = stateData.find((d) => d.duty_label === b.duty_label)?.mean || 0;
				return bValue - aValue; // Descending order
			});
		}
		return currentViewData;
	});

	let width = $state(0);
	const baseRowHeight = interactiveMode ? 35 : 45;
	const minRowHeight = interactiveMode ? 20 : 40;

	// Base dimensions without rowHeight to avoid circular dependency
	const baseDimensions = $derived({
		width,
		height: currentViewData.length * baseRowHeight + baseRowHeight * 2,
		margins: {
			top: interactiveMode ? baseRowHeight : 60,
			right: interactiveMode ? 50 : 150,
			bottom: interactiveMode ? baseRowHeight : 0,
			left: guessMode ? 150 : 450
		}
	});

	const tickSize = 10;

	const showAll = $derived(!currentDataMap[activeId]?.includeArr?.length);

	let dashboardHeight = $state(null);
	let controlsHeight = $state(null);
	let axisHeight = 50;
	let noteHeight = $state(0);

	// Reset noteHeight when note is not visible
	$effect(() => {
		if (!interactiveMode || (activeView !== 'state' && activeView !== 'race')) {
			noteHeight = 0;
		}
	});

	// Calculate dynamic row height based on available space
	const rowHeight = $derived.by(() => {
		if (!dashboardHeight || !controlsHeight) return baseRowHeight;

		const availableHeight = dashboardHeight - axisHeight - controlsHeight - noteHeight;

		const requiredHeight =
			currentViewData.length * baseRowHeight +
			baseDimensions.margins.top +
			baseDimensions.margins.bottom;

		if (requiredHeight <= availableHeight) {
			return baseRowHeight;
		}

		// Calculate height needed per row
		const calculatedHeight = Math.max(
			minRowHeight,
			(availableHeight - baseDimensions.margins.top - baseDimensions.margins.bottom) /
				currentViewData.length
		);

		return calculatedHeight;
	});

	// Calculate margins with rowHeight
	const adjustedMargins = $derived({
		...baseDimensions.margins,
		top: interactiveMode ? rowHeight : 60,
		bottom: 0
	});

	// Final dimensions with rowHeight in margins and adjusted height
	// Add extra space for the last row to align with axis baseline
	const adjustedDimensions = $derived({
		...baseDimensions,
		height: (currentViewData.length + 1) * rowHeight + adjustedMargins.top + adjustedMargins.bottom,
		margins: adjustedMargins
	});

	// Calculate chart container height for pinned mode
	const chartContainerHeight = $derived(
		interactiveMode && isPinned
			? `calc(100vh - ${controlsHeight || 200}px - ${selectedStateView == 'map' ? 0 : axisHeight}px - ${noteHeight}px)`
			: adjustedDimensions.height
	);

	let renderedChartContainerHeight = $state(0);
	let dashboardElement = $state(null);

	// Check if SVG is larger than container and needs scrolling
	const needsScrolling = $derived(
		interactiveMode &&
			isPinned &&
			adjustedDimensions.height > renderedChartContainerHeight + rowHeight
	);

	const xScale = $derived(
		scaleLinear()
			.domain([0, 100])
			.range([baseDimensions.margins.left, width - baseDimensions.margins.right])
	);

	const createCustomColorScale = (colors) => {
		return scaleLinear().domain([0, 100]).range(colors).interpolate(interpolateRgb);
	};

	const mapColorScale = scaleSequential().interpolator(interpolateYlGn).domain([0, 100]);
</script>

<div
	class="dashboard"
	class:intro={!interactiveMode}
	class:interactive={interactiveMode}
	class:pinned={interactiveMode && isPinned}
	style:--controls-height="{controlsHeight}px"
	bind:this={dashboardElement}
	bind:clientWidth={width}
	bind:clientHeight={dashboardHeight}
>
	{#if interactiveMode && isPinned}
		<div bind:clientHeight={controlsHeight} class="controls-wrapper pinned">
			<Controls
				bind:activeView
				bind:selectedStateView
				bind:selectedStateMapViewOption
				bind:selectedStateChartViewOptions
				bind:interactiveMode
				bind:isPinned
				searchOptions={{
					states: new Set(
						states
							.map((d) => d.state)
							.filter((state, index, self) => {
								// Get unique states and check if they meet N threshold
								const isUnique = self.indexOf(state) === index;
								const n = statesNMap.get(state.toLowerCase());
								return isUnique && n !== undefined && n >= N_THRESHOLD;
							})
					),
					duties: new Set(transformedData.state.map((d) => d.duty_label))
				}}
				onExit={() => {
					// Scroll to dashboard element when exiting pinned view
					setTimeout(() => {
						if (dashboardElement) {
							dashboardElement.scrollIntoView({ behavior: 'instant', block: 'start' });
						}
					}, 100);
				}}
			/>
			<div class="dashboard-legend">
				{#if activeView == 'state' && selectedStateView == 'map'}
					<GradientLegend colorScale={mapColorScale} />
				{:else}
					<GroupLegend
						options={options.find((o) => o.value === activeView)}
						{activeView}
						interactive={true}
						bind:clickedSeries
					/>
				{/if}
			</div>
		</div>
	{/if}

	<div class="dashboard-content">
		<!-- {#if interactiveMode && !isPinned}
			<div class="overlay" transition:fade={{ duration: 500 }}>
				<button class="explore-button" onclick={() => (isPinned = true)}>Explore the data</button>
			</div>
		{/if} -->

		{#if interactiveMode && activeView == 'state' && selectedStateView == 'map'}
			<div class="map-container">
				<MapViz
					data={mapData}
					{width}
					duty={selectedStateMapViewOption}
					colorScale={mapColorScale}
				/>
			</div>
		{/if}
		<div
			class="chart-container {interactiveMode ? 'interactive-mode' : ''} {needsScrolling
				? 'needs-scrolling'
				: ''}"
			style:--chart-height={chartContainerHeight}
			bind:clientHeight={renderedChartContainerHeight}
		>
			<!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
			<svg
				{width}
				height={adjustedDimensions.height}
				role="img"
				aria-label="Data visualization chart"
				onclick={(e) => {
					// Reset clicked series if clicking outside circles
					if (interactiveMode && !e.target.closest('circle')) {
						clickedSeries = new Set();
						clickedCircles = new Set();
					}
				}}
				onkeydown={(e) => {
					// Reset clicked series on Escape key
					if (interactiveMode && e.key === 'Escape') {
						clickedSeries = new Set();
						clickedCircles = new Set();
					}
				}}
			>
				<g class="rows">
					{#each sortedViewData as row, i (row.duty_label)}
						<Row
							{...row}
							y={i * rowHeight + adjustedDimensions.margins.top + rowHeight / 2}
							{xScale}
							dimensions={adjustedDimensions}
							{rowHeight}
							{guessMode}
							{pollCorrectMode}
							{tickSize}
							index={i}
							active={showAll || currentDataMap[activeId]?.highlightArr.includes(row.duty_label)}
							highlight={currentDataMap[activeId]?.highlightArr?.length
								? currentDataMap[activeId]?.highlightArr.includes(row.duty_label)
								: false}
							options={options.find((o) => o.value === activeView)}
							customSeries={currentDataMap[activeId]?.series}
							circleTransition={activeView == 'state' || interactiveMode
								? 'fill 0.5s ease-out,'
								: 'fill 0.5s ease-out, cx 0.5s ease-out'}
							{interactiveMode}
							inIntro={!interactiveMode}
							bind:hoveredSeries
							bind:clickedSeries
							bind:clickedCircles
							showGapLine={currentDataMap[activeId]?.showGapLine}
							{activeView}
						/>
					{/each}
				</g>
			</svg>

			{#if needsScrolling && activeView != 'state'}
				<div
					class="bottom-gradient"
					style="position: {interactiveMode ? 'sticky' : 'absolute'}"
				></div>
			{/if}
			<!-- Bottom gradient overlay -->
		</div>

		{#if activeView != 'state' || selectedStateView != 'map'}
			<div class="axis-wrapper" class:sticky={interactiveMode}>
				<Axis
					{width}
					dimensions={adjustedDimensions}
					{axisHeight}
					{tickSize}
					{xScale}
					inIntro={!interactiveMode}
				/>
			</div>
		{/if}

		{#if interactiveMode && (activeView === 'state' || activeView === 'race')}
			<div class="n-threshold-note" class:sticky={interactiveMode} bind:clientHeight={noteHeight}>
				{#if activeView === 'state'}
					Only states with more than N = 30 participants are included
				{:else}
					Only categories with more than N = 30 participants are included
				{/if}
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.dashboard {
		// Base styles
		display: flex;
		flex-direction: column;
		justify-content: center;
		position: relative;
		width: 100%;
		height: 100svh;
		margin: 0 auto;
		background-color: var(--bg-color);
		transition: all 0.5s ease;
		font-family: sans-serif;

		// Interactive mode styles
		&.interactive {
			height: 100svh;
			overflow: hidden;
			justify-content: center;
		}

		// Pinned mode styles
		&.pinned {
			height: calc(100svh - var(--header-height, 80px));
			margin-top: var(--header-height, 80px);
			// position: fixed;
			// top: 0;
			// left: 0;
			// width: 100vw;
			// height: 100vh;
			// z-index: 1000;
			// border: 10px solid var(--color-theme-blue);

			.dashboard-content {
				flex: 1;
				display: flex;
				flex-direction: column;
				overflow: hidden;

				.chart-container {
					flex: 1;
					margin-top: var(--controls-height);

					&.needs-scrolling {
						overflow: auto;
					}
				}
			}
		}

		// Dashboard content
		.dashboard-content {
			// Content styles here if needed
		}

		// Dashboard legend
		.dashboard-legend {
			margin-top: 0.5rem;
		}

		// Controls wrapper
		.controls-wrapper {
			width: 100%;
			margin: 0 auto;
			position: sticky;
			top: 0;
			z-index: 1000;
			padding: 1rem;
			box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.1);
			background-color: #fff;

			&.pinned {
				position: fixed;
				top: var(--header-height, 80px);
				z-index: 10001;
			}

			.unpin-button {
				display: flex;
				align-items: center;
				gap: 0.5rem;
				background: none;
				border: 2px solid var(--color-theme-blue);
				color: var(--color-theme-blue);
				padding: 0.5rem 1rem;
				border-radius: 8px;
				cursor: pointer;
				font-size: 0.9rem;
				font-weight: 500;
				transition: all 0.2s ease;

				&:hover {
					background-color: var(--color-theme-blue);
					color: white;
				}

				svg {
					width: 16px;
					height: 16px;
				}
			}
		}

		// Axis wrapper
		.axis-wrapper {
			background-color: var(--bg-color);

			&.sticky {
				position: sticky;
				bottom: 0;
				z-index: 1000;
			}
		}

		// N threshold note
		.n-threshold-note {
			background-color: var(--bg-color);
			padding: 0.75rem 1rem;
			text-align: center;
			font-size: 0.875rem;
			color: #666;
			font-style: italic;

			&.sticky {
				position: sticky;
				bottom: 0;
				z-index: 1000;
			}
		}
	}

	// Map container
	.map-container {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: calc(100svh - var(--controls-height));
		margin-top: var(--controls-height);
		background-color: var(--bg-color);
		z-index: 10;
		transition: all 0.5s ease;

		&.visible {
			opacity: 1;
			pointer-events: auto;
		}
	}

	// Chart container
	.chart-container {
		height: var(--chart-height);
		max-height: var(--chart-max-height);
		overflow: auto;

		&.interactive-mode {
			overflow: hidden;
		}

		&.needs-scrolling {
			overflow: auto;
		}

		.bottom-gradient {
			position: absolute;
			bottom: -1px;
			left: 0;
			right: 0;
			height: 40px;
			background: linear-gradient(to bottom, transparent, $color-theme-light);
			pointer-events: none;
			z-index: 10;
		}
	}

	// Global SVG styles
	:global(svg) {
		display: block;
		font-size: 14px;
		font-family: sans-serif;
	}

	// Local SVG styles
	svg {
		transition: height 0.5s ease;
	}
</style>
