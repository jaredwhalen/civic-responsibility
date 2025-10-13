<script>
	import { fade } from 'svelte/transition';
	import stateAbbreviations from '$lib/data/stateAbbreviations.json';

	let {
		activeView = $bindable(),
		selectedStateView = $bindable(),
		selectedStateMapViewOption = $bindable(),
		selectedStateChartViewOptions = $bindable(),
		searchOptions,
		interactiveMode = $bindable(),
		isPinned = $bindable(),
		onExit = () => {}
	} = $props();
	let selectedOption = $state('mean');

	let isDropdownOpen = $state(false);
	let buttonRefs = $state({});

	// Derived resultsOptions array based on selectedStateView
	let resultsOptions = $derived(
		selectedStateView === 'chart'
			? searchOptions.states.map((state) => ({ label: state, value: state }))
			: searchOptions.duties.map((duty) => ({ label: duty, value: duty }))
	);

	// Update selectedStateMapViewOption when resultsOptions change (for map view)
	$effect(() => {
		if (
			resultsOptions.length > 0 &&
			!resultsOptions.find((opt) => opt.value === selectedStateMapViewOption)
		) {
			selectedStateMapViewOption = resultsOptions[0].value;
		}
	});

	// Initialize selectedStateChartViewOptions when switching to chart view
	$effect(() => {
		if (selectedStateView === 'chart') {
			selectedStateChartViewOptions = [];
		}
	});

	const options = [
		{
			label: 'U.S. average',
			value: 'mean'
		},
		{
			label: 'Political Identification',
			value: 'pid'
		},
		{
			label: 'Gender',
			value: 'gender'
		},
		{
			label: 'Generation',
			value: 'generation'
		},
		{
			label: 'Race/Ethnicity',
			value: 'race'
		},

		{
			label: 'State',
			value: 'state'
		}
	];

	const stateViewOptions = [
		{
			label: 'Map',
			value: 'map'
		},
		{
			label: 'Chart',
			value: 'chart'
		}
	];

	$effect(() => {
		if (activeView == 'mean') {
			selectedOption = 'mean';
			selectedStateMapViewOption = resultsOptions[0]?.value;
			selectedStateChartViewOptions = [];
			isDropdownOpen = false;

			Object.values(buttonRefs).forEach((ref) => {
				if (ref && ref === document.activeElement) {
					ref.blur();
				}
			});
		}
	});

	$effect(() => {
		// Reset selected state when view type changes
		selectedStateMapViewOption = resultsOptions[0]?.value;
		selectedStateChartViewOptions = [];
		isDropdownOpen = false;
	});

	function handleSelect(value) {
		if (value == selectedOption) {
			selectedOption = 'mean';
			activeView = 'mean';
			return;
		}

		selectedOption = value;

		activeView = value;
	}

	function handleStateSelect(value) {
		if (selectedStateView === 'chart') {
			// Handle multiple state selection for chart view
			if (selectedStateChartViewOptions.includes(value)) {
				// Remove state if already selected
				selectedStateChartViewOptions = selectedStateChartViewOptions.filter(
					(state) => state !== value
				);
			} else if (selectedStateChartViewOptions.length < 3) {
				// Add state if under limit
				selectedStateChartViewOptions = [...selectedStateChartViewOptions, value];
			}
		} else {
			// Single selection for map view
			selectedStateMapViewOption = value;
		}
		isDropdownOpen = false;
	}

	function toggleDropdown() {
		isDropdownOpen = !isDropdownOpen;
	}

	// Remove a specific state from selection
	function removeState(stateToRemove) {
		selectedStateChartViewOptions = selectedStateChartViewOptions.filter(
			(state) => state !== stateToRemove
		);
	}

	// Get state abbreviation for display in pills
	function getStateAbbreviation(stateName) {
		return stateAbbreviations[stateName] || stateName;
	}

	// Close dropdown when clicking outside
	function handleClickOutside(event) {
		if (!event.target.closest('.dropdown-container')) {
			isDropdownOpen = false;
		}
	}

	// Get display text for chart view
	function getChartDisplayText() {
		if (selectedStateChartViewOptions.length === 0) {
			return 'Select up to 3 states';
		} else if (selectedStateChartViewOptions.length === 1) {
			return selectedStateChartViewOptions[0];
		} else {
			return `${selectedStateChartViewOptions.length} states selected`;
		}
	}
</script>

