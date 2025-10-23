<script>
	import { onMount } from 'svelte';
	import { scaleLinear } from 'd3-scale';
	import { fade, fly } from 'svelte/transition';
	import Row from './Row.svelte';
	import { userResponse } from '$lib/stores/userResponse.js';

	import { scaleSequential } from 'd3-scale';
	import { interpolateRgb } from 'd3-interpolate';
	import { interpolateViridis } from 'd3-scale-chromatic';
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import { isMobile } from '$lib/stores/responsive.js';

	// components
	import Controls from './Controls.svelte';
	import GroupLegend from './GroupLegend.svelte';
	import GradientLegend from './GradientLegend.svelte';
	import MapViz from './Map.svelte';
	import Axis from './Axis.svelte';
	import Note from './Note.svelte';

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

	const N_THRESHOLD = 40;

	// Create N lookup maps with normalized keys (lowercase)
	const raceNMap = new Map(raceN.map((d) => [d.raceGroup.toLowerCase(), Number(d.n)]));
	const statesNMap = new Map(statesN.map((d) => [d.State.toLowerCase(), Number(d.n)]));

	function filterDataByN(data, nMap, threshold, groupKey) {
		return data.filter((row) => {
			const n = nMap.get(row[groupKey].toLowerCase());
			return n !== undefined && n >= threshold;
		});
	}

	// Filter data once and reuse
	const filteredStateData = filterDataByN(states, statesNMap, N_THRESHOLD, 'state');
	const filteredRaceData = filterDataByN(race, raceNMap, N_THRESHOLD, 'racegroup');

	let {
		activeId,
		interactiveMode = $bindable(),
		animateMount = true,
		isPinned = false,
		disableTippy = false
	} = $props();
	let activeView = $state('mean');
	let selectedStateView = $state('map');
	let selectedStateChartViewOptions = $state([]);
	let selectedStateMapViewOption = $state(null);
	let guessMode = $derived(activeId == 'poll-guess');
	let pollCorrectMode = $derived(activeId == 'poll-correct');

	let mapData = $derived(
		filteredStateData
			.filter((d) => d.duty_label == selectedStateMapViewOption)
			.sort((a, b) => a.state.localeCompare(b.state))
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
				{ label: 'Independents', color: getCSSVar('--color-theme-yellow') }
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
				{ label: 'Mixed race', color: '#dddddd' }
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
		race: transformGroupedData(filteredRaceData),
		pid: transformGroupedData(pid),
		state: transformGroupedData(filteredStateData)
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

	const minRowHeight = interactiveMode ? ($isMobile ? 45 : 25) : 40;
	let controlsWidth = $state(null);

	// Base dimensions without rowHeight to avoid circular dependency
	const baseDimensions = $derived({
		width:
			interactiveMode && isPinned && !$isMobile ? width - Math.min(controlsWidth || 0, 300) : width,
		height: currentViewData.length * baseRowHeight + baseRowHeight * 2,
		margins: {
			top: interactiveMode ? baseRowHeight : 60,
			right: $isMobile ? 15 : interactiveMode ? 50 : 150,
			bottom: 0,
			left: $isMobile ? 15 : guessMode ? 150 : interactiveMode ? 350 : 450
		}
	});

	const tickSize = 10;

	const showAll = $derived(!currentDataMap[activeId]?.includeArr?.length);

	let dashboardHeight = $state(null);
	let controlsHeight = $state(null);

	let axisHeight = $derived($isMobile ? 80 : 100);

	let noteHeight = $state(0);

	// Reset noteHeight when note is not visible
	$effect(() => {
		if (!interactiveMode) {
			noteHeight = 0;
		}
	});

	// Calculate dynamic row height based on available space
	const rowHeight = $derived.by(() => {
		if (!dashboardHeight) return baseRowHeight;

		const availableHeight = dashboardHeight - axisHeight - noteHeight;

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
		height: currentViewData.length * rowHeight + adjustedMargins.top + adjustedMargins.bottom,
		margins: adjustedMargins
	});

	// Calculate chart container height for pinned mode
	const chartContainerHeight = $derived(
		interactiveMode && isPinned
			? `calc(100svh - ${selectedStateView == 'map' ? 0 : axisHeight}px - ${noteHeight}px)`
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
			.range([baseDimensions.margins.left, baseDimensions.width - baseDimensions.margins.right])
	);

	const createCustomColorScale = (colors) => {
		return scaleLinear().domain([0, 100]).range(colors).interpolate(interpolateRgb);
	};

	const mapColorScale = scaleSequential().interpolator(interpolateViridis).domain([0, 100]);

	// Function to reset clicked series and circles
	function resetSelections(e) {
		// Reset clicked series if interacting outside circles
		if (interactiveMode && !e.target.closest('circle')) {
			clickedSeries = new Set();
			clickedCircles = new Set();
		}
	}

	// Function to handle Escape key
	function handleEscapeKey(e) {
		// Reset clicked series on Escape key
		if (interactiveMode && e.key === 'Escape') {
			clickedSeries = new Set();
			clickedCircles = new Set();
		}
	}

	// 	$inspect(`

	// dashboardHeight: ${dashboardHeight}
	// controlsHeight: ${controlsHeight}
	// rowHeight: ${rowHeight}
	// adjustedDimensions.height: ${adjustedDimensions.height}
	// renderedChartContainerHeight: ${renderedChartContainerHeight}
	// needsScrolling: ${needsScrolling}
	// 			`);
</script>

<div
	class="dashboard"
	class:intro={!interactiveMode}
	class:interactive={interactiveMode}
	class:pinned={interactiveMode && isPinned}
	style:--controls-width="{controlsWidth}px"
	style:--note-height="{noteHeight}px"
	bind:this={dashboardElement}
	bind:clientWidth={width}
	bind:clientHeight={dashboardHeight}
>
	{#if interactiveMode && isPinned}
		<div bind:clientWidth={controlsWidth} class="controls-wrapper pinned" class:mobile={$isMobile}>
			<Controls
				bind:activeView
				bind:selectedStateView
				bind:selectedStateMapViewOption
				bind:selectedStateChartViewOptions
				bind:interactiveMode
				bind:isPinned
				searchOptions={{
					states: Array.from(new Set(filteredStateData.map((d) => d.state))).sort(),
					duties: Array.from(new Set(transformedData.state.map((d) => d.duty_label))).sort()
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

			{#if options.find((o) => o.value === activeView)?.series?.length > 1}
				<div class="legend-wrapper">
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
			{/if}
			{#if !$isMobile}
				<Note {activeView} />
			{/if}
		</div>
	{/if}

	<div class="dashboard-content">
		{#if interactiveMode && activeView == 'state' && selectedStateView == 'map'}
			<div class="map-wrapper">
				<MapViz
					data={mapData}
					width={baseDimensions.width}
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
				width={baseDimensions.width}
				height={adjustedDimensions.height}
				role="img"
				aria-label="Data visualization chart"
				onclick={resetSelections}
				ontouchend={resetSelections}
				onkeydown={handleEscapeKey}
			>
				<g class="rows">
					{#each sortedViewData as row, i (row.duty_label)}
						<Row
							{...row}
							y={i * rowHeight + adjustedDimensions.margins.top}
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
							{disableTippy}
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
					width={baseDimensions.width}
					dimensions={adjustedDimensions}
					{axisHeight}
					{tickSize}
					{xScale}
					inIntro={!interactiveMode}
				/>
			</div>
		{/if}

		{#if $isMobile}
			<Note {activeView} bind:noteHeight position="bottom" />
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

		@include mq('small-mobile', 'max') {
			justify-content: flex-end;
		}

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
			display: flex;
			flex-direction: row;

			@include mq('mobile', 'max') {
				flex-direction: column;
			}

			.dashboard-content {
				flex: 1;
				display: flex;
				flex-direction: column;
				overflow: hidden;
				margin-left: min(var(--controls-width), 300px);

				@include mq('mobile', 'max') {
					margin-left: 0;
					margin-top: var(--controls-height, 0);
				}

				.chart-container {
					flex: 1;
					position: relative;

					&.needs-scrolling {
						overflow: auto;
					}
				}
			}
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

			@include mq('mobile', 'max') {
				padding-bottom: 0.5rem;
			}

			&.pinned {
				position: fixed;
				top: var(--header-height, 80px);
				left: 0;
				width: min(var(--controls-width), 300px);
				max-width: 300px;
				height: calc(100svh - var(--header-height, 80px));
				z-index: 100;
				overflow-y: auto;
				box-shadow: 2px 0 10px 0 rgba(0, 0, 0, 0.1);
				display: flex;
				flex-direction: column;
				gap: 1rem;
				overflow-y: scroll;

				// Ensure Controls component takes available space
				:global(.controls) {
					flex: 1;
					display: flex;
					flex-direction: column;
				}

				@include mq('mobile', 'max') {
					position: sticky;
					top: 0;
					width: 100%;
					max-width: none;
					height: auto;
					box-shadow: 0 2px 10px 0 rgba(0, 0, 0, 0.1);
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
	}

	// Map container
	.map-wrapper {
		position: absolute;
		top: 0;
		left: 0;
		margin-left: min(var(--controls-width), 300px);
		width: calc(100% - var(--controls-width));
		height: calc(100svh - var(--header-height, 80px) - var(--note-height));
		background-color: var(--bg-color);
		z-index: 10;
		transition: all 0.5s ease;

		@include mq('mobile', 'max') {
			margin-left: 0;
			width: 100%;
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
			width: 100%;
			height: 0px;
			bottom: 0;
			&::after {
				content: '';

				bottom: -1px;
				left: 0;
				right: 0;
				position: absolute;

				bottom: -1px;
				left: 0;
				right: 0;
				width: 100%;
				height: 25px;
				background: linear-gradient(to bottom, transparent, $color-theme-light);
				pointer-events: none;
				z-index: 10;
			}
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

	.legend-wrapper {
		padding-top: 1rem;
		margin-top: 1rem;
		border-top: 1px solid var(--color-gray-200);
	}
</style>
