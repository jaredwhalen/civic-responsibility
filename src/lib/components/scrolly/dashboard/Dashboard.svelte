<script>
	import { onMount } from 'svelte';
	import { scaleLinear } from 'd3-scale';
	import { fade, fly } from 'svelte/transition';
	import Row from './Row.svelte';
	import { userResponse } from '$lib/stores/userResponse.js';

	import { interpolateRgb } from 'd3-interpolate';

	// components
	import Controls from './Controls.svelte';
	import GroupLegend from './GroupLegend.svelte';
	import GradientLegend from './GradientLegend.svelte';
	import MapViz from './Map.svelte';

	// data imports
	import mean from '$lib/data/csvs/mean_duties_weighted.csv';
	import gender from '$lib/data/csvs/table_gender.csv';
	import generation from '$lib/data/csvs/table_generation.csv';
	import race from '$lib/data/csvs/table_racegroup.csv';
	import pid from '$lib/data/csvs/table_pid3.csv';
	import states from '$lib/data/csvs/mean_duties_weighted_by_state.csv';

	let { activeId, interactiveMode = $bindable(), animateMount = true } = $props();
	let activeView = $state('mean');
	let selectedStateView = $state('chart');
	let selectedStateViewOption = $state(null);
	let guessMode = $derived(activeId == '6-poll-guess');
	let mapData = $derived(states.filter((d) => d.duty_label == selectedStateViewOption));
	let hoveredSeries = $state(null);

	let isMountedWithDelay = $state(false);

	onMount(() => {
		if (interactiveMode) {
			setTimeout(() => {
				isMountedWithDelay = true;
			}, 250);
		}
	});

	$effect(() => {
		if (activeId != '9999-dashboard') {
			activeView = 'mean';
		}
	});

	// Set initial selectedStateViewOption when states data is available
	$effect(() => {
		if (states && states.length > 0) {
			selectedStateViewOption = states[0].state;
		}
	});

	const options = $derived([
		{
			label: 'Gender',
			value: 'gender',
			series: [
				{ label: 'Male', color: '#64B42D' },
				{ label: 'Female', color: '#FAD246' }
			]
		},
		{
			label: 'Generation',
			value: 'generation',
			series: [
				{ label: 'Gen Z', color: '#64B42D' },
				{ label: 'Millennials', color: '#FAD246' },
				{ label: 'Gen X', color: '#5C80BC' },
				{ label: 'Baby Boomers', color: '#E63719' }
			]
		},
		{
			label: 'Race/Ethnicity',
			value: 'race',
			series: [
				{ label: 'White', color: '#64B42D' },
				{ label: 'Black', color: '#FAD246' },
				{ label: 'Hispanic', color: '#5C80BC' },
				{ label: 'Asian', color: '#E63719' },
				{ label: 'Other', color: '#ddd' }
			]
		},
		{
			label: 'Political Identification',
			value: 'pid',
			series: [
				{ label: 'Democrat', color: '#5C80BC' },
				{ label: 'Republican', color: '#E63719' },
				{ label: 'Independent', color: '#FAD246' }
			]
		},
		{
			label: 'State',
			value: 'state',
			series: [
				{
					label: selectedStateViewOption,
					color: '#64B42D'
				}
			]
		}
	]);

	// data maps
	let currentDataMap = {
		'6-poll-guess': {
			includeArr: ['Supporting democracy'],
			highlightArr: ['Supporting democracy']
		},
		'7-poll-correct': {
			includeArr: ['Supporting democracy'],
			highlightArr: ['Supporting democracy']
		},
		'8-chart-taxes': {
			includeArr: ['Supporting democracy', 'Paying your taxes'],
			highlightArr: ['Paying your taxes']
		},
		'9-chart-charity': {
			includeArr: ['Supporting democracy', 'Paying your taxes', 'Donating to charity'],
			highlightArr: ['Donating to charity']
		},
		'10-chart-majority': {
			includeArr: [
				'Supporting democracy',
				'Paying your taxes',
				'Donating to charity',
				'Fighting for people’s rights',
				'Honoring the flag'
			],
			highlightArr: ['Fighting for people’s rights', 'Honoring the flag']
		},
		'11-outro': [],
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
		race: transformGroupedData(race),
		pid: transformGroupedData(pid),
		state: transformGroupedData(states)
	};

	let currentViewData = $derived.by(() => {
		if (!currentDataMap[activeId]) {
			return [];
		}

		return guessMode
			? transformedData.mean
					.filter((d) =>
						currentDataMap[activeId]?.includeArr?.length
							? currentDataMap[activeId]?.includeArr.includes(d.duty_label)
							: true
					)
					.map((d) => ({
						...d,
						series: [{ label: 'mean', value: $userResponse.guess }]
					}))
			: transformedData[activeView].filter((d) =>
					currentDataMap[activeId]?.includeArr?.length
						? currentDataMap[activeId]?.includeArr.includes(d.duty_label)
						: true
				);
	});

	// Sort currentViewData when viewing state data in chart mode
	let sortedViewData = $derived.by(() => {
		if (activeView === 'state' && selectedStateView == 'chart') {
			// Find the state data for the selected state
			const stateData = states.filter((d) => d.state === selectedStateViewOption);

			// Sort duties by their values for the selected state (descending)
			return [...currentViewData].sort((a, b) => {
				const aValue = stateData.find((d) => d.duty_label === a.duty_label)?.mean || 0;
				const bValue = stateData.find((d) => d.duty_label === b.duty_label)?.mean || 0;
				return bValue - aValue; // Descending order
			});
		}
		return currentViewData;
	});

	let width = $state(0);
	const rowHeight = 28;

	const dimensions = $derived({
		width,
		height: currentViewData.length * rowHeight + rowHeight * 2,
		margins: {
			top: 15,
			right: 75,
			bottom: 0,
			left: 400
		}
	});

	const xScale = $derived(
		scaleLinear()
			.domain([0, 100])
			.range([dimensions.margins.left, width - dimensions.margins.right])
	);

	const tickSize = 10;

	const showAll = $derived(!currentDataMap[activeId]?.includeArr?.length);

	let dashboardHeight = $state(null);
	let controlsHeight = $state(null);
	let axisHeight = 50;

	let chartContainerHeight = $derived(
		interactiveMode && isMountedWithDelay
			? dimensions.height < dashboardHeight
				? dimensions.height - axisHeight
				: dashboardHeight - controlsHeight - (selectedStateView == 'map' ? 0 : axisHeight)
			: dimensions.height - axisHeight
	);

	let chartContainerHeightMaxHeight = $derived(
		dashboardHeight - controlsHeight - (selectedStateView == 'map' ? 0 : axisHeight)
	);

	const createCustomColorScale = (colors) => {
		return scaleLinear().domain([0, 100]).range(colors).interpolate(interpolateRgb);
	};
	const mapColorScale = createCustomColorScale(['#fff', '#6DA34D']);