<!-- <svelte:window on:click={handleClickOutside} /> -->
<div class="controls-container">
	<div class="dashboard-controls">
		<div class="dashboard-controls-inner">
				<div class="dashboard-controls-inner-title">
					<h3>View data by</h3>
				</div>

				<div class="dashboard-controls-inner-options">
					{#each options as option}
						<button
							bind:this={buttonRefs[option.value]}
							class="dashboard-controls-inner-option {selectedOption === option.value
								? 'selected'
								: ''}"
							onclick={() => handleSelect(option.value)}
						>
							{option.label}
						</button>
					{/each}
				</div>
			</div>

			{#if activeView == 'state'}
				<div class="dashboard-controls-inner">
					<div class="dashboard-controls-inner-title">
						<h3>Display</h3>
					</div>

					<div class="dashboard-controls-inner-options">
						{#each stateViewOptions as option}
							<button
								onclick={() => (selectedStateView = option.value)}
								class="dashboard-controls-inner-option {selectedStateView === option.value
									? 'selected'
									: ''}">{option.label}</button
							>
						{/each}
					</div>
				</div>

				<div class="dashboard-controls-inner">
					<div class="dashboard-controls-inner-title">
						<h3>View results for</h3>
					</div>

					<div class="dropdown-container">
						<button class="dropdown-button" onclick={toggleDropdown} aria-expanded={isDropdownOpen}>
							<span class="dropdown-arrow" class:is-open={isDropdownOpen}>▼</span>
							<span class="dropdown-text">
								{#if selectedStateView === 'chart'}
									<!-- State pills for chart view -->
									{#if selectedStateChartViewOptions.length > 0}
										<div class="state-pills">
											{#each selectedStateChartViewOptions as state}
												<div class="state-pill" onclick={() => removeState(state)}>
													<span class="state-name">{stateAbbreviations[state] || state}</span>
													<button class="remove-state" aria-label="Remove {state}"> × </button>
												</div>
											{/each}
										</div>
									{:else}
										Select up to 3 states
									{/if}
								{:else}
									{selectedStateMapViewOption || 'Select a duty'}
								{/if}
							</span>
						</button>

						{#if isDropdownOpen}
							<div class="dropdown-menu" transition:fade={{ duration: 200 }}>
								{#each resultsOptions as option}
									<button
										class="dropdown-item {selectedStateView === 'chart'
											? selectedStateChartViewOptions.includes(option.value)
												? 'selected'
												: ''
											: selectedStateMapViewOption === option.value
												? 'selected'
												: ''}"
										onclick={() => handleStateSelect(option.value)}
										disabled={selectedStateView === 'chart' &&
											selectedStateChartViewOptions.length >= 3 &&
											!selectedStateChartViewOptions.includes(option.value)}
									>
										{option.label}
									</button>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			{/if}
	</div>
</div>

<style lang="scss">
	.controls-container {
		position: relative;
		z-index: 1000;
	}

	.dashboard-controls {
		// position: absolute;
		// top: 0;
		// left: 0;
		// right: 0;
		// width: 100%;
		// max-width: 1400px;
		// margin: 1rem auto;

		display: flex;
		gap: 1rem;

		.dashboard-controls-inner {
			width: fit-content;

			.dashboard-controls-inner-title {
				h3 {
					font-size: 1rem;
					font-weight: 600;
					margin: 0px 0px 5px;
				}
			}

			.dashboard-controls-inner-options {
				border-radius: 0.25rem;

				display: flex;
				justify-content: center;
				align-items: center;
				gap: 0.25rem;

				.dashboard-controls-inner-option {
					padding: 0.5rem 0.5rem;
					border: 1px solid #999;
					border-radius: 0.25rem;
					background: var(--bg-color);
					color: #666;
					font-size: 14px;
					font-weight: 500;
					cursor: pointer;
					transition: all 0.2s ease;
					font-family: sans-serif;
					white-space: nowrap;

					&.selected {
						background-color: $color-theme-yellow;
						color: #000;
						// font-weight: 600;
					}

					&:hover:not(.selected) {
						background-color: #f5f5f5;
						color: #333;
					}
				}
			}
		}

		.dropdown-container {
			position: relative;
			width: 100%;

			.dropdown-button {
				width: 100%;
				min-width: 185px;
				// height: 50px; // Fixed height instead of max-height
				padding: 0.5rem 1rem; // Reduced padding to account for fixed height
				border: none;
				border-radius: 0.25rem;
				padding: 0.5rem 0.5rem;
				border: 1px solid #999;
				border-radius: 0.25rem;
				background: var(--bg-color);
				color: #666;
				font-size: 14px;
				font-weight: 500;

				color: #666;
				font-size: 14px;
				font-weight: 500;
				cursor: pointer;
				transition: all 0.2s ease;
				font-family: sans-serif;
				box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.1);
				display: flex;
				align-items: center;
				justify-content: space-between;
				text-align: left;
				white-space: nowrap;
				overflow: hidden;
				text-overflow: ellipsis;
				position: relative; // For absolute positioning of pills
				box-sizing: border-box; // Ensure padding is included in height calculation

				&:hover {
					background-color: #f8f8f8;
				}

				.dropdown-arrow {
					color: #999;
					font-size: 10px;
					transition: transform 0.2s ease;
					margin-right: 0.5rem;
					flex-shrink: 0;
					transform: rotate(270deg);

					&.is-open {
						transform: rotate(360deg);
					}
				}

				.dropdown-text {
					flex: 1;
					margin-right: 0.5rem;
					display: flex;
					align-items: center;
					gap: 0.25rem;
					overflow: hidden;
					height: 100%; // Take full height of button
					max-height: 100%; // Ensure it doesn't exceed button height
				}

				// State pills styling - positioned inside the button
				.state-pills {
					display: flex;
					flex-wrap: wrap;
					gap: 0.25rem;
					align-items: center;
					flex: 1;
					overflow: hidden;
					min-height: 0;
					max-height: 100%; // Constrain to button height
					height: 100%; // Take full height

					.state-pill {
						display: flex;
						align-items: center; // Changed from baseline to center
						background-color: #e8e8e8;
						border-radius: 5px;
						padding: 0.75rem 0.5rem; // Reduced vertical padding
						border: 1px solid #d0d0d0;
						transition: all 0.2s ease;
						font-size: 0.75rem;
						flex-shrink: 0; // Prevent pills from shrinking
						cursor: pointer;
						height: 20px; // Fixed height for pills
						box-sizing: border-box; // Include border in height calculation

						&:hover {
							background-color: #d8d8d8;
							border-color: #b0b0b0;

							.remove-state {
								color: #333;
							}
						}

						.state-name {
							font-weight: 500;
							color: #333;
							white-space: nowrap;
							line-height: 1; // Ensure consistent line height
						}

						.remove-state {
							background: none;
							border: none;
							color: #666;
							font-weight: bold;
							cursor: pointer;
							padding: 0;
							width: 14px; // Slightly smaller
							height: 14px; // Slightly smaller
							display: flex;
							align-items: center;
							justify-content: center;
							border-radius: 50%;
							transition: all 0.2s ease;
							margin-left: 0.25rem;
							flex-shrink: 0;

							// &:hover {
							// 	background-color: #c0c0c0;
							// 	color: #333;
							// }

							&:focus {
								outline: none;
								outline-offset: 2px;
							}
						}
					}
				}
			}

			.dropdown-menu {
				position: absolute;
				top: 100%;
				left: 0;
				right: 0;
				background-color: #fff;
				border-radius: 0.5rem;
				box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.15);
				margin-top: 0.25rem;
				max-height: 200px;
				overflow-y: auto;
				z-index: 1000;

				.dropdown-item {
					width: 100%;
					padding: 0.75rem 1rem;
					border: none;
					background: transparent;
					color: #666;
					font-size: 14px;
					font-weight: 500;
					cursor: pointer;
					transition: all 0.2s ease;
					font-family: sans-serif;
					text-align: left;
					border-radius: 0;
					white-space: nowrap;
					overflow: hidden;
					text-overflow: ellipsis;
					display: flex;
					align-items: center;
					justify-content: space-between;

					&:first-child {
						border-top-left-radius: 0.5rem;
						border-top-right-radius: 0.5rem;
					}

					&:last-child {
						border-bottom-left-radius: 0.5rem;
						border-bottom-right-radius: 0.5rem;
					}

					&:hover:not(:disabled) {
						background-color: $color-beacon-yellow;
						color: #333;
					}

					&.selected {
						// background-color: $color-beacon-yellow;
						background-color: #eee;
						color: #888;
						// font-weight: 600;
					}

					&:disabled {
						opacity: 0.5;
						cursor: not-allowed;
						color: #ccc;
					}
				}
			}
		}
	}
</style>
