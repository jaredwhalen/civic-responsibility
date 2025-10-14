<script>
	import { fade, fly } from 'svelte/transition';
	import stateAbbreviations from '$lib/data/stateAbbreviations.json';
	import { ListFilter } from '@lucide/svelte';
	import { isMobile } from '$lib/stores/responsive.js';

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
	let isModalOpen = $state(false);
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

	// Toggle modal (mobile only)
	function toggleModal() {
		isModalOpen = !isModalOpen;
	}

	// Close modal
	function closeModal() {
		isModalOpen = false;
		isDropdownOpen = false;
	}

	// Get current view summary text
	function getCurrentViewSummary() {
		const viewLabel = options.find(opt => opt.value === selectedOption)?.label || 'U.S. average';
	

		if (activeView === 'state' && selectedStateView === 'map' && selectedStateMapViewOption) {
			return selectedStateMapViewOption;
		}
		
		return viewLabel;
	}

	// Prevent body scroll when modal is open on mobile
	$effect(() => {
		if ($isMobile && isModalOpen) {
			document.body.style.overflow = 'hidden';
		} else {
			document.body.style.overflow = '';
		}
		
		// Cleanup
		return () => {
			document.body.style.overflow = '';
		};
	});
</script>

<!-- Wrapper for mobile controls -->
<div class="controls-wrapper">
	<!-- Mobile filter button and summary (always visible on mobile) -->
	{#if $isMobile}
		<div class="mobile-controls-header">
			<button class="filter-button" onclick={toggleModal} aria-label="Open filter options">
				<ListFilter size={20} />
			</button>
			<div class="view-summary">
				<span class="view-summary-label">Viewing {selectedStateView === 'map' ? 'states' : 'data'} by:</span>
				<span class="view-summary-value">{getCurrentViewSummary()}</span>
			</div>
		</div>
	{/if}

	<!-- Modal overlay (mobile only) -->
	{#if $isMobile && isModalOpen}
		<div 
			class="modal-overlay" 
			onclick={closeModal} 
			onkeydown={(e) => e.key === 'Escape' && closeModal()}
			role="button"
			tabindex="-1"
			aria-label="Close modal"
			transition:fade={{ duration: 200 }}
		></div>
	{/if}

	<!-- Controls container -->
	<div class="controls-container" class:modal-open={$isMobile && isModalOpen}>
		{#if !$isMobile || isModalOpen}
			<div class="dashboard-controls" transition:fly={{ y: $isMobile ? 300 : 0, duration: 300 }}>
			<!-- Modal header (mobile only) -->
			{#if $isMobile}
				<div class="modal-header">
					<h2>Filter Options</h2>
					<button class="close-button" onclick={closeModal} aria-label="Close filters">×</button>
				</div>
			{/if}

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
												<div 
													class="state-pill" 
													onclick={(e) => {
														e.stopPropagation();
														removeState(state);
													}}
													onkeydown={(e) => {
														if (e.key === 'Enter' || e.key === ' ') {
															e.preventDefault();
															removeState(state);
														}
													}}
													role="button"
													tabindex="0"
													aria-label="Remove {state}"
												>
													<span class="state-name">{stateAbbreviations[state] || state}</span>
													<span class="remove-icon" aria-hidden="true">×</span>
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

			<!-- Apply button (mobile only) -->
			{#if $isMobile}
				<div class="modal-footer">
					<button class="apply-button" onclick={closeModal}>Apply Filters</button>
				</div>
			{/if}
		</div>
	{/if}
	</div>
</div>

<style lang="scss">
	// Modal overlay (mobile only)
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: rgba(0, 0, 0, 0.5);
		z-index: 1002;
	}

	// Mobile controls header (filter button + summary)
	.mobile-controls-header {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		// padding: 0.75rem 1rem;
		// background-color: #fff;
		// border-radius: 0.5rem;
		// box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		// margin-bottom: 1rem;

		.filter-button {
			width: 40px;
			height: 40px;
			border-radius: 0.375rem;
			background-color: $color-theme-yellow;
			color: #000;
			border: none;
			cursor: pointer;
			display: flex;
			align-items: center;
			justify-content: center;
			transition: all 0.2s ease;
			flex-shrink: 0;

			&:hover {
				background-color: #e1bc2f;
			}

			&:active {
				transform: scale(0.95);
			}
		}

		.view-summary {
			display: flex;
			flex-direction: column;
			gap: 0.125rem;
			flex: 1;
			min-width: 0;

			.view-summary-label {
				font-size: 0.75rem;
				color: #666;
				font-weight: 500;
			}

			.view-summary-value {
				font-size: 0.9rem;
				color: #000;
				font-weight: 600;
				white-space: nowrap;
				overflow: hidden;
				text-overflow: ellipsis;
			}
		}
	}

	.controls-container {
		position: relative;
		z-index: 1000;

		// Modal mode on mobile
		&.modal-open {
			position: fixed;
			bottom: 0;
			left: 0;
			right: 0;
			z-index: 1003;
		}
	}

	.dashboard-controls {
		display: flex;
		gap: 1rem;
		flex-wrap: wrap;
	
		@include mq('mobile', 'max') {
			flex-wrap: wrap;
			flex-direction: column;
			background-color: #fff;
			border-radius: 1rem 1rem 0 0;
			padding: 0;
			height: calc(100vh - var(--header-height, 0px));
			overflow-y: auto;
			box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.2);
			gap: 0rem;
		}

		// Modal header (mobile only)
		.modal-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			padding: 1.5rem 1rem 1rem;
			border-bottom: 1px solid #e0e0e0;
			position: sticky;
			top: 0;
			background-color: #fff;
			z-index: 10;

			h2 {
				font-size: 1.25rem;
				font-weight: 600;
				margin: 0;
			}

			.close-button {
				background: none;
				border: none;
				font-size: 2rem;
				line-height: 1;
				cursor: pointer;
				color: #666;
				padding: 0;
				width: 32px;
				height: 32px;
				display: flex;
				align-items: center;
				justify-content: center;
				transition: color 0.2s ease;

				&:hover {
					color: #000;
				}
			}
		}

		// Modal footer (mobile only)
		.modal-footer {
			padding: 1rem;
			border-top: 1px solid #e0e0e0;
			position: sticky;
			bottom: 0;
			background-color: #fff;
			z-index: 10;

			.apply-button {
				width: 100%;
				padding: 1rem;
				background-color: $color-theme-yellow;
				color: #000;
				border: none;
				border-radius: 0.5rem;
				font-size: 1rem;
				font-weight: 600;
				cursor: pointer;
				transition: all 0.2s ease;

				&:hover {
					background-color: #e1bc2f;
				}

				&:active {
					transform: scale(0.98);
				}
			}
		}

		.dashboard-controls-inner {
			width: fit-content;

			@include mq('mobile', 'max') {
				width: 100%;
				padding: 1rem;
				border-bottom: 1px solid #f0f0f0;

				&:last-of-type {
					border-bottom: none;
				}
			}

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
				justify-content: flex-start;
				align-items: center;
				gap: 0.25rem;
				flex-wrap: wrap;

				@include mq('mobile', 'max') {
					// overflow-x: scroll;
				}

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
		    width: fit-content;

			@include mq('mobile', 'max') {
				width: 100%;
			}

			.dropdown-button {
				width: 100%;
				min-width: 185px;

				@include mq('mobile', 'max') {
					min-width: 100%;
				}
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

							.remove-icon {
								color: #333;
							}
						}

						.state-name {
							font-weight: 500;
							color: #333;
							white-space: nowrap;
							line-height: 1; // Ensure consistent line height
						}

						.remove-icon {
							color: #666;
							font-weight: bold;
							font-size: 1.2rem;
							line-height: 1;
							display: flex;
							align-items: center;
							justify-content: center;
							transition: all 0.2s ease;
							margin-left: 0.25rem;
							flex-shrink: 0;
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