</script>

<div
	class="dashboard {showAll ? 'show-all' : ''} {chartContainerHeight >= dashboardHeight
		? 'overflow'
		: ''}"
	bind:clientWidth={width}
	bind:clientHeight={dashboardHeight}
>
	{#if interactiveMode}
		<div bind:clientHeight={controlsHeight}>
			<Controls
				bind:activeView
				bind:selectedStateView
				bind:selectedStateViewOption
				bind:interactiveMode
				searchOptions={{
					states: new Set(states.map((d) => d.state)),
					duties: new Set(transformedData.state.map((d) => d.duty_label))
				}}
			/>
			{#if selectedStateView == 'map'}
				<GradientLegend colorScale={mapColorScale} />
			{:else}
				<GroupLegend options={options.find((o) => o.value === activeView)} {activeView} />
			{/if}
		</div>
	{/if}

	<div class="dashboard-content">
		{#if interactiveMode && activeView == 'state' && selectedStateView == 'map'}
			<div class="map-container">
				<MapViz data={mapData} {width} duty={selectedStateViewOption} colorScale={mapColorScale} />
			</div>
		{/if}
		<div
			class="chart-container {interactiveMode && isMountedWithDelay ? 'interactive-mode' : ''}"
			style:--chart-height="{chartContainerHeight}px"
			style:--chart-max-height="{chartContainerHeightMaxHeight}px"
		>
			<svg {width} height={dimensions.height}>
				<g class="rows">
					{#each sortedViewData as row, i (row.duty_label)}
						<Row
							{...row}
							y={i * rowHeight + dimensions.margins.top}
							{xScale}
							{dimensions}
							{rowHeight}
							{guessMode}
							{tickSize}
							index={i}
							active={showAll || currentDataMap[activeId]?.highlightArr.includes(row.duty_label)}
							highlight={currentDataMap[activeId]?.highlightArr?.length
								? currentDataMap[activeId]?.highlightArr.includes(row.duty_label)
								: false}
							options={options.find((o) => o.value === activeView)}
							circleTransition={activeView == 'state' || (interactiveMode && !isMountedWithDelay)
								? 'fill 0.5s ease-out'
								: 'fill 0.5s ease-out, cx 0.5s ease-out'}
							{interactiveMode}
							bind:hoveredSeries
						/>
					{/each}
				</g>
			</svg>

			{#if showAll && activeView != 'state'}
				<div
					class="bottom-gradient"
					style="position: {interactiveMode && isMountedWithDelay ? 'sticky' : 'absolute'}"
				></div>
			{/if}
			<!-- Bottom gradient overlay -->
		</div>

		{#if activeView != 'state' || selectedStateView != 'map'}
			<div class="axis-container">
				<svg {width} height={axisHeight}>
					<g class="x-axis axis">
						<line
							x1={dimensions.margins.left}
							x2={width - dimensions.margins.right}
							stroke="#ddd"
							stroke-width="2"
						/>
						{#each [0, 25, 50, 75, 100] as tickValue}
							<line
								x1={xScale(tickValue)}
								x2={xScale(tickValue)}
								y1={0}
								y2={tickSize}
								stroke="#ddd"
								stroke-width="2"
							/>

							<g class="tick" transform="translate({xScale(tickValue)}, {tickSize / 2})">
								<text y="20" text-anchor="middle">{tickValue}%</text>
							</g>
						{/each}
					</g>
				</svg>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.dashboard {
		font-family: sans-serif;
		display: flex;
		flex-direction: column;
		justify-content: center;
		position: relative;
		height: 100%;
		width: 100%;
		max-width: 1400px;
		margin: 0 auto;

		&.show-all.overflow {
			justify-content: flex-start;
		}
	}

	.dashboard-content {
		position: relative;
		overflow-y: hidden;
	}

	.map-container {
		width: 100%;
		height: 100%;
		background-color: $color-bg-light;
		transition: all 0.5s ease;

		position: absolute;
		top: 0;
		left: 0;
		z-index: 10;
		// pointer-events: none;
		// opacity: 0;
		&.visible {
			opacity: 1;
			pointer-events: auto;
		}
	}

	.chart-container {
		height: var(--chart-height);
		max-height: var(--chart-max-height);
		overflow: hidden;
		transition: all 0.5s ease;
		display: flex;
		flex-direction: column;
		justify-content: center;
		position: relative;

		&.interactive-mode {
			overflow-y: scroll;
			display: block;
		}

		.bottom-gradient {
			bottom: -1px;
			left: 0;
			right: 0;
			height: 20px;
			background: linear-gradient(to bottom, transparent, $color-bg-light);
			pointer-events: none;
			z-index: 10;
		}
	}

	:global(svg) {
		display: block;
		font-size: 14px;
		font-family: sans-serif;
	}
	:global(.x-axis .tick text) {
		font-size: 12px;
		fill: #888;
	}

	.legend {
		display: flex;
		justify-content: flex-end;
		margin-bottom: 1rem;
		font-size: 14px;
	}

	.legend-item {
		display: flex;
		align-items: center;
		margin-left: 1.5rem;

		.dot {
			width: 12px;
			height: 12px;
			border-radius: 50%;
			margin-right: 0.5rem;

			&.men {
				background-color: #a3c102;
			}

			&.women {
				background-color: #333;
			}
		}
	}

	svg {
		transition: height 0.5s ease;
	}

	// svg * {
	// 	transition: all 0.5s ease;
	// }

	.axis {
		text {
			font-family: $font-family-mono;
		}
	}
</style>
