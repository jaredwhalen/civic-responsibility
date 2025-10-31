<script>
	import { fade, fly } from 'svelte/transition';
	import { ListFilter } from '@lucide/svelte';
	import { isMobile } from '$lib/stores/responsive.js';
	import Dropdown from './Dropdown.svelte';

	// ===== PROPS =====
	let {
		activeView = $bindable(),
		selectedStateView = $bindable(),
		selectedStateMapViewOption = $bindable(),
		selectedStateChartViewOptions = $bindable(),
		searchOptions,
		interactiveMode = $bindable(),
		isPinned = $bindable(),
		onExit = () => {},
		stateColors = []
	} = $props();

	// ===== STATE =====
	let selectedOption = $state('mean');
	let isModalOpen = $state(false);
	let buttonRefs = $state({});

	// ===== CONSTANTS =====
	const options = [
		{ label: 'U.S. average', value: 'mean' },
		{ label: 'Political Identification', value: 'pid' },
		{ label: 'Gender', value: 'gender' },
		{ label: 'Generation', value: 'generation' },
		{ label: 'Race/Ethnicity', value: 'race' },
		{ label: 'State', value: 'state' }
	];

	const stateViewOptions = [
		{ label: 'Map', value: 'map' },
		{ label: 'Chart', value: 'chart' }
	];

	// ===== DERIVED VALUES =====
	let resultsOptions = $derived(
		selectedStateView === 'chart'
			? searchOptions.states.map((state) => ({ label: state, value: state }))
			: searchOptions.duties.map((duty) => ({ label: duty, value: duty }))
	);

	// ===== EFFECTS =====
	$effect(() => {
		if (activeView == 'mean') {
			selectedOption = 'mean';
			selectedStateMapViewOption = resultsOptions[0]?.value;
			selectedStateChartViewOptions = [];

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
	});

	$effect(() => {
		// Update selectedStateMapViewOption when resultsOptions change (for map view)
		if (
			resultsOptions.length > 0 &&
			!resultsOptions.find((opt) => opt.value === selectedStateMapViewOption)
		) {
			selectedStateMapViewOption = resultsOptions[0].value;
		}
	});

	$effect(() => {
		// Initialize selectedStateChartViewOptions when switching to chart view
		if (selectedStateView === 'chart') {
			selectedStateChartViewOptions = [];
		}
	});

	$effect(() => {
		// Prevent body scroll when modal is open on mobile
		if ($isMobile && isModalOpen) {
			document.body.style.overflow = 'hidden';
			document.body.style.position = 'fixed';
			document.body.style.width = '100%';
		} else {
			document.body.style.overflow = '';
			document.body.style.position = '';
			document.body.style.width = '';
		}

		// Cleanup
		return () => {
			document.body.style.overflow = '';
			document.body.style.position = '';
			document.body.style.width = '';
		};
	});

	// ===== EVENT HANDLERS =====
	function handleSelect(value) {
		selectedOption = value;
		activeView = value;

		if ($isMobile && activeView != 'state') {
			closeModal();
		}
	}

	function handleDropdownSelect(value) {
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
	}

	// ===== MOBILE HANDLERS =====
	function toggleModal() {
		isModalOpen = !isModalOpen;
	}

	function closeModal() {
		isModalOpen = false;
	}

	// ===== UTILITY FUNCTIONS =====
	function getCurrentViewSummary() {
		const viewLabel = options.find((opt) => opt.value === selectedOption)?.label || 'U.S. average';

		if (activeView === 'state' && selectedStateView === 'map' && selectedStateMapViewOption) {
			return selectedStateMapViewOption;
		}

		return viewLabel;
	}
</script>

<!-- ===== INSTRUCTIONS SNIPPET ===== -->
{#snippet instructions()}
	<p class="dashboard-instructions">
		Click {#if activeView == 'state' && selectedStateView === 'map'}the map{:else}the dots{/if} to compare
		responses. Select filters to view data by different categories.
	</p>
{/snippet}

<!-- ===== MAIN TEMPLATE ===== -->
<div class="controls-wrapper">
	<!-- Mobile filter button and summary (always visible on mobile) -->
	{#if $isMobile}
		<div class="mobile-controls-header">
			<button class="filter-button" onclick={toggleModal} aria-label="Open filter options">
				<ListFilter size={20} />
			</button>
			<div class="view-summary">
				{#if activeView == 'state'}
					<Dropdown
						options={resultsOptions}
						bind:selectedValues={selectedStateChartViewOptions}
						bind:selectedValue={selectedStateMapViewOption}
						viewMode={selectedStateView}
						onSelect={handleDropdownSelect}
						pillColors={stateColors}
					/>
				{:else}
					<span class="view-summary-label">Viewing data by:</span>
					<span class="view-summary-value">{getCurrentViewSummary()}</span>
				{/if}
			</div>
		</div>

		{@render instructions()}
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

				<!-- Scrollable content -->
				<div class="modal-content">
					{#if !$isMobile}
						<div class="control-section">
							{@render instructions()}
						</div>
					{/if}

					<!-- View data by section -->
					<div class="control-section">
						<div class="section-title">
							<h3>View data by</h3>
						</div>
						<div class="option-buttons">
							{#each options as option}
								<button
									bind:this={buttonRefs[option.value]}
									class="option-button {selectedOption === option.value ? 'selected' : ''}"
									onclick={() => handleSelect(option.value)}
								>
									{option.label}
								</button>
							{/each}
						</div>
					</div>

					<!-- State view options (only when state is selected) -->
					{#if activeView == 'state'}
						<div class="control-section">
							<div class="section-title">
								<h3>Display</h3>
							</div>
							<div class="option-buttons">
								{#each stateViewOptions as option}
									<button
										onclick={() => (selectedStateView = option.value)}
										class="option-button {selectedStateView === option.value ? 'selected' : ''}"
									>
										{option.label}
									</button>
								{/each}
							</div>
						</div>
					{/if}
				</div>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	// ===== DESKTOP STYLES =====
	.controls-wrapper {
		.controls-container {
			position: relative;
			z-index: 1000;

			.dashboard-controls {
				display: flex;
				flex-direction: column;
			}
		}
	}

	// ===== CONTROL SECTIONS =====
	.control-section {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;

		&:not(:last-child) {
			padding-bottom: 1.5rem;
			margin-bottom: 1rem;
			border-bottom: 1px solid var(--color-gray-200); // Standardized border between sections
		}

		.section-title {
			h3 {
				font-size: 1rem;
				font-weight: 600;
				margin: 0;
				color: #333;
			}
		}

		.option-buttons {
			display: flex;
			flex-direction: column;
			gap: 0.5rem;

			.option-button {
				padding: 0.75rem 1rem;
				border: 1px solid #d0d0d0;
				border-radius: 0.5rem;
				background: #fff;
				color: #666;
				font-size: 0.9rem;
				font-weight: 500;
				cursor: pointer;
				transition: all 0.2s ease;
				font-family: sans-serif;
				text-align: left;

				&.selected {
					background-color: $color-theme-yellow;
					color: #000;
					border-color: $color-theme-yellow;
				}

				&:hover:not(.selected) {
					background-color: #f8f8f8;
					border-color: #999;
					color: #333;
				}
			}
		}
	}

	// ===== MOBILE STYLES =====
	@include mq('mobile', 'max') {
		// Mobile controls header
		.mobile-controls-header {
			display: flex;
			align-items: center;
			gap: 0.75rem;
			margin-bottom: 1rem;

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

		// Modal overlay
		.modal-overlay {
			position: fixed;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background-color: rgba(0, 0, 0, 0.5);
			z-index: 1002;
		}

		// Controls container
		.controls-container {
			&.modal-open {
				position: fixed;
				top: calc(var(--header-height, 80px) + 1rem);
				bottom: 0;
				left: 1rem;
				right: 0;
				z-index: 1003;
				display: flex;
				flex-direction: column;
				width: calc(100% - 2rem);
			}

			.dashboard-controls {
				flex-direction: column;
				background-color: #fff;
				border-radius: 1rem 1rem 0 0;
				padding: 0;
				flex: 1;
				overflow-y: auto;
				box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.2);
				gap: 0;
				width: 100%;
				max-height: 100vh;

				// Modal header
				.modal-header {
					display: flex;
					justify-content: space-between;
					align-items: center;
					padding: 1.5rem 1rem 1rem;
					border-bottom: 1px solid var(--color-gray-200);
					position: sticky;
					top: 0;
					background-color: #fff;
					z-index: 10;
					flex-shrink: 0;

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

				// Scrollable content area
				.modal-content {
					flex: 1;
					overflow-y: auto;
					padding-bottom: 2rem; // Extra space at bottom for better UX
				}

				// Control sections on mobile
				.control-section {
					margin: 1rem;
					border-bottom: 1px solid var(--color-gray-200);

					&:last-of-type {
						border-bottom: none;
					}

					.option-buttons {
						.option-button {
							width: 100%;
						}
					}
				}
			}
		}
	}

	.dashboard-instructions {
		font-size: 1rem;
		color: #666;
		font-weight: 600;
		margin: 0;
		line-height: 1.4;

		@include mq('mobile', 'max') {
			font-size: 0.8rem;
			font-weight: 400;

			margin-bottom: 1rem;
		}
	}
</style>
