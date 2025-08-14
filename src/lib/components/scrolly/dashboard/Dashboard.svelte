<script>
	import { onMount } from 'svelte';
	import { scaleLinear } from 'd3-scale';
	import { fade, fly } from 'svelte/transition';
	import Row from './Row.svelte';
	import { userResponse } from '$lib/stores/userResponse.js';

	// components
	import Controls from './Controls.svelte';

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

	let isMountedWithDelay = $state(false);

	onMount(() => {
		if (interactiveMode) {
			setTimeout(() => {
				isMountedWithDelay = true;
			}, 500);
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
				{ label: 'Asian', color: '#E63719' }
			]
		},
		{
			label: 'Political Identification',
			value: 'pid'
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
		'12-dashboard': []
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

	let currentViewData = $derived(
		guessMode
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
				)
	);

	// Sort currentViewData when viewing state data in chart mode
	let sortedViewData = $derived.by(() => {
		if (activeView === 'state' && selectedStateView === 'chart' && selectedStateViewOption) {
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
		height: currentViewData.length * rowHeight,
		margins: {
			top: 10,
			right: 75,
			bottom: 40,
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
	let chartHeight = $derived(rowHeight * currentViewData.length);
</script>

<div
	class="dashboard {interactiveMode && interactiveMode ? 'interactive-mode' : ''}"
	bind:clientWidth={width}
	transition:fade={{ duration: animateMount ? 500 : 0 }}
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
		</div>
	{/if}

	<div
		class="chart-container {interactiveMode && isMountedWithDelay ? 'interactive-mode' : ''}"
		style:--chart-height="{interactiveMode && isMountedWithDelay
			? chartHeight < dashboardHeight
				? chartHeight
				: dashboardHeight - controlsHeight
			: chartHeight < dashboardHeight
				? chartHeight
				: dashboardHeight}px"
	>
		{#if activeView == 'state' && selectedStateView == 'map'}
			<div class="state-container">
				<h1>{selectedStateViewOption}</h1>
			</div>
		{:else}
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
								: 'all 0.5s ease-out'}
						/>
					{/each}
				</g>
			</svg>
		{/if}
		{#if showAll}
			<div class="bottom-gradient"></div>
		{/if}
		<!-- Bottom gradient overlay -->

	</div>

	{#if activeView != 'state' || selectedStateView != 'map'}
		<svg {width} height="50">
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
	{/if}
</div>

<style lang="scss">
	.dashboard {
		padding: 2rem;
		font-family: sans-serif;
		display: flex;
		flex-direction: column;
		justify-content: center;

		height: 100dvh;
		width: 100%;
		max-width: 1400px;
		margin: 0 auto;

		// &.interactive-mode {
		// 	display: block;
		// }
	}

	.chart-container {
		height: var(--chart-height);
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
			position: sticky;
			bottom: 0;
			left: 0;
			right: 0;
			height: 40px;
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
